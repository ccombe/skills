---
name: transcribe-video
description: "Transcribe a video or audio recording into an MP3, executive summary, and verbatim transcript in the same folder. Use when given a recording path or asked to transcribe a meeting or latest recording."
---

# Transcribe Video

## 1. Extract audio beside the recording

Run the extraction script from this skill's directory, passing the recording path (or omit the argument to pick the newest video in the user's `Videos` folder):

- **Windows (PowerShell)**:
  ```powershell
  pwsh -NoProfile -File "<skill-dir>/scripts/extract-audio.ps1" "<VideoPath>"
  ```
- **macOS / Linux / WSL**:
  ```bash
  bash "<skill-dir>/scripts/extract-audio.sh" "<VideoPath>"
  ```

**Done when** `<Dir>/<BaseName>.mp3` (and `<BaseName>.part-*.mp3` chunks for files over 8 MB / ~35 min) is written with path and size logged.

## 2. Load the audio

Call `read_file` on `<Dir>/<BaseName>.mp3`, or on each `<BaseName>.part-XX.mp3` chunk in ascending order when split.

**Done when** every audio file or chunk is loaded into context.

## 3. Write summary and verbatim transcript

Write `<Dir>/<BaseName> - Transcript and Summary.md` and copy it to `<Dir>/<BaseName>.txt` with three sections:

1. **Header**: Date, source recording path, exported `.mp3` path, and participant names.
2. **Executive Summary**: Context, key themes and discussion points, concrete numbers/metrics/examples, decisions, and next steps.
3. **Full Transcript**: Every turn of dialogue from start to sign-off as `**[MM:SS] Speaker:** ...` with timestamps anchored to the recording's actual duration.

Remove any temporary `<BaseName>.part-*.mp3` chunks after writing the transcript.

**Done when** every turn of dialogue, metric, and decision in the recording is accounted for, `<BaseName>.mp3`, `<BaseName> - Transcript and Summary.md`, and `<BaseName>.txt` exist in `<Dir>`, temporary chunks are removed, and the summary with clickable file links is shown to the user.
