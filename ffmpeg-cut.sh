#!/bin/sh
# Cuts videos based on frames, takes vid filename and a file with a list of times

filename=`readlink -f "$1"`
cut_times=`readlink -f "$2"`
unformatted_fps=`ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate "$filename"`
vid_fps=`perl -l -e "print(${unformatted_fps})"`
shortname=`echo "${filename##/*/}" | sed 's|\(.*\)\(\..*\)|\1|'`
extension=`echo "${filename##/*/}" | sed 's|.*\(\..*\)|\1|'`

# convert() will take fps and a timestamp, find the nearest frame and return time to cut in seconds
convert () {
    fps="$1"
    timestamp="$2"
    read -r h m s <<< $(echo "${timestamp}" | sed 's/\([0-9][0-9]\):\([0-9][0-9]\):\([0-9][0-9]\)/\1 \2 \3/')
    ttl_seconds=`echo "${s} + (60 * ${m}) + (3600 * ${h})" | bc`	# perl doesn't like leading zeroes, so just used the lazy option,bc
    frame=`perl -l -e "printf('%1.0f', ${ttl_seconds} * ${fps})"`  # Round value to nearest frame
    perl -l -e "print(${frame} / ${fps})"   # return precise decimal value
}

# Loop through time tuples and create videos
create_vids() {
    count=1
    while IFS='' read -r line || [ "$line" ]
    do
        read -r t0 t1 <<< $(echo "${line}" | sed 's/\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\)-\([0-9][0-9]:[0-9][0-9]:[0-9][0-9]\)/\1 \2/')
        inpoint=`convert "$vid_fps" "$t0"`
        outpoint=`convert "$vid_fps" "$t1"`
        ffmpeg -i "$filename" -ss "$inpoint" -to "$outpoint" -c copy "${shortname}${count}${extension}" < /dev/null
        count=$((count+1))
    done < "$cut_times"
}

create_vids
