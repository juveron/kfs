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

    ; Set up the stack pointer
    mov $stack_top, %esp
  
    ; Call kernel_main
    call kernel_main
  
    cli 
1:  
    hlt 
    jmp 1b 
  
  
.size _start, . - _start

.section .text
kernel_main:
    ; Your kernel code goes here

    ; Declare the GDT
    .section .gdt, "awx", @nobits
    .align 4
gdt_start:
    ; Null segment
    dd 0
    dd 0

    ; Kernel Code segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x9A   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

    ; Kernel Data segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x92   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

    ; Kernel Stack segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x92   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

    ; User Code segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x9A   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

    ; User Data segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x92   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

    ; User Stack segment
    dw 0xFFFF ; Limit (16-bit)
    dw 0x0000 ; Base (16-bit)
    db 0x00   ; Base (8-bit)
    db 0x92   ; Access byte
    db 0xCF   ; Granularity byte
    db 0x00   ; Base (8-bit)

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size of GDT
    dd gdt_start              ; Base address of GDT

    ; Declare the GDT to the BIOS
    .section .bios_gdt, "awx", @progbits
    .align 8
    .long 0x00000800
    .short 0x0000
    .short 0xFFFF

    ; Fill the remaining bytes with zeros until 0x00000800
    .section .bios_padding, "awx", @nobits
    .align 1
    .skip 2048 - ($ - $$)