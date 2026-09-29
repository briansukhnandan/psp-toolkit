#!/usr/bin/env bash
# Convert a JPEG or PNG image to a PSP-compatible JPEG.
# Usage: psp-image-maker.sh -f FILE

set -euo pipefail

usage() {
    printf 'Usage: %s -f FILE\n' "${0##*/}" >&2
    printf '  -f FILE  Convert one .jpg, .jpeg, or .png image.\n' >&2
}

is_supported_file() {
    case "${1,,}" in
        *.jpg|*.jpeg|*.png) return 0 ;;
        *) return 1 ;;
    esac
}

input_file=

while getopts ':f:h' option; do
    case "$option" in
        f) input_file=$OPTARG ;;
        h)
            usage
            exit 0
            ;;
        :|\?)
            usage
            exit 2
            ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 || -z "$input_file" ]]; then
    usage
    exit 2
fi

if [[ ! -f "$input_file" ]]; then
    printf 'Input file not found: %s\n' "$input_file" >&2
    exit 1
fi

if ! is_supported_file "$input_file"; then
    printf 'Input must be a .jpg, .jpeg, or .png file: %s\n' "$input_file" >&2
    exit 1
fi

if command -v magick >/dev/null 2>&1; then
    image_tool=magick
elif command -v convert >/dev/null 2>&1; then
    image_tool=convert
else
    printf 'ImageMagick is required but neither `magick` nor `convert` was found in PATH.\n' >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output_dir="$script_dir/out"
input_name=$(basename -- "$input_file")
input_stem=${input_name%.*}
output="$output_dir/$input_stem - PSP.jpg"

mkdir -p -- "$output_dir"

if [[ -e "$output" ]]; then
    printf 'Refusing to overwrite existing file: %s\n' "$output" >&2
    exit 1
fi

printf 'Converting: %s\n' "$input_file"
"$image_tool" "$input_file" \
    -auto-orient \
    -resize '480x272' \
    -background black -alpha remove -alpha off \
    -colorspace sRGB -type TrueColor -depth 8 \
    -define jpeg:sampling-factor=2x2 -interlace none -quality 92 \
    "$output"
printf 'Created PSP-compatible image: %s\n' "$output"
