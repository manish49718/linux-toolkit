#!/bin/bash


source ~/toolkit/common.sh

#measure
cpu=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')
mem=$(free | awk '/Mem:/ {print int($3/$2*100)}')
disk=$(df / | awk 'NR==2 {print $5}' | tr -d '%')


if [ "$cpu" -ge "$CPU_LIMIT" ]; then 
  log WARN "CPU is high: $cpu%"
else
  log Info "cpu is workin fine: $cpu%"
fi

if [ "$mem" -ge "$MEM_LIMIT" ]; then
  log WARN "MEM is hish: $mem%"
else 
  log INFO "MEM is working fine: $mem%"
fi

if [ "$disk" -ge "$DISK_LIMIT" ]; then
  log WARN "Disk is full: $disk"
else 
  log INFO "Disk is fine: $disk"
fi  
