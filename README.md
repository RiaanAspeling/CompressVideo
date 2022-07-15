# CompressVideo
This script compresses videos to h265 (HEVC) from one location to another recursivly without overwriting the destination.

# Requirement
The script uses ffmpeg and can be install on Debian/Ubuntu based systems with:
```
~$ apt install ffmpeg
```

# Usage
```
~$ ./compress_video.sh [Extension] [Start dir] [Destination dir]
```

# Example
Compress videos from location ```/mnt/videos``` to ```/home/user/videos```
```
~$ ./compress_video.sh mkv /mnt/videos ./videos
```
The output might look like this:
```
Destination file exist: ./videos/Season 1/video1.S34E04.mkv
---------------------------------------------------------------------------------------------------------------------------------
Compressing  /mnt/videos/Season 1/video2.mkv  with size ( 1280 x 720 ) to file  ./Season 1/video2.mkv
---------------------------------------------------------------------------------------------------------------------------------
x265 [info]: HEVC encoder version 3.4
x265 [info]: build info [Linux][GCC 7.5.0][64 bit] 8bit+10bit+12bit
x265 [info]: using cpu capabilities: MMX2 SSE2Fast LZCNT SSSE3 SSE4.2 AVX FMA3 BMI2 AVX2
x265 [info]: Main profile, Level-3.1 (Main tier)
x265 [warning]: No thread pool allocated, --wpp disabled
x265 [warning]: No thread pool allocated, --lookahead-slices disabled
x265 [info]: Slices                              : 1
x265 [info]: frame threads / pool features       : 3 / none
x265 [info]: Coding QT: max CU size, min CU size : 64 / 8
x265 [info]: Residual QT: max TU size, max depth : 32 / 1 inter / 1 intra
x265 [info]: ME / range / subpel / merge         : hex / 57 / 2 / 3
x265 [info]: Keyframe min / max / scenecut / bias  : 25 / 250 / 40 / 5.00
x265 [info]: Lookahead / bframes / badapt        : 20 / 4 / 2
x265 [info]: b-pyramid / weightp / weightb       : 1 / 1 / 0
x265 [info]: References / ref-limit  cu / depth  : 3 / off / on
x265 [info]: AQ: mode / str / qg-size / cu-tree  : 2 / 1.0 / 32 / 1
x265 [info]: Rate Control / qCompress            : CRF-28.0 / 0.60
x265 [info]: tools: rd=3 psy-rd=2.00 early-skip rskip mode=1 signhide tmvp
x265 [info]: tools: b-intra strong-intra-smoothing deblock sao
frame=33025 fps= 13 q=32.0 size=  219136kB time=00:18:23.03 bitrate=1627.5kbits/s speed=0.418x
```
