#!/bin/bash

function draw_line()
{
    local width=$(stty -a <"/dev/pts/1" | grep -Po '(?<=columns )\d+')
    for (( x = 0; x < "$width"; ++x )); do echo -e -n "\e[1;32m-"; done
    echo -e "\e[0m"
}

if [[ -z "$3" ]]; then
   echo "Usage"
   echo "   compress_video.sh [Extension] [Start dir] [Destination dir]"
   exit
fi

ext=$1
out=$3
#enable globstar to recursively match all files in folder
shopt -s globstar
for i in $2/**/*.$1; do
    relative_path=${i#$2}

    if [[ -f "$out$relative_path" ]]; then
        echo -e "\e[1;33mDestination file exist: $out$relative_path"
        continue
    fi

    codex=$(ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$i")

    if [ "${codex//$'\r'/}" = "hevc" ]; then
        echo -e "\e[1;33mSource file is already HEVC encoded : $i"
        continue
    fi

    width=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=width -of default=nw=1:nk=1 "$i")
    height=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$i")

    draw_line
    echo -e "Compressing \e[1;32m" $i "\e[0m with size (\e[1;31m" $width "x" $height "\e[0m) to file \e[1;34m" $out$relative_path "\e[0m"
    draw_line
    mkdir -p $out"$(dirname "$relative_path")"

    nice ffmpeg -stats -hide_banner -loglevel error -i "$i" -c:v libx265 -vtag hvc1 -c:a copy "$out$relative_path"
done
