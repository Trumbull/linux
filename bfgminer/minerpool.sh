#!/bin/bash
export TERMINFO=/usr/share/terminfo
export TERM=xterm-basic
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./.libs/
./bfgminer -o stratum+tcp://mgd.vvpool.com:5630 -u MGuBuTuGsHtdf6W91u78Dgz7CDSV5TTgBe -p x -S opencl:auto --api-listen --api-network --eexit 1 

