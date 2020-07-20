#!/bin/bash
 
# Script to search for MKV files modified more than 20 mins ago.
# Check the MKV against a MediaConch policy with search to return "fail" files.
# Loop that separate failed files from pass files and moves fails to 'killed' folder.
# echo outputs written to post_rawcooked.log file.
# Temporary .txt file created just to store names of failed files, deleted at end.
 
mkv_destination="/mnt/qnap/Public/rawcooked/"
 
find ${mkv_destination}mkv_cooked/ -name "*.mkv" -mmin +20 -print0 | while IFS= read -r files; do
check=$(mediaconch --force -p /mnt/isilon/rawcooked/mkv_policy.xml "$files" | grep "fail")
filename=$(basename "$files") 
  if [ -z "$check" ];
    then
      echo "*** RAWcooked MKV file $filename has passed the Mediaconch policy. Whoopee ***" >> ${mkv_destination}post_rawcooked.log
    else
      {
        echo "*** FAILED RAWcooked MKV $filename has failed the mediaconch policy. Grrrrr ***"
        echo "*** Moving $filename to killed directory, and amending log fail_${filename}.txt ***"
        echo "$check"
      } >> ${mkv_destination}post_rawcooked.log
        echo "$filename" > ${mkv_destination}temp_mediaconch_policy_fails.txt
  fi
done
 
grep ^N ${mkv_destination}temp_mediaconch_policy_fails.txt | parallel --progress --jobs 10 "mv ${mkv_destination}mkv_cooked/{} ${mkv_destination}killed/{}"
grep ^N ${mkv_destination}temp_mediaconch_policy_fails.txt | parallel --progress --jobs 10 "mv ${mkv_destination}mkv_cooked/{}.txt ${mkv_destination}logs/fail_{}.txt"
