# psp-video-converter

Convert a video file to a compact, PSP-compatible H.264/AAC MP4 file.

Requires [ffmpeg](https://ffmpeg.org/download.html)

## Usage

From this repository, pass exactly one file to the converter:

```bash
./psp-video-converter.sh ~/Documents/'Paranormal Activity.mp4'
```

The converted file is written to `out/` as `<input name> - PSP.mp4`. Copy that
MP4 to the PSP's `VIDEO` directory.

## Supported input formats

The converter accepts these common video filename extensions; `ffmpeg` performs
the format and codec detection.

- MP4 / QuickTime: `.mp4`, `.m4v`, `.mov`
- Matroska / WebM: `.mkv`, `.webm`
- AVI: `.avi`, `.divx`
- MPEG / DVD video: `.mpg`, `.mpeg`, `.mpe`, `.m2v`, `.vob`
- MPEG transport streams: `.ts`, `.m2ts`, `.mts`
- Windows Media: `.wmv`, `.asf`
- Flash video: `.flv`, `.f4v`
- 3GPP: `.3gp`, `.3g2`
- Ogg video: `.ogv`, `.ogm`
- Digital Video: `.dv`

## Why

- Video files are bloated; my repository contains tons of them that are >1GB in size.
- My PSP only has a 64 GB memory stick, and I would like to store lots of movies on it, as the PSP is an incredible media-playback handheld.
