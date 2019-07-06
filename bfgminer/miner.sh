#!/bin/bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./.libs/
./bfgminer -o http://127.0.0.1:9442 -u mgdcoinrpc -p mgdcoinpassword --generate-to MQVtQD8DMVGoihnXueD4XQLYki1Bnzfj2B -S opencl:auto --eexit 1
