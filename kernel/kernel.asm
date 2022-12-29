;nasm -f elf kernel.asm -o kernel.o  
; ld

SELECTOR_KERNEL_CS	equ	8

global _start

; 导入全局变量
extern cstart 
extern	gdt_ptr

[SECTION .bss] 
StackSpace resb 2 * 1024 
StackTop:

[section .text]

_start: 
    mov esp, StackTop
    sgdt [gdt_ptr]
    call cstart 
    lgdt [gdt_ptr]

    jmp SELECTOR_KERNEL_CS:csinit
csinit:		; “这个跳转指令强制使用刚刚初始化的结构”——<<OS:D&I 2nd>> P90.
    push	0
	popfd	; Pop top of stack into EFLAGS

	hlt
  