.set ALIGN,    1<<0 
.set MEMINFO,  1<<1 
.set FLAGS,    ALIGN | MEMINFO 
.set MAGIC,    0x1BADB002 
.set CHECKSUM, -(MAGIC + FLAGS) 
  
.section .multiboot 
.align 4 
.long MAGIC 
.long FLAGS 
.long CHECKSUM 
  
.section .bss 
.align 16 
stack_bottom: 
.skip 16384 # 16 KiB 
stack_top: 
  
.section .data
.align 4
gdt_start:
    .quad 0x0  # Descriptor nul
    .quad 0x00CF9A000000FFFF  # Descripteur de code
    .quad 0x00CF92000000FFFF  # Descripteur de données
gdt_end:

.section .data
gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

.section .text 
.global _start 
.type _start, @function 
_start: 
    mov $stack_top, %esp

    lgdt gdt_descriptor

    call kernel_main 

    cli 
1: 
    hlt 
    jmp 1b 

.size _start, . - _start