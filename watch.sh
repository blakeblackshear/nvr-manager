#!/bin/bash

check_file (){
    /usr/local/bin/ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1;
}

archive_file (){
    # grab the first 12 digits from the filename
    local date_string=$(echo "$1" |grep -Eo '[[:digit:]]{12}')
    # format them for folder archives ex: 2018/05/28
    local date_folders=$(date -d "$date_string" +'%Y/%m/%d/%H')
    # make sure the folders exist
    mkdir -p "${MONITORDIR}/${date_folders}"

    mv $1 "${MONITORDIR}/${date_folders}/"
}

check_and_archive_file (){
    # test the file for errors
    if check_file "$1"; then
        # archive the good files
        archive_file "$1"
    else
        # delete the bad ones
        rm "$1"
    fi
}

check_existing_files (){
    touch /data/dummy
    sleep 1
    find "${MONITORDIR}" -maxdepth 1 -type f -name "*.mp4" ! -newer /data/dummy | while read file; do check_and_archive_file "$file"; done
}

# run ffprobe on all files in the directory that havent been modified in 1 second
check_existing_files
# run it again in case a new file was created in the meantime
check_existing_files

# look for files that are finished writing
inotifywait -m "${MONITORDIR}" -e close_write  | while read path action file
do
    # just look for .mp4 files
    if [[ $file = *.mp4 ]]; then
        check_and_archive_file "${MONITORDIR}/${file}"
    fi
done