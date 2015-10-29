#!/bin/sh

rm -Rf video
mkdir video

from=1
to=250

for i in `seq $from $to`
do
	ffmpeg -loop 1 -i "../svg-to-png-grey-bg/$i.png" -i "target/RTK1_keyword_pair_$i.mp3" -shortest -acodec copy "video/RTK1_keyword_pair_$i.mp4"
done
