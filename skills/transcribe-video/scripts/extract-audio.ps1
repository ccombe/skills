param(
    [Parameter(Mandatory=$false, Position=0)]
    [string]$VideoPath
)

$ErrorActionPreference = "Stop"

# 1. Resolve video file (default to newest video in the user's Videos folder)
$videosDir = Join-Path $HOME "Videos"
if ([string]::IsNullOrWhiteSpace($VideoPath)) {
    if (-not (Test-Path $videosDir)) {
        throw "Default Videos directory not found: $videosDir"
    }
    $latest = Get-ChildItem -Path $videosDir -Include *.mkv,*.mp4,*.mov,*.webm,*.m4a,*.mp3,*.wav -File |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $latest) {
        throw "No recording files found in $videosDir."
    }
    $VideoPath = $latest.FullName
} else {
    $VideoPath = (Resolve-Path -LiteralPath $VideoPath).Path
}

$videoFile = Get-Item -LiteralPath $VideoPath
$dir = $videoFile.DirectoryName
$baseName = $videoFile.BaseName
$mp3Path = Join-Path $dir "$baseName.mp3"

# 2. Locate ffmpeg
$ffmpegCmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
if ($ffmpegCmd) {
    $ffmpeg = $ffmpegCmd.Source
} elseif (Test-Path "C:\Program Files\DownloadHelper CoApp\ffmpeg.exe") {
    $ffmpeg = "C:\Program Files\DownloadHelper CoApp\ffmpeg.exe"
} else {
    throw "ffmpeg not found on PATH. Install ffmpeg and retry."
}

Write-Output "Source Video : $VideoPath"
Write-Output "Target Audio : $mp3Path"
Write-Output "Using ffmpeg : $ffmpeg"

# 3. Extract mono 16kHz 32kbps MP3 in the same directory
& $ffmpeg -y -i $VideoPath -vn -ac 1 -ar 16000 -b:a 32k $mp3Path 2>&1 | Select-String "Duration|size=" | ForEach-Object { $_.Line }

$mp3Item = Get-Item -LiteralPath $mp3Path
Write-Output ("Exported MP3 : {0} ({1:N2} MB)" -f $mp3Item.FullName, ($mp3Item.Length / 1MB))

# 4. If file exceeds 8 MB (~35 mins), split into 25-minute segments for multimodal reading
if ($mp3Item.Length -gt 8MB) {
    $chunkPattern = Join-Path $dir "$baseName.part-%02d.mp3"
    & $ffmpeg -y -i $mp3Path -f segment -segment_time 1500 -c copy $chunkPattern 2>&1 | Out-Null
    Get-ChildItem -Path $dir -Filter "$baseName.part-*.mp3" | Sort-Object Name | ForEach-Object {
        Write-Output ("Audio Chunk  : {0} ({1:N2} MB)" -f $_.FullName, ($_.Length / 1MB))
    }
}
