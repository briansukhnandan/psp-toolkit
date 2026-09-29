#!/usr/bin/env bash
# Convert supported video files to a compact format playable by a PSP.
# Usage: psp-video-converter.sh -f FILE | -d DIRECTORY [-b BATCH_SIZE]

set -euo pipefail

# Input filename extensions.
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
    printf 'Usage: %s -f FILE | -d DIRECTORY [-b BATCH_SIZE]\n' "${0##*/}" >&2
    printf '  -f FILE       Convert one supported video file.\n' >&2
    printf '  -d DIRECTORY  Convert supported files directly in a directory.\n' >&2
    printf '  -b SIZE       Maximum parallel directory conversions (default: 5).\n' >&2
}

is_supported_file() {
    local candidate=${1,,}
    local format

    for format in "${supported_formats[@]}"; do
        [[ "$candidate" == *."$format" ]] && return 0
    done
    return 1
}

convert_file() {
    local input=$1
    local input_name
    local input_stem
    local output

    input_name=$(basename -- "$input")
    input_stem=${input_name%.*}
    output="$output_dir/$input_stem - PSP.mp4"

    if [[ -e "$output" ]]; then
        printf 'Refusing to overwrite existing file: %s\n' "$output" >&2
        return 1
    fi

    printf 'Converting: %s\n' "$input"
    ffmpeg -hide_banner -n -i "$input" \
        -map 0:v:0 -map '0:a:0?' \
        -vf 'scale=480:272:force_original_aspect_ratio=decrease:force_divisible_by=2,pad=480:272:(ow-iw)/2:(oh-ih):black,setsar=1' \
        -c:v libx264 -profile:v baseline -level:v 3.0 -pix_fmt yuv420p \
        -preset slow -b:v 300k -maxrate 500k -bufsize 1000k \
        -x264-params 'ref=1:bframes=0:cabac=0:weightp=0' \
        -c:a aac -ac 1 -ar 44100 -b:a 48k \
        -movflags +faststart "$output"
    printf 'Created PSP-compatible video: %s\n' "$output"
}

input_file=
input_directory=
batch_size=5
batch_size_set=false

while getopts ':f:d:b:h' option; do
    case "$option" in
        f) input_file=$OPTARG ;;
        d) input_directory=$OPTARG ;;
        b)
            batch_size=$OPTARG
            batch_size_set=true
            ;;
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

if [[ $# -ne 0 ]] || { [[ -n "$input_file" ]] && [[ -n "$input_directory" ]]; } || \
    { [[ -z "$input_file" ]] && [[ -z "$input_directory" ]]; }; then
    usage
    exit 2
fi

if [[ ! "$batch_size" =~ ^[1-9][0-9]*$ ]]; then
    printf 'Batch size must be a positive integer: %s\n' "$batch_size" >&2
    exit 1
fi

if [[ -n "$input_file" && "$batch_size_set" == true ]]; then
    printf 'The -b option can only be used with -d.\n' >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    printf 'ffmpeg is required but was not found in PATH.\n' >&2
    exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
output_dir="$script_dir/out"
mkdir -p -- "$output_dir"

if [[ -n "$input_file" ]]; then
    if [[ ! -f "$input_file" ]]; then
        printf 'Input file not found: %s\n' "$input_file" >&2
        exit 1
    fi
    if ! is_supported_file "$input_file"; then
        printf 'Input must be one of the supported file formats: %s\n' "$supported_formats_text" >&2
        exit 1
    fi
    convert_file "$input_file"
    exit 0
fi

if [[ ! -d "$input_directory" ]]; then
    printf 'Input directory not found: %s\n' "$input_directory" >&2
    exit 1
fi

files=()
while IFS= read -r -d '' candidate; do
    is_supported_file "$candidate" && files+=("$candidate")
done < <(find "$input_directory" -maxdepth 1 -type f -print0)

if [[ ${#files[@]} -eq 0 ]]; then
    printf 'No supported video files found in: %s\n' "$input_directory" >&2
    exit 1
fi

failures=0
active_jobs=0
for input in "${files[@]}"; do
    convert_file "$input" &
    active_jobs=$((active_jobs + 1))
    if [[ $active_jobs -ge $batch_size ]]; then
        wait -n || ((failures += 1))
        active_jobs=$((active_jobs - 1))
    fi
done

while [[ $active_jobs -gt 0 ]]; do
    wait -n || ((failures += 1))
    active_jobs=$((active_jobs - 1))
done

if [[ $failures -ne 0 ]]; then
    printf '%d conversion(s) failed.\n' "$failures" >&2
    exit 1
fi
