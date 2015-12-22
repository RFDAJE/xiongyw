#!/bin/bash

# suppose odd/even pages are in "./odd/" and "./even/" folders respectively

pages=36 # total page number, customize it

mkdir all # for page both odd and even pages

count=1  # for odd pages
for f in $(ls odd/*.jpg|sort); do
    cp $f all/$count.jpg
    ((count+=2))
done

count=$pages # for even pages
for f in $(ls even/*.jpg|sort); do
    cp $f all/$count.jpg
    ((count-=2))
done
