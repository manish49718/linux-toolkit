#!/bin/bash


source ~/toolkit/config.sh

log() {
   echo "$(date '+%Y-%m-%d %H:%M:%S')	[$1] $2" >> ~/toolkit/logs/toolkit.log
    
  echo  "[$1] $2"
      }
