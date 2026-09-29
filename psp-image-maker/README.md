# psp-image-maker

Convert a JPEG or PNG to a PSP-compatible, 24-bit color JPEG.

Requires [ImageMagick](https://imagemagick.org/), available as the `magick`
command on current releases or `convert` on older ones.

## Usage

```bash
./psp-image-maker.sh -f ~/Pictures/wallpaper.png
```

The output is written to `out/` as `<input name> - PSP.jpg`. It is resized to
fit within the PSP screen's 480×272 pixels while retaining its aspect ratio;
it is never cropped. Transparent PNG areas become black. The JPEG uses 8 bits
per color channel (24-bit color) and baseline encoding for PSP compatibility.
