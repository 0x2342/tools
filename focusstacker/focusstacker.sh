#!/bin/sh
#
# inspired by https://foto.schwedenstuhl.de/?page=stacking
#
# 2018-07-21 MM
#

TARGETBASENAME=$1
NUMARGS=$#
SOURCEFILES=""
for i in $@
do 
	if [ "$i" !=  "$1" ] 
	then
		SOURCEFILES="$SOURCEFILES $i"
	fi
done
echo "Target base name: $TARGETBASENAME"
echo "Source files: $SOURCEFILES"

align_image_stack -v -m -a $TARGETBASENAME $SOURCEFILES

enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 --hard-mask --contrast-window-size=9 --output=$TARGETBASENAME-stacked.tif $TARGETBASENAME*.tif

#exiftool -TagsFromFile $2 $TARGETBASENAME_Stacked.tif
