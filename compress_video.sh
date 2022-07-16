#!/bin/bash

#=============================================================================
#
#    FILE: compress_video.sh
#
#    USAGE:
#       compress_video.sh [-e EXTENSION] [-s SOURCE] [-d DESTINATION]
#                          -e EXTENSION      Specify the file extension
#                                            to filter on source. Eg: -e mkv'
#                          -s SOURCE         Specify the source folder
#                                            to compress from. Eg: /mnt/myvideos'
#                          -d DESTINATION    Specify the destination folder to
#                                            compress to. Note that files will
#                                            not be overwritten. Eg: /mnt/converted'
#
#    DESCRIPTION: This script compresses videos to h265 (HEVC) from one location
#    to another recursively without overwriting the destination.
#
#    Copyright 2022 Riaan Aspeling
#
#    Permission is hereby granted, free of charge, to any person obtaining a
#    copy of this software and associated documentation files (the "Software")
#    , to deal in the Software without restriction, including without
#    limitation the rights to use, copy, modify, merge, publish, distribute,
#    sublicense, and/or sell copies of the Software, and to permit persons to
#    whom the Software is furnished to do so, subject to the following
#    conditions:
#
#    The above copyright notice and this permission notice shall be included
#    in all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: Report bugs to Riaan Aspeling via Github:
#                https://github.com/RiaanAspeling/CompressVideo/issues
#         NOTES: ---
#        AUTHOR: Riaan Aspeling
#  CONTRIBUTORS: ---
#  ORGANIZATION: UNAD cc
#       CREATED: 2022-07
#  LAST UPDATED: 2022-07
#       VERSION: 1
#     SCRIPT ID: 1
#=============================================================================

# show the usage pattern of this script
function usage()
{
    echo "Usage: $(basename $0) [-e EXTENSION] [-s SOURCE] [-d DESTINATION]" 2>&1
    echo '    -e EXTENSION      Specify the file extension to filter on source. Eg: -e mkv'
    echo '    -s SOURCE         Specify the source folder to compress from. Eg: /mnt/myvideos'
    echo '    -d DESTINATION    Specify the destination folder to compress to. Note that files will not be overwritten. Eg: /home/user/myvideos'
    exit 1
}

# unset variables
unset -v extension
unset -v source
unset -v destination

# if no input argument found, exit the script with usage
if [[ ${#} -eq 0 ]]; then
    usage
fi

# draw a dashed line the width of the console
function draw_line()
{
    local width=$(tput cols)
    for (( x = 0; x < "$width"; ++x )); do echo -e -n "\e[1;32m-"; done
    echo -e "\e[0m"
}

# list of arguments expected in the input
optstring=":e:s:d:"

# assign arguments to variables
while getopts ${optstring} arg; do
  case "${arg}" in
    e)
        extension=${OPTARG}
        ;;
    s)
        source=$OPTARG
        ;;
    d)
        destination=$OPTARG
        ;;
    :)
        echo "$0: Must supply an argument to -$OPTARG." >&2
        exit 1
        ;;
    ?)
        echo "Invalid option: -${OPTARG}."
        exit 2
        ;;
  esac
done

# check that all arguments was supplied
if [ -z "$extension" ]; then
    echo "Extension argument is required!"
    usage
fi
if [ -z "$source" ]; then
    echo "Source argument is required!"
    usage
fi
if [ -z "$destination" ]; then
    echo "Destination argument is required!"
    usage
fi

# Enable globstar for recursive matching
shopt -s globstar

# Loop though all sub-folders and files from the source folder.
for i in $source/**/*.$extension; do
    relative_path=${i#$source}

    # Check if the destination file already exists.
    if [[ -f "$destination$relative_path" ]]; then
        echo -e "\e[1;33mDestination file exists: $destination$relative_path"
        continue
    fi

    # Extract the codex used in the source file
    codex=$(ffprobe -hide_banner -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$i")

    # Check if the source file is already compressed with h265. (No need to re-compress)
    if [ "${codex//$'\r'/}" = "hevc" ]; then
        echo -e "\e[1;33mSource file is already HEVC encoded : $i"
        continue
    fi

    # Extract the video dimensions from the source file
    width=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=width -of default=nw=1:nk=1 "$i")
    height=$(ffprobe -loglevel error -select_streams v:0 -show_entries stream=height -of default=nw=1:nk=1 "$i")

    draw_line
    echo -e "Compressing \e[1;32m" $i "\e[0m with size (\e[1;31m" $width "x" $height "\e[0m) to file \e[1;34m" $destination$relative_path "\e[0m"
    draw_line

    # Create the output folder if it doesn't exist
    mkdir -p $destination"$(dirname "$relative_path")"

    # Run ffmpeg with nice to not hog all CPU for itself
    nice ffmpeg -stats -hide_banner -loglevel error -i "$i" -c:v libx265 -vtag hvc1 -c:a copy "$destination$relative_path"
done
