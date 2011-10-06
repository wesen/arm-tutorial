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
  end = . ;
  _end = . ;

  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }

  /* .ARM.attributes 0 : { KEEP (*(.ARM.attributes)) KEEP (*(.gnu.attributes)) } >ram */
}
