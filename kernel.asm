;nasm -f elf kernel.asm -o kernel.o  
; ld
[section .text]

global _start

_start: 
    mov ah, 0Fh 
    mov al, 'k'
    mov [gs:((80*1 + 39) *2)], ax 
    jmp $
