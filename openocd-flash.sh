#!/bin/sh

FILE=$1; shift

openocd $* -c "arm7_9 dcc_downloads enable" -c "arm7_9 fast_memory_access enable" -c init -c targets -c halt -c "flash write_image  $FILE 0x100000 bin" -c "verify_image $FILE 0x100000" -c "halt" -c "reset init" -c resume -c shutdown
