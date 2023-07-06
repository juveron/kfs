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
.skip 16384 ; 16 KiB
stack_top:

.section .text
.global _start
.type _start, @function
_start:
    ; Set up the stack pointer
    mov $stack_top, %esp

    ; Call kernel_main
    call kernel_main

    ; Print the GDT
    call print_gdt

    ; Loop and halt
    cli
1:
    hlt
    jmp 1b

.size _start, . - _start

.section .text
kernel_main:
    ; Your kernel code goes here

    ; Declare the GDT to the BIOS at address 0x00000800
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
    db 0x00   ;Base (8-bit)

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size of GDT
    dd gdt_start              ; Base address of GDT

    ; Declare the GDT to the BIOS at address 0x00000800
    .section .bios_gdt, "awx", @progbits
    .align 8
    .long 0x00000800
    .short 0x0000
    .short 0xFFFF

    ; Fill the remaining bytes with zeros until 0x00000800
    .section .bios_padding, "awx", @nobits
    .align 1
    .skip 2048 - ($ - $$)

.section .text
print_gdt:
    pusha              ; Save registers

    mov $gdt_start, %eax
    mov $0, %ecx       ; Counter

    print_gdt_entry:
        mov (%eax), %ebx   ; Read entry address

        ; Print the GDT entry
        mov $8, %edx       ; Number of characters to print
        mov $16, %ebx      ; Base address
        xor %ecx, %ecx     ; Counter

    print_gdt_entry_loop:
        shr $4, %ebx       ; Shift right 4 bits
        movzbl (%ebx), %eax ; Zero-extend and move into EAX
        and $0xF, %eax     ; Mask with 0xF to get the lower 4 bits
        add $0x30, %al     ; Convert to ASCII
        cmp $0x3A, %al     ; Check if the character is ':' (colon)
        jbe print_gdt_entry_char
        add $7, %al        ; Adjust ASCII character for letters A-F

    print_gdt_entry_char:
        mov %al, (%ecx)   ; Store character in memory
        inc %ecx          ; Increment counter
        dec %edx          ; Decrement remaining characters
        jnz print_gdt_entry_loop

        ; Print newline
        mov $0xA, %al
        mov %al, (%ecx)
        inc %ecx

        add $4, %eax     ; Move to the next entry
        add $8, %eax     ; Each entry is 8 bytes long
        inc %ebx         ; Increment GDT entry pointer
        loop print_gdt_entry

    ; Print the GDT string
    mov $16 * 8 + 1, %edx   ; Size of GDT * 8 + 1 for newline character
    mov $0x09, %ah         ; BIOS function to print string
    mov %ecx, %ecx         ; Pointer to the GDT string
    int $0x10

    popa               ; Restore registers
    ret                ; Return from the function
