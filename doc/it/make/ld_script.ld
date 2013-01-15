


ENTRY(_start)

 OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm",
     "elf32-littlearm")



OUTPUT_ARCH(arm)

MEMORY
{
    img_sdram : ORIGIN = ((((0x00000000)+0x400000))), LENGTH = (0x600000)
}


SECTIONS
{
 __code_start = ((((0x00000000)+0x400000)));
 .text ((((0x00000000)+0x400000))) :
 {
   _ld_text_start = .;
      *(.avlboot)
 *(.text)
 *(.text.*)
 *(.vfp*)
   _ld_text_end = .;
 } > img_sdram
    __exidx_start = .;

    .ARM.exidx :
    {
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } >img_sdram
    __exidx_end = .;

 . = ALIGN(4);
 .ctors :
        {
           __init_array_start = .;
           KEEP(*(.ctors))
           KEEP(*(.init_array))
           __init_array_end = .;
        } > img_sdram

 . = ALIGN(4);
 .initcall :
        {
           __init_call_start = .;
          KEEP(*(.initcall0.init))
          KEEP(*(.initcall1.init))
          KEEP(*(.initcall2.init))
          KEEP(*(.initcall3.init))
          KEEP(*(.initcall4.init))
          KEEP(*(.initcall5.init))
          KEEP(*(.initcall6.init))
           __init_call_end = .;
        } > img_sdram

 . = ALIGN(4);
 .exitcall :
        {
           __exit_call_start = .;
           KEEP(*(.exitcall6.exit))
           KEEP(*(.exitcall5.exit))
           KEEP(*(.exitcall4.exit))
           KEEP(*(.exitcall3.exit))
           KEEP(*(.exitcall2.exit))
           KEEP(*(.exitcall1.exit))
           KEEP(*(.exitcall0.exit))
           __exit_call_end = .;
        } > img_sdram

 . = ALIGN(4);
 _ld_data_start = .;
 .rodata : { *(.rodata) *(.rodata.*)} > img_sdram

 . = ALIGN(4);
 .data : { *(.data) *(.data.*)} > img_sdram

 . = ALIGN(4);
 .sdata : { *(.sdata) *(.sdata.*)} > img_sdram

 _gp = ALIGN(16);

 __got_start = .;
 .got : { *(.got) } > img_sdram
        .gotplt : { *(.got.*) } > img_sdram
 __got_end = .;
       .plt : { *(.plt) *(.plt.*)} > img_sdram

  _ld_data_end = .;
 . = ALIGN(4);
 .mmudata : { *(.mmudata) *(.mmudata.*)} > img_sdram
 . = ALIGN(4);
  _ld_bss_start = .;
     __bss_start = .;
 .sbss : { *(.sbss) *(.sbss.*)} > img_sdram
 .bss : { *(.bss) *(.COMMON) } > img_sdram
 .wild : { *(.bss.*)} > img_sdram
  _ld_bss_end = .;
     __bss_end = .;
 _end = .;



 __code_end = .;

 _ld_bss_size = SIZEOF(.bss) + SIZEOF(.sbss) + SIZEOF(.wild);
  _ld_stack_address = _ld_text_start + 0x40000;

}
