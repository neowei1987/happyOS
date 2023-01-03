%include "sconst.inc"

_NR_get_ticks equ 0 
_NR_write equ 1

INT_VECTOR_SYS_CALL equ 0x90

global get_ticks 
global write 

bits 32 
[section .text]

get_ticks:
    mov eax, _NR_get_ticks
    int INT_VECTOR_SYS_CALL
    ret

write:
    mov eax, _NR_write
    mov ebx, [esp + 4] ; fd
    mov ecx, [esp + 8] ; buf
    mov edx, [esp + 12]; len
    int INT_VECTOR_SYS_CALL
    ret