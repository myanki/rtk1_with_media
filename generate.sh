#!/usr/bin/env bash

# Usage

## 1-250 video
#bash generate.sh --from-heisig=1 --to-heisig=250 --video=false --jp-keyword=true --silence-prefix=0.7 --silence-between-words=0.5 --silence-suffix=10.0

dir=`pwd`

# Parse input parameters

for i in "$@"
do
case $i in

    -fh=*|--from-heisig=*)
    fromHeisig="${i#*=}"
    ;;

    -th=*|--to-heisig=*)
    toHeisig="${i#*=}"
    ;;

    -v=*|--video=*)
    isVideo="${i#*=}"
    ;;

    -jpkw=*|--jp-keyword=*)
    isJpKeyword="${i#*=}"
    ;;

    -sp=*|--silence-prefix=*)
    silencePrefix="${i#*=}"
    ;;

    -sbw=*|--silence-between-words=*)
    silenceBetweenWords="${i#*=}"
    ;;

    -ss=*|--silence-suffix=*)
    silenceSuffix="${i#*=}"
    ;;

    --default)
        # default value
    ;;
    *)
        # unknown option
    ;;
esac
done

# ajutiste failide asukoht

cachePath=/tmp/rtk_cache
rm -Rf $cachePath
mkdir $cachePath
mkdir $cachePath/en
mkdir $cachePath/jp

rm -Rf target
mkdir target
audioTargetPath=target/audio
mkdir $audioTargetPath
videoTargetPath=target/video
mkdir $videoTargetPath

whereIsKanji() {
    k=${1#0}

    if (($k >= 1)) && (($k <= 250)); then
		echo "RTK1_1-250"
	elif (($k >= 251)) && (($k <= 500)); then
		echo "RTK1_251-500"
	elif (($k >= 501)) && (($k <= 750)); then
		echo "RTK1_501-750"
	elif (($k >= 751)) && (($k <= 1000)); then
		echo "RTK1_751-1000"
	elif (($k >= 1001)) && (($k <= 1250)); then
		echo "RTK1_1001-1250"
	elif (($k >= 1251)) && (($k <= 1500)); then
		echo "RTK1_1251-1500"
	elif (($k >= 1501)) && (($k <= 1750)); then
		echo "RTK1_1501-1750"
	elif (($k >= 2001)) && (($k <= 2200)); then
		echo "RTK1_2001-2200"
	else
		raise :"Kanji not found $i"
	fi
}

# vaikusefailide loomine

silencePrefixFile=$cachePath/silencePrefixFile.mp3
silenceBetweenWordsFile=$cachePath/silenceBetweenWordsFile.mp3
silenceSuffixFile=$cachePath/silenceSuffixFile.mp3

sox -n -r 44100 -c 1 $silencePrefixFile trim 0.0 $silencePrefix
sox -n -r 44100 -c 1 $silenceBetweenWordsFile trim 0.0 $silenceBetweenWords
sox -n -r 44100 -c 1 $silenceSuffixFile trim 0.0 $silenceSuffix

# audiofailide loomine

for i in `seq $fromHeisig $toHeisig`
do
	# tekita märksõnadest sama sample rate'ga failid

	kanjiPath=$(whereIsKanji $i)
    echo "Create audio for: $i in $kanjiPath"

	keyword_jp="$kanjiPath/keyword_jp/RTK1_keyword_jp_$i.mp3"
	keyword_en="$kanjiPath/keyword_en/RTK1_keyword_en_$i.mp3"

	tmp_keyword_jp="$cachePath/jp/RTK1_keyword_jp_$i.mp3"
	tmp_keyword_en="$cachePath/en/RTK1_keyword_en_$i.mp3"

	if [ -f $keyword_jp ]; then
		sox $keyword_jp -r 44100 $tmp_keyword_jp rate
	fi

	sox $keyword_en -r 44100 $tmp_keyword_en rate

	destFile="$audioTargetPath/RTK1_keyword_pair_$i.mp3"

	if [ $isJpKeyword == "true" ] && [ -f $tmp_keyword_jp ]; then
		sox $silencePrefixFile $tmp_keyword_en $silenceBetweenWordsFile $tmp_keyword_jp $silenceSuffixFile $destFile
	else	
		sox $silencePrefixFile $tmp_keyword_en $silenceSuffixFile $destFile
	fi

	kbl="kanji-by-line.txt"
	kanji=`sed "$i q;d" $kbl`

	# audio metadata, tiitliks kanji
    echo "Audio $i will have title $kanji"

	id3tool -t $kanji -a "" -r "" -y "" -c $i $destFile

done


# videofailide loomine

if [ $isVideo = "true" ]; then
	for i in `seq $fromHeisig $toHeisig`
	do
		fflog="$cachePath/ffmpeg-image-and-audio.log"
		echo "Create video for $i. Tail log file - $fflog"
		ffmpeg -loop 1 -i "svg-to-png-grey-bg/$i.png" -i "$audioTargetPath/RTK1_keyword_pair_$i.mp3" -shortest -acodec copy "$videoTargetPath/RTK1_keyword_pair_$i.mp4" &> $fflog
		echo "file '$dir/$videoTargetPath/RTK1_keyword_pair_$i.mp4'" >> "$cachePath/videos.txt"
	done

	# ühe pika video loomine
	echo "Create video playlist"

	ffmpeg -f concat -i "$cachePath/videos.txt" -c copy "target/video_playlist.mp4"
fi