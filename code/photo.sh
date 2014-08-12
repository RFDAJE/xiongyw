#!/bin/sh

# extract the 'yyyymmdd' from the file name and create
# a folder for each day, then move the photos into
# the respective folders

# the image names on android phone are: IMG_yyyymmdd_xxxxx.jpg"

for f in *.jpg
do 
    dir=`echo "$f"|awk -F '[._]' '{print $2}'`
    echo "$f -> $dir"
    mkdir -p $dir
    mv $f $dir
done
