#!/bin/bash

# Variables to be changed between storage devices
dpx_path="/path_to_sequences/"
policy_path="/path_to_policy/"

rm "${dpx_path}temp_dpx_failure_list.txt"
touch "${dpx_path}temp_dpx_failure_list.txt"

# Call script command to record programme interactions 
# script -a ${policy_path}pre-rawcook_script.log

# Function to write output to log and bypass repeated echo calls.
function log {
    timestamp=$(date "+%Y-%m-%d - %H.%M.%S")
    echo "===== $1 ===== $timestamp ====="
} >> ${dpx_path}pre_rawcook.log

# Write first log output
log "++++++++++++ Pre-RAWcooked workflows start ++++++++++"

# Search for folders in dpx_to_cook that have not been modified in last 24 hours
find "${dpx_path}dpx_to_cook/" -maxdepth 3 -mindepth 3 -type d -mmin +1440 | while IFS= read -r files; do
    
    # Captures first dpx from within sequence for metadata generation specific to DPX
    dpx=$(ls "$files" | head -1)
    # Cuts to be adjusted based on specific path length. Should leave just key folder name
    filename=$(echo "${files}" | cut -c 58- | rev | cut -c 18- | rev)
    # As above but with second path information to differentiate between scan01 and scan02 variations
    file_scan_name=$(echo "$files" | cut -c 58- | rev | cut -c 11- | rev)
    # Search to see if this item has already been assessed and passed as successful
    count_queued=$(grep -c "$file_scan_name" "${dpx_path}temp_dpx_success_list.txt")

    if [ "$count_queued" -eq 0 ]
        then
            # Search for audio files (this is not accounted for in MediaConch policy)
            audio=$(find "$files" -name "*.wav" -o -name "*.aif" -o -name "*.aiff" -o -name "*.flac" | wc -l)
            if [ "$audio" -gt 0 ]
                then
                    log "AUDIO FILES FOUND IN $file_scan_name IMAGE SEQUENCE. Adding to dpx_for_review/ folder list"
                    echo "$files" >> ${dpx_path}temp_dpx_failure_list.txt
                else
                    log "No audio files found within $file_scan_name image sequence"
            fi
        
            # Output metadata and md5 to files path
            log "Metadata and fixity file creation has started for: ${files}/${dpx}"
            mediainfo -f "${files}/${dpx}" > "${files}/${filename}_${dpx}_metadata.txt"
            md5sum "${files}/${dpx}" > "${files}/${filename}_${dpx}.md5"

            # Start comparison of first dpx file against mediaconch policy - suitable to RAWcook or not?
            check=$(mediaconch --force -p ${policy_path}rawcooked_dpx_policy.xml "${files}/$dpx" | grep "fail")
            if [ -z "$check" ]
                then
                    log "PASS: $file_scan_name has passed the MediaConch policy and can progress to RAWcooked processing"
                    echo "$files" >> ${dpx_path}temp_dpx_success_list.txt
                else
                    log "FAIL: $file_scan_name DOES NOT CONFORM TO MEDIACONCH POLICY. Adding to temp_dpx_failure_list.txt"
                    log "$check"
                    echo "$files" >> ${dpx_path}temp_dpx_failure_list.txt
            fi
        else
            log "Skipping DPX folder, it has already been processed: $file_scan_name"
    fi
done

# Move failure list to dpx_for_review/ folder
log "Moving items found to have audio files, or failed MediaConch policy to dpx_for_review/ folder"
find "${dpx_path}"temp_dpx_failure_list.txt -name "*dpx_to_cook" | parallel --jobs 10 "mv {} ${dpx_path}dpx_for_review/"

# FFmpeg process moved to end, so only successful cases get cooked. Time consuming process, one parallel job at time.
log "Framemd5 manifest generation will now start for items on temp_dpx_success_list.txt"
find "${dpx_path}"temp_dpx_success_list.txt -name "$file_scan_name" | parallel --jobs 1 "ffmpeg -pattern_type glob -i {}/*.dpx -f framemd5 {}/sequence_md5.framemd5"

# End of process
log "********** Pre-RAWcooked worfklows end **********"
