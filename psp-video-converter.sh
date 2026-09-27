#!/usr/bin/env bash
# Convert a supported video file to a compact format playable by a PSP.
# Usage: psp-video-converter.sh INPUT.<format>

set -euo pipefail

# Common video containers supported by the installed ffmpeg build. Add further
# filename extensions here when a compatible source format is encountered.
supported_formats=(
    mp4 m4v mov
    mkv webm
    avi divx
    mpg mpeg mpe m2v vob
    ts m2ts mts
    wmv asf
    flv f4v
    3gp 3g2
    ogv ogm
    dv
)

printf -v supported_formats_text '.%s, ' "${supported_formats[@]}"
supported_formats_text=${supported_formats_text%, }

usage() {
    printf 'Usage: %s INPUT.<format>\n' "${0##*/}" >&2
    printf 'Creates a compact PSP-compatible MP4.\n' >&2
}

if [[ $# -ne 1 ]]; then
    usage
    exit 2
fi

input=$1
if [[ ! -f "$input" ]]; then
    printf 'Input file not found: %s\n' "$input" >&2
    exit 1
fi

input_lower=${input,,}
input_supported=false
for format in "${supported_formats[@]}"; do
    if [[ "$input_lower" == *."$format" ]]; then
        input_supported=true
        break
    fi
done

if [[ "$input_supported" != true ]]; then
    printf 'Input must be one of the supported file formats: %s\n' "$supported_formats_text" >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    printf 'ffmpeg is required but was not found in PATH.\n' >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
input_name=$(basename -- "$input")
input_stem=${input_name%.*}
output_dir="$script_dir/out"
output="$output_dir/$input_stem - PSP.mp4"

mkdir -p -- "$output_dir"

if [[ -e "$output" ]]; then
    printf 'Refusing to overwrite existing file: %s\n' "$output" >&2
    printf 'Choose a different output path, or remove the existing file first.\n' >&2
    exit 1
fi

ffmpeg -hide_banner -n -i "$input" \
    -map 0:v:0 -map '0:a:0?' \
    -vf 'scale=480:272:force_original_aspect_ratio=decrease:force_divisible_by=2,pad=480:272:(ow-iw)/2:(oh-ih):black,setsar=1' \
    -c:v libx264 -profile:v baseline -level:v 3.0 -pix_fmt yuv420p \
    -preset slow -b:v 300k -maxrate 500k -bufsize 1000k \
    -x264-params 'ref=1:bframes=0:cabac=0:weightp=0' \
    -c:a aac -ac 1 -ar 44100 -b:a 48k \
    -movflags +faststart "$output"

printf 'Created PSP-compatible video: %s\n' "$output"
