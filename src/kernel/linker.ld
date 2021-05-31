ENTRY(start)

KERNEL_OFFSET = 0xFFFFFF8000000000;
KERNEL_START = 0x100000;

SECTIONS
{
  . = KERNEL_START + KERNEL_OFFSET;

  kernel_start = .;
  
  .boot : AT(ADDR(.boot) - KERNEL_OFFSET)
  {
    KEEP(*(.multiboot_header))
  }

  .text : AT(ADDR(.text) - KERNEL_OFFSET)
  {
    *(.text)
  }

  .data : AT(ADDR(.data) - KERNEL_OFFSET)
  {
    *(.data)
  }

  .bss : AT(ADDR(.bss) - KERNEL_OFFSET)
  {
    *(COMMON)
    *(.bss)
  }

  .rodata : AT(ADDR(.rodata) - KERNEL_OFFSET)
  {
    *(.rodata*)
  }

  kernel_end = .;
}
