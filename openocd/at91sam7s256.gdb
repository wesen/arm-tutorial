target remote localhost:3333
monitor reset halt
monitor arm core_state arm
monitor mww 0xffffff60 0x00320100
monitor mww 0xfffffd44 0xa0008000
monitor mww 0xfffffc20 0xa0000601
monitor sleep 100
monitor mww 0xfffffc2c 0x00480a0e
monitor sleep 200
monitor mww 0xfffffc30 0x7
monitor sleep 100
monitor mww 0xfffffd08 0xa5000401
set remote memory-write-packet-size 1024
set remote memory-write-packet-size fixed
set remote memory-read-packet-size 1024
set remote memory-read-packet-size fixed
monitor mww 0xfffffd00 0xa5000004
monitor mww 0xffffff00 0x01
monitor reg pc 0x0000000000
monitor gdb_breakpoint_override soft
monitor arm7_9 dbgrq enable
load
