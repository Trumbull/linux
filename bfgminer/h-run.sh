#!/usr/bin/env bash

[ -t 1 ] && . colors

. h-manifest.conf
#CPU_INFO=`lscpu`
CPU_INFO=`cat /proc/cpuinfo | grep flags`
#echo $CPU_INFO
[[ -z $MINER_LOG_BASENAME ]] && echo -e "${RED}No MINER_LOG_BASENAME is set${NOCOLOR}" && exit 1
[[ -z $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}No CUSTOM_CONFIG_FILENAME is set${NOCOLOR}" && exit 1
[[ ! -f $CUSTOM_CONFIG_FILENAME ]] && echo -e "${RED}Custom config ${YELLOW}$CUSTOM_CONFIG_FILENAME${RED} is not found${NOCOLOR}" && exit 1
MINER_LOG_BASENAME=`dirname "$MINER_LOG_BASENAME"`
[[ ! -d $MINER_LOG_BASENAME ]] && mkdir -p $MINER_LOG_BASENAME
#echo export TERMINFO=/usr/share/terminfo
#echo export TERM=xterm+256color
#export TERMINFO=/usr/share/terminfo
#export TERM=
#export DISPLAY=:0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/hive/miners/custom/bfgminer/.libs/
script -c "./bfgminer $(< $MINER_NAME.conf)" $@ 2>&1 | tee /var/log/miner/bfgminer/bfgminer.log
