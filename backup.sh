#!/bin/bash

source ~/toolkit/common.sh
mkdir -p "$BACKUP_TO"
if [ $? -gt 0 ]; then
	exit 1
fi

<<readme  
this is a backup script for important files and logs
readme

if [ ! -d $BACKUP_FROM ]; then
	log ERROR "folder $BACKUP_FROM file not found"
	exit 1
fi

file="$BACKUP_TO/backup_$(date +%Y-%m-%d_%H%M%S).tar.gz"

tar -czf "$file" "$BACKUP_FROM".tar.gz 2>/dev/null
log INFO "Backup created: $file"

find $BACKUP_TO -name "backup_*.tar.gz" -mtime +$KEEP_DAYS -delete
log INFO "Deleted folder longer than $KEEP_DAYS days"

