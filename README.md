# psp-video-converter

Convert an MP4 to a compact, PSP-compatible H.264/AAC file.

## Usage

From this repository, pass exactly one MP4 file to the converter:

```bash
./psp-video-converter.sh ~/Documents/'Paranormal Activity.mp4'
```

The converted file is written to `out/` as `<input name> - PSP.mp4`. Copy that
MP4 to the PSP's `VIDEO` directory.
