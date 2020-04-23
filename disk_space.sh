#!/bin/bash

timestamp=$(date "+%Y-%m-%d  -  %H.%M.%S")
df -H | grep '^storage_device_name' | awk '{ print $5 " " $6 " " $2 }' | while IFS= read -r output; do
  used_space=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo "$output" | awk '{ print $2 }' )
  max_size=$(echo "$output" | awk '{ print $3 }' )
  if [ "$used_space" -ge 85 ]; then
      echo "Running out of space on qnap_h22, total space of $partition is $max_size, used space $used_space% as of $timestamp" | mail -s "Alert: Almost out of disk capacity $used_space% used" email.to@bfi.org.uk
  fi
done
