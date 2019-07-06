#!/usr/bin/env bash

#######################
# Functions
#######################


get_cards_hashes(){
        # hs is global
        hs=''
	for (( i=0; i < ${GPU_COUNT_NVIDIA}; i++ )); do	
        local  MHS=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1| awk {'print $1'}|cut -b 3-10`		
        local t=0
        t=`echo $MHS | awk {'print int($1+0.5)'}`
        local p=0
        let p=$t/$GPU_COUNT_NVIDIA
        hs[$i]=`echo $p`
	done
}

get_cards_hashes_1(){
        # hs is global
        hs=''
	for (( i=0; i < ${GPU_COUNT_NVIDIA}; i++ )); do	
        local  MHS=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1| awk {'print $2'}`		
        local t=0
        t=`echo $MHS | awk {'print int($1+0.5)'}`
        local p=0
        let p=$t/$GPU_COUNT_NVIDIA
        hs[$i]=`echo $p`
	done
}


get_nvidia_cards_temp(){
        echo $(jq -c "[.temp$nvidia_indexes_array]" <<< $gpu_stats)
}

get_nvidia_cards_fan(){
        echo $(jq -c "[.fan$nvidia_indexes_array]" <<< $gpu_stats)
}

get_miner_uptime(){
        local tmp=$(cat $DATE | head -n 1 | awk '{print}')
        local start=$(date +%s -d "$tmp")
        local now=$(date +%s)
        echo $((now - start))
}

get_total_hashes(){
        # khs is global
 	
	 local Total=`cat $LOG_NAME | tail -n 3 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1| awk {'print $1'} |cut -b 3-10| awk {'print int(($1+0.5)*1000)'}`
	  echo $Total
}

get_log_time_diff(){
        local getLastLogTime=`tail -n 100 $LOG_NAME | tail -n 1 | awk {'print $1'} | cut -b 11-18`
        local logTime=`date --date="$getLastLogTime" +%s`
        local curTime=`date +%s`
        echo `expr $curTime - $logTime`
}

#######################
# MAIN script body
#######################

. /hive/miners/custom/bfgminer/h-manifest.conf

LOG_NAME="/var/log/miner/bfgminer/bfgminer.log"
DATE="$CUSTOM_LOG_BASENAME.date.log"
gpu_stats_json="/run/hive/gpu-stats.json"
nvidia_indexes_array=`echo /run/hive/gpu-stats.json | jq -r '[ . | to_entries[] | select(.value.brand =="nvidia") | .key]'`
[[ -z $GPU_COUNT_NVIDIA ]] &&
        GPU_COUNT_NVIDIA=`gpu-detect NVIDIA`



# Calc log freshness
#local diffTime=$(get_log_time_diff)
#local maxDelay=120

# echo $diffTime

# If log is fresh the calc miner stats or set to null if not
test_hash=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1| awk {'print $1'}|cut -b 3-10| awk {'print int($1+0.5)'}`
if [ "$test_hash" -gt 9 ]; then 
hs=
get_cards_hashes
khs=$(get_total_hashes)

# hashes array
       hs_units='Mhs'                             # hashes utits
       temp=`cat $gpu_stats_json | jq -c ".temp"`     # cards temp
       fan=`cat $gpu_stats_json |jq -c ".fan"`               # cards fan
        uptime=10        # miner uptime
        # algo=$(cat $LOG_NAME | head -n 20 | grep -a "add" | awk '{printf $4"\n"}')                 # 
       algo="x13"

        # A/R shares by pool
        ac=`cat $LOG_NAME |tail -n 3|  grep -o "A.* R" $LOG_NAME | tail -n 1| awk {'print $1'} | cut -b 3-10`
        rj=`cat $LOG_NAME |tail -n 3|  grep -o "R:." $LOG_NAME | tail -n 1|cut -b 3-10`
       Test=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1|awk {'print $1'}| cut -b 3-10`
# | cut -b 3-10` 
        # make JSON
        stats=$(jq -nc \
                                --argjson hs "`echo ${hs[@]} | tr " " "\n" | jq -cs '.'`" \
                                --arg hs_units "$hs_units" \
                                --argjson temp "$temp" \
                                --argjson fan "$fan" \
                                --arg uptime "$uptime" \
                                --arg ac "$ac" --arg rj "$rj" \
                                --arg algo "$algo" \
                                '{$hs, $hs_units, $temp, $fan, $uptime, ar: [$ac, $rj], $algo}')
else        
hs=
get_cards_hashes_1
khs=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1| awk {'print $2*1000'}`

# hashes array
       hs_units='Mhs'                             # hashes utits
       temp=`cat $gpu_stats_json | jq -c ".temp"`     # cards temp
       fan=`cat $gpu_stats_json |jq -c ".fan"`               # cards fan
        uptime=10        # miner uptime
        # algo=$(cat $LOG_NAME | head -n 20 | grep -a "add" | awk '{printf $4"\n"}')                 # 
       algo="x13"

        # A/R shares by pool
        ac=`cat $LOG_NAME |tail -n 3|  grep -o "A.* R" $LOG_NAME | tail -n 1| awk {'print $1'} | cut -b 3-10`
        rj=`cat $LOG_NAME |tail -n 3|  grep -o "R:." $LOG_NAME | tail -n 1|cut -b 3-10`
       Test=`cat $LOG_NAME|tail -n 5 |  grep -o "u.* Mh/s" $LOG_NAME | tail -n 1|awk {'print $1'}| cut -b 3-10`
# | cut -b 3-10` 
        # make JSON
        stats=$(jq -nc \
                                --argjson hs "`echo ${hs[@]} | tr " " "\n" | jq -cs '.'`" \
                                --arg hs_units "$hs_units" \
                                --argjson temp "$temp" \
                                --argjson fan "$fan" \
                                --arg uptime "$uptime" \
                                --arg ac "$ac" --arg rj "$rj" \
                                --arg algo "$algo" \
                                '{$hs, $hs_units, $temp, $fan, $uptime, ar: [$ac, $rj], $algo}')
fi

# debug output
#echo Test: $Test
##echo temp:  $temp
##echo fan:   $fan
echo stats: $stats
echo khs:   $khs
