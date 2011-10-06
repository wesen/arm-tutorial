/*
 * # linker script for ARM tutorial #
 *
 */

/*
 * Usage: LDFLAGS = -Map main.map -nostartfiles -T ld-script.ld
 *
 * - first object is placed at the beginning of the text section.
 *
 */

 /**
  * stack order (starting from upper ram limit: 0x20FFFF + 1 - 4 = 0x20FFFC
  *
  * UDF stack : 16 bytes
  * ABT stack : 16 bytes
  * FIQ stack : 128 bytes
  * IRQ stack : 128 bytes
  * SVC stack : 16 bytes
  * user program
  *
  */

ENTRY (_vec_reset)

/**
 * memory areas
 *
 * Flash starts at 0x000000
 * RAM starts at 0x200000
 **/
MEMORY {
  flash : ORIGIN = 0, LENGTH = 256K
  ram : ORIGIN = 0x00200000, LENGTH = 64K
}

_stack_end = 0x20FFFC;

SECTIONS {
  . = 0;

  .text : {
     *(.text)
     *(.rodata)
     *(.rodata*)
     *(.glue_7)
     *(.glue_7t)

     _etext = .;
  } >ram

  .data : {
     _data = .;

     *(.data)
     _edata = .;
  } >ram /* put all in RAM, but LMA initializer copy into FLASH */

  .bss : {
     _bss_start = .;
     *(.bss)
  } >ram

  . = ALIGN(4);
  _bss_end = . ;
}

_end = . ;
