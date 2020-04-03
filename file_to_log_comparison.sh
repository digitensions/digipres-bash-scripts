#!/bin/bash
 
# Variables for script, so it's easy to relocate
log_path="/mnt/isilon_lt2/"
timestamp=$(date "+%Y-%m-%d  -  %H.%M.%S")
dpx_list="/mnt/isilon_lt2/dpx_cooked/"
global_log="/mnt/qnap_h22/lto_project/global_copy.log"
 
# Create list ordered by the extensions _01of*
ls "$dpx_list" | sort -n -k1.10 > ${log_path}temp_dpx_list.txt
 
# Begin with writing start time to log
echo "====== $timestamp ====== Comparing dpx_cooked folder to global.log ======" >> ${log_path}global_log_check.log
 
# Search within txt file for N_ numbers, passed to $files variable in while loop
grep ^N ${log_path}temp_dpx_list.txt | while IFS= read -r files; do
 # Comparison of $files list against the global log, stored in variable $on_global
 on_global=$(grep "$files" "$global_log" | grep 'deleted')
 # if $on_global returns no string (ie, has no 'deleted' entry / any entry in global log)
 if [ -z "$on_global" ]
   then
     echo "****** ${files}.mkv has not passed into autoingest ******" >> ${log_path}global_log_check.log
   # else, if it has an entry for both titled, and 'deleted'
   else
     echo "====== ${files}.mkv has been RAWcooked and is in Imagen ======" >> ${log_path}global_log_check.log
  fi
done
