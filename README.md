# psp-video-converter

Convert a video file to a compact, PSP-compatible H.264/AAC MP4 file.

Requires [ffmpeg](https://ffmpeg.org/download.html)

## Usage

Convert one file with `-f`:

```bash
./psp-video-converter.sh -f ~/Documents/'Paranormal Activity.mp4'
```

Convert all supported files directly in a directory with `-d`:

```bash
./psp-video-converter.sh -d ~/Documents/Movies
```

Directory conversion runs up to five files in parallel. Override that limit
with `-b`:

```bash
./psp-video-converter.sh -d ~/Documents/Movies -b 3
```

Outputs are written to `out/` as `<input name> - PSP.mp4`. Directory scanning
is non-recursive. Copy the resulting MP4 files to the PSP's `VIDEO` directory.

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
