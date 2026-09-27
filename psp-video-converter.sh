#!/usr/bin/env bash
# Convert an MP4 to a compact format playable by a PSP.
# Usage: psp-video-convert.sh INPUT.mp4 [OUTPUT.mp4]

set -euo pipefail

usage() {
    printf 'Usage: %s INPUT.mp4 [OUTPUT.mp4]\n' "${0##*/}" >&2
    printf 'Creates a 480x272 H.264 Baseline/AAC MP4 suitable for PSP playback.\n' >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
    exit 2
fi

input=$1
if [[ ! -f "$input" ]]; then
    printf 'Input file not found: %s\n' "$input" >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    printf 'ffmpeg is required but was not found in PATH.\n' >&2
    exit 1
fi

if [[ $# -eq 2 ]]; then
    output=$2
else
    input_dir=$(dirname -- "$input")
    input_name=$(basename -- "$input")
    input_stem=${input_name%.*}
    output="$input_dir/$input_stem - PSP.mp4"
fi

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
