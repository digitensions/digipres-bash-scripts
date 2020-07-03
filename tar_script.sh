#!/bin/bash -x

# Variables that define paths to dpx_sequence
log_path="/path/logs/"
dpx_path="/path/dpx_to_review/tar/"
destination="/path/destination/"

# Function to write output to log, bypass echo calls, using just 'log' + 'statement' to populate ${1}.
function log {
    timestamp=$(date "+%Y-%m-%d - %H.%M.%S")
    echo "$1 - $timestamp"
} >> ${dpx_path}tar_wrap_log.log

# Start TAR preparations and wrap of DPX sequences
log "********* ========== TAR wrap begins ========= *********"

find $dpx_path -maxdepth 3 -mindepth 3 -type d | while IFS= read -r tar_files;
do
    # Extract useable filenames from the path
    log "TAR WRAP BEGINNING FOR $tar_files"
    log "==================================="
    dpx=$(ls ${dpx_path}$tar_files | head -1)
    filename=$(echo $tar_files | cut -c 46- | rev | cut -c 18- | rev)
    file_scan_name=$(echo $tar_files | cut -c 46- | rev | cut -c 11- | rev)

    # Start metadata, md5sum and framemd5 manifest generation for each file in loop
    log "Generating directory list, metadata, checksum and framemd5 manifest for file $filename and placing in DPX sequence folder"
    tree ${dpx_path}${filename} > ${tar_files}/${filename}_directory_structure.txt
    mediainfo -f ${tar_files}/${dpx} > ${tar_files}/${filename}_${dpx}_metadata.txt
    md5sum ${tar_files}/${dpx} > ${tar_files}/${filename}_${dpx}.md5
    ffmpeg -nostdin -pattern_type glob -i "${tar_files}/*.dpx" -f framemd5 "${tar_files}/${filename}.framemd5" 

    # Begin tar wrap using Linux TAR module
    log "Beginning GNU tar process for file $filename using posix formatting"
    tar -cf --posix ${dpx_path}${tar_files}/${filename}.tar ${dpx_path}${tar_files}

    # Running analysis of tar file using verify setting
    tar_pass=$(tar --verify ${tar_files}.tar | grep "error" ) # this function needs testing to see what possible pass/fail messages are returned
    if [ -z $tar_pass ]
        then
            log "TAR file ${filename}.tar has passed a verify check"
            log "$tar_pass"
            # Create MD5 checksum for whole TAR file
            md5sum ${dpx_path}${tar_files}/${filename}.tar > ${dpx_path}${tar_file}/${filename}.md5
        else
            log "TAR file ${filename}.tar has NOT PASSED the verification checks"
            log "================================================================="
            rm ${dpx_path}${tar_file}/${filename}.tar
    fi
done

# Find .tar files in DPX_Path and move to autoingest, and move DPX folders to dpx_cooked leaving unsuccessful TAR attempts to try again
log "Moving successful .tar files to autoingest"
find ${dpx_path} -name "*.tar" | while IFS= read -r tars; do
    # Move .tar files to autoingest
    log "Moving $tars to $destination"
    mv ${dpx_path}${tars} ${destination}
    # Move .log files to logs/ folder
    log "Moving ${tars}.txt to $log_path"
    mv ${dpx_path}${tars}.txt ${log_path}
done

# Writing script close statement
log "********* ========== TAR wrap ended ========= *********"
