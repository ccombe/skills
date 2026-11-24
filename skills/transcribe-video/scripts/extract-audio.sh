#!/usr/bin/env bash
set -euo pipefail

VIDEO_PATH="${1:-}"
VIDEOS_DIR="${HOME}/Videos"

if [ -z "$VIDEO_PATH" ]; then
  if [ ! -d "$VIDEOS_DIR" ]; then
    echo "Default Videos directory not found: $VIDEOS_DIR" >&2
    exit 1
  fi
  VIDEO_PATH=$(find "$VIDEOS_DIR" -maxdepth 1 -type f \( -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.mov' -o -iname '*.webm' -o -iname '*.m4a' -o -iname '*.mp3' -o -iname '*.wav' \) -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-)
  if [ -z "$VIDEO_PATH" ]; then
    echo "No recording files found in $VIDEOS_DIR." >&2
    exit 1
  fi
fi

FFMPEG=$(command -v ffmpeg || true)
if [ -z "$FFMPEG" ]; then
  echo "ffmpeg not found on PATH. Install ffmpeg and retry." >&2
  exit 1
fi

DIR=$(dirname "$VIDEO_PATH")
FILENAME=$(basename "$VIDEO_PATH")
BASENAME="${FILENAME%.*}"
MP3_PATH="${DIR}/${BASENAME}.mp3"

echo "Source Video : $VIDEO_PATH"
echo "Target Audio : $MP3_PATH"
echo "Using ffmpeg : $FFMPEG"

"$FFMPEG" -y -i "$VIDEO_PATH" -vn -ac 1 -ar 16000 -b:a 32k "$MP3_PATH" 2>&1 | grep -E 'Duration|size=' || true

SIZE_BYTES=$(stat -c%s "$MP3_PATH" 2>/dev/null || stat -f%z "$MP3_PATH")
SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $SIZE_BYTES / 1048576}")
echo "Exported MP3 : $MP3_PATH (${SIZE_MB} MB)"

if [ "$SIZE_BYTES" -gt 8388608 ]; then
  "$FFMPEG" -y -i "$MP3_PATH" -f segment -segment_time 1500 -c copy "${DIR}/${BASENAME}.part-%02d.mp3" >/dev/null 2>&1
  for chunk in "${DIR}/${BASENAME}".part-*.mp3; do
    [ -f "$chunk" ] || continue
    CSIZE=$(stat -c%s "$chunk" 2>/dev/null || stat -f%z "$chunk")
    CMB=$(awk "BEGIN {printf \"%.2f\", $CSIZE / 1048576}")
    echo "Audio Chunk  : $chunk (${CMB} MB)"
  done
fi
