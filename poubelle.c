i686-elf-as   -o boot.o boot.s
boot.s: Assembler messages:
boot.s:49: Error: no such instruction: `dd 0'
boot.s:50: Error: no such instruction: `dd 0'
boot.s:52: Error: no such instruction: `dw 0xFFFF'
boot.s:53: Error: no such instruction: `dw 0x0000'
boot.s:54: Error: no such instruction: `db 0x00'
boot.s:55: Error: no such instruction: `db 0x9A'
boot.s:56: Error: no such instruction: `db 0xCF'
boot.s:57: Error: no such instruction: `db 0x00'
boot.s:59: Error: no such instruction: `dw 0xFFFF'
boot.s:60: Error: no such instruction: `dw 0x0000'
boot.s:61: Error: no such instruction: `db 0x00'
boot.s:62: Error: no such instruction: `db 0x92'
boot.s:63: Error: no such instruction: `db 0xCF'
boot.s:64: Error: no such instruction: `db 0x00'
boot.s:66: Error: no such instruction: `dw 0xFFFF'
boot.s:67: Error: no such instruction: `dw 0x0000'
boot.s:68: Error: no such instruction: `db 0x00'
boot.s:69: Error: no such instruction: `db 0x92'
boot.s:70: Error: no such instruction: `db 0xCF'
boot.s:71: Error: no such instruction: `db 0x00'
boot.s:72: Error: no such instruction: `dw 0xFFFF'
boot.s:73: Error: no such instruction: `dw 0x0000'
boot.s:74: Error: no such instruction: `db 0x00'
boot.s:75: Error: no such instruction: `db 0x9A'
boot.s:76: Error: no such instruction: `db 0xCF'
boot.s:77: Error: no such instruction: `db 0x00'
boot.s:79: Error: no such instruction: `dw 0xFFFF'
boot.s:80: Error: no such instruction: `dw 0x0000'
boot.s:81: Error: no such instruction: `db 0x00'
boot.s:82: Error: no such instruction: `db 0x92'
boot.s:83: Error: no such instruction: `db 0xCF'
boot.s:84: Error: no such instruction: `db 0x00'
boot.s:86: Error: no such instruction: `dw 0xFFFF'
boot.s:87: Error: no such instruction: `dw 0x0000'
boot.s:88: Error: no such instruction: `db 0x00'
boot.s:89: Error: no such instruction: `db 0x92'
boot.s:90: Error: no such instruction: `db 0xCF'
boot.s:91: Error: no such instruction: `db 0x00'
boot.s:95: Error: no such instruction: `dw gdt_end - gdt_start - 1'
boot.s:96: Error: no such instruction: `dd gdt_start'
boot.s:106: Error: .space, .nops or .fill specifies non-absolute value
make: *** [<builtin>: boot.o] Error 1




Je dois faire un boot.s pour mon kernel en 32 bits kernel qui inclut un gdt.

J'ai ce code mais il semble que la partie gdt comporte des instructions inconnus

A savoir que c'est de l'assembler qui doit compiler avec i686-elf

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
