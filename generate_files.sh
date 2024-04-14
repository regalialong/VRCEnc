#!/bin/bash

# Preperation
outdir=./output/
declare -a videocodecs=("libvpx-vp9" "libx264" "libx265" "libsvtav1")

# Remove outdir for dev purposes
rm -rf $outdir

mkdir $outdir
for i in "${videocodecs[@]}"; do
    mkdir "$outdir"/"$i"
done

ffmpeg -hide_banner -loglevel warning -i sample.mp4 -c:a ac3 "$outdir"audioac3.ac3

set -x
for i in "${videocodecs[@]}"; do
    ffmpeg  -hide_banner -loglevel warning -stats -i sample.mp4 -movflags +faststart -c:v "$i" -c:a aac "$outdir"/"$i"/aac.mp4

    # Since we now have working encode, copy the video from the previous one to save on time.
    ffmpeg  -hide_banner -loglevel warning -stats -i "$outdir"/"$i"/aac.mp4 -movflags +faststart -c:v copy -c:a libopus "$outdir"/"$i"/opus.mp4
    ffmpeg  -hide_banner -loglevel warning -stats -i "$outdir"/"$i"/aac.mp4 -i "$outdir"audioac3.ac3 -c:v copy -c:a:0 ac3 "$outdir"/"$i"/ac3.mp4

    # Remux to webm container if format supports it
    # "Only VP8 or VP9 or AV1 video and Vorbis or Opus audio and WebVTT subtitles are supported for WebM."
    if [[ "$i" = libvpx-vp9  ]] || [[ "$i" = libsvtav1 ]]; then
        ffmpeg -hide_banner -loglevel warning -i "$outdir"/"$i"/opus.mp4 -c copy "$outdir"/"$i"/opus.webm
    fi
done

notify-send "Put down that girlcock" "Your encode is finished."
