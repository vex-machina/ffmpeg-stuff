#!/bin/sh
# Takes filepath, loop through folder, merge vids. ffmpeg-cut must be run first

merge_path=`readlink -f "$1"`
# We'll take an arbitrary name (in this case the first) and do some text processing, assumes a properly formatted video name
name=`ls "$merge_path" | head -n 1 | sed 's/^\([0-9]*[[:alpha:]]\{1,\}\)[0-9]\{1,\}\(\..*\)$/\1\2/'`
extension=`echo "$name" | cut -f 2 -d "."`
create_input_file() {
    for f in "${merge_path}/*.${extension}"
    do
        absolute_path=`readlink -f "$f"`
        echo "file '$absolute_path'" >> /tmp/ffmpeg.mylist
    done
}

create_input_file
ffmpeg -f concat -safe 0 -i /tmp/ffmpeg.mylist -c copy "${merge_path}/${name}"
rm /tmp/ffmpeg.mylist
