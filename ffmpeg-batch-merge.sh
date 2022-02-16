#!/bin/sh
# Accepts directory, loop through directory, merge files in each subdirectory

batch_path=`readlink -f "$1"`

for dir in "${batch_path}"/*
do
    if [ -d $dir ]
    then
        ffmpeg-merge "$dir"
    fi
done
