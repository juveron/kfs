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

# Définition des segments
.global gdt_start
gdt_start:
    # Descripteur de segment null
    .quad 0x0
    .quad 0x0

    # Descripteur de code du kernel
    .quad 0x00CF9A000000FFFF
    .quad 0x0

    # Descripteur de data du kernel
    .quad 0x00CF92000000FFFF
    .quad 0x0

    # Descripteur de stack du kernel
    .quad 0x00CFFA000000FFFF
    .quad 0x0

    # Descripteur de code user
    .quad 0x00CFF2000000FFFF
    .quad 0x0

    # Descripteur de data user
    .quad 0x00CFF0000000FFFF
    .quad 0x0

    # Descripteur de stack user
    .quad 0x00CFFE000000FFFF
    .quad 0x0

.global gdt_end
gdt_end:

.section .data
gdt_descriptor:
    .word gdt_end - gdt_start - 1
    .long gdt_start

.global load_gdt
load_gdt:
    lgdt (%eax)
    ret

.section .text 
.global _start 
.type _start, @function 
_start: 
    mov $stack_top, %esp

    # Chargez la GDT
    lgdt gdt_descriptor

    call kernel_main 

    cli 
1: 
    hlt 
    jmp 1b 

.size _start, . - _start