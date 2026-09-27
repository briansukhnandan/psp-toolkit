# psp-video-converter

Convert a video file to a compact, PSP-compatible H.264/AAC MP4 file.

## Usage

From this repository, pass exactly one file to the converter:

```bash
./psp-video-converter.sh ~/Documents/'Paranormal Activity.mp4'
```

The converted file is written to `out/` as `<input name> - PSP.mp4`. Copy that
MP4 to the PSP's `VIDEO` directory.

## Supported input formats

- `.mp4`
- `.mkv`

Add newly supported filename extensions to the `supported_formats` list in
`psp-video-converter.sh` and to this section.

## Why

- Video files are bloated; my repository contains tons of them that are >1GB in size.
- My PSP only has a 64 GB memory stick, and I would like to store lots of movies on it, as the PSP is an incredible media-playback handheld.
