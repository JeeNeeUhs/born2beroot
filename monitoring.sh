#!/bin/bash

sys_info=$(uname -a)
cpu_phys=$(grep -c 'physical id' /proc/cpuinfo)
cpu_virt=$(grep -c 'processor' /proc/cpuinfo)
mem_info=$(free --mega | awk '/^Mem/ {printf "%s/%sMB (%.2f%%)", $3, $2, $3*100/$2}')
disk_total_gb=$(df --block-size=GB | grep '^/dev' | awk '{sum += $2} END {print sum}')
disk_used_mb=$(df --block-size=MB | grep '^/dev' | awk '{sum += $3} END {print sum}')
disk_used_pct=$(df | grep '^/dev' | awk '{i++; sum += $5} END {printf "%.2f%%", sum/i}')
cpu_load=$(top -bn 1 | awk -F, 'NR==3 {printf "%.1f%%", 100 - $4}')
boot_time=$(who -b | awk '{print $3, $4}')
lvm_exists=$(lsblk | grep -c 'lvm')
lvm_status=$(if [ $lvm_exists -gt 0 ]; then echo "yes"; else echo "no"; fi)
tcp_connections=$(ss -t | grep -c 'ESTAB')
user_sessions=$(users | tr ' ' '\n' | sort | uniq | wc -l)
network_info="IP: $(hostname -I) (MAC: $(ip address | grep 'ether' | awk 'NR==1 {print $2}'))"
sudo_cmd_count=$(journalctl | grep -c 'sudo.*COMMAND')

wall "\
 #Architecture: $sys_info
 #CPU physical: $cpu_phys
 #vCPU: $cpu_virt
 #Memory Usage: $mem_info
 #Disk Usage: $disk_used_mb/$disk_total_gb GB ($disk_used_pct)
 #CPU load: $cpu_load
 #Last boot: $boot_time
 #LVM use: $lvm_status
 #Connections TCP: $tcp_connections
 #User log: $user_sessions
 #Network: $network_info
 #Sudo commands: $sudo_cmd_count"
