#!/bin/sh

# This script will create 250 mp3 files with template: keyword_en + 500ms silence + keyword_jp + 10s silence
# If there is no audio for Japanese keyword, then keyword_jp is omitted.

# ajutiste failide asukoht

rm -Rf tmp
mkdir tmp
mkdir tmp/en
mkdir tmp/jp

# vaikusefailide loomine
enjpSilenceLen="0.5"
lastSilenceLen="10.0"
enjpSilenceFile="tmp/enjpSilenceFile.mp3"
lastSilenceFile="tmp/lastSilenceFile.mp3"

sox -n -r 44100 -c 1 $enjpSilenceFile trim 0.0 $enjpSilenceLen
sox -n -r 44100 -c 1 $lastSilenceFile trim 0.0 $lastSilenceLen

# target kaust, kuhu tulemus pannakse

dest=target
rm -Rf $dest
mkdir $dest

from=1
to=250

for i in `seq $from $to`
do
	echo $i
	# tekita märksõnadest sama sample rate'ga failid

	keyword_jp="keyword_jp/RTK1_keyword_jp_$i.mp3"
	keyword_en="keyword_en/RTK1_keyword_en_$i.mp3"

	tmp_keyword_jp="tmp/jp/RTK1_keyword_jp_$i.mp3"
	tmp_keyword_en="tmp/en/RTK1_keyword_en_$i.mp3"

	if [ -f $keyword_jp ]; then
		sox $keyword_jp -r 44100 $tmp_keyword_jp rate
	fi

	sox $keyword_en -r 44100 $tmp_keyword_en rate

	destFile="$dest/RTK1_keyword_pair_$i.mp3"

	if [ -f $tmp_keyword_jp ]; then
		sox $tmp_keyword_en $enjpSilenceFile $tmp_keyword_jp $lastSilenceFile $destFile
	else	
		sox $tmp_keyword_en $lastSilenceFile $destFile
	fi

	kbl="/home/scylla/projects/rtk1_with_media/kanji-by-line.txt"
	kanji=`sed "$i q;d" $kbl`

	id3tool -t $kanji -a "" -r "" -y "" -c $i $destFile

done

# enda järelt koristamine

rm -Rf tmp