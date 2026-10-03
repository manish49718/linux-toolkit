#!/bin/bash

source ~/toolkit/common.sh

for svc in $SERVICES; do 
	if systemctl is-active --quiet "$svc"; then
	  log INFO "$svc is running"
        else
       	  log ERROR "$svc is down. Restarting..." 
  	  sudo systemctl restart "$svc"
	fi
done


