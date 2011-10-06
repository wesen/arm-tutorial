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

  .fini : {
   KEEP (*(.fini))
  } >ram

  _etext = .;
  .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >ram

  __exidx_start = .;
  .ARM.exidx : { *(.ARM.exidx* .gnu.linkonce.armexidx.*) } >ram
  __exidx_end = .;

  .ctors          :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  } >ram

  .dtors          :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
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

  .ARM.attributes 0 : { KEEP (*(.ARM.attributes)) KEEP (*(.gnu.attributes)) } >ram
}

end = . ;
_end = . ;
