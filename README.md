# psp-video-converter

Convert an uncompressed MP4 to a compact, PSP-compatible H.264/AAC file.

## Usage

From this repository, pass exactly one MP4 file to the converter:

```bash
./psp-video-converter.sh ~/Documents/'Paranormal Activity.mp4'
```

The converted file is written to `out/` as `<input name> - PSP.mp4`. Copy that
MP4 to the PSP's `VIDEO` directory.

## Why

- `.mp4` files are bloated; my repository contains tons of them that are >1GB in size.
- My PSP only has a 64 GB memory stick, and I would like to store lots of movies on it, as the PSP is an incredible media-playback handheld.
