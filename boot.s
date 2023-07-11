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
  
  
.section .text 
.global _start 
.type _start, @function 
_start: 


    mov $stack_top, %esp
  

    call kernel_main
  
    cli 
1:  
    hlt 
    jmp 1b 
  
  
.size _start, . - _start

.section .text
kernel_main:



    .section .gdt, "awx", @nobits
    .align 4
gdt_start:

    dd 0
    dd 0

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

    .section .bios_gdt, "awx", @progbits
    .align 8
    .long 0x00000800
    .short 0x0000
    .short 0xFFFF

    .section .bios_padding, "awx", @nobits
    .align 1
    .skip 2048 - ($ - $$)
    