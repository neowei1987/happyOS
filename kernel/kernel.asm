;nasm -f elf kernel.asm -o kernel.o  
; ld

%include "sconst.inc"

; 导入函数
extern	cstart
extern 	happy_main
extern	exception_handler
extern	spurious_irq
extern clock_handler;

; 导入全局变量
extern	gdt_ptr
extern	idt_ptr
extern p_proc_ready 
extern tss 
extern	disp_pos
extern disp_str
extern k_reenter


bits 32

[SECTION .bss]
StackSpace		resb	2 * 1024
StackTop:		; 栈顶

[SECTION .data]
clock_int_msg db "^", 0

global _start	; 导出 _start

global restart 

global	divide_error
global	single_step_exception
global	nmi
global	breakpoint_exception
global	overflow
global	bounds_check
global	inval_opcode
global	copr_not_available
global	double_fault
global	copr_seg_overrun
global	inval_tss
global	segment_not_present
global	stack_exception
global	general_protection
global	page_fault
global	copr_error
global	hwint00
global	hwint01
global	hwint02
global	hwint03
global	hwint04
global	hwint05
global	hwint06
global	hwint07
global	hwint08
global	hwint09
global	hwint10
global	hwint11
global	hwint12
global	hwint13
global	hwint14
global	hwint15

[section .text]

_start: 
	xchg bx, bx 
	; 把esp从loader挪到KERNEL
    mov esp, StackTop

	mov	dword [disp_pos], 0

    sgdt [gdt_ptr] ;保存老的GDT到kernel空间
    call cstart 	
    lgdt [gdt_ptr]	;从kernel空间重新加载gdt

	lidt [idt_ptr] ; 加载中断描述符表

    jmp SELECTOR_KERNEL_CS:csinit
csinit:		; “这个跳转指令强制使用刚刚初始化的结构”——<<OS:D&I 2nd>> P90.
    ;push	0
	;popfd	; Pop top of stack into EFLAGS

	;sti ;打开中断

	;ud2
	;jmp 0x40:0

	xor eax, eax 
	mov ax, SELECTOR_TSS 
	ltr ax

	jmp happy_main

	;hlt
  
restart:
	mov esp, [p_proc_ready]
	lldt [esp + P_LDT_SEL]

	lea eax, [esp + P_STACK_TOP]
	mov dword [tss + TSS3_S_SP0], eax

	pop gs 
	pop fs 
	pop es 
	pop ds 
	popad 
	add esp, 4 
	iretd
;restart_reenter:
;	dec dword [k_reenter]
;	pop gs 
;	pop fs 
;	pop es
;	pop ds 
;	popad 
;	add esp, 4 
;	iret 

  ; 中断和异常 -- 硬件中断
; ---------------------------------
%macro	hwint_master	1
	push	%1
	call	spurious_irq
	add	esp, 4
	hlt
%endmacro

ALIGN	16
hwint00:		; Interrupt routine for irq 0 (the clock).
	;inc byte [gs:0]
	;mov al, EOI ; reenable 
   	;out INT_M_CTL, al 
	;iretd
	; esp指向StackFrame的高地址，也就是retaddr;
	; sub 4个字节，也就是把这个地址跳过了。
	sub esp, 4 
	pushad 
	push ds 
	push es 
	push fs 
	push gs 
	; 以上是保存工作
	;进入到ring0之后，除了ss,cs以外，其他的都是其他Ring的，
	; 所以在开始任务之前需要把其他的seg寄存器设置成正确的
	mov	dx, ss
	mov	ds, dx
	mov	es, dx

	;进程调度开始
   inc byte [gs:0]

   mov al, EOI ; reenable 
   out INT_M_CTL, al 

	inc dword [k_reenter]
	cmp dword [k_reenter], 0
	jne .re_enter

	mov esp, StackTop ;把ESP从进程表切走，切到内核栈（用来完成既定工作，例如进程调度等）
	sti ;开启中断

	push 0
	call clock_handler
	add esp, 4 
   ;push clock_int_msg 
   ;call disp_str 
   ;add esp, 4

   ; 进程调度结束

	cli ;关闭中断

   mov esp, [p_proc_ready]; 离开内核栈，把ESP指向下一个要被调度到的进程表
   lea eax, [esp + P_STACK_TOP]
   mov dword [tss + TSS3_S_SP0], eax 
.re_enter:
	dec dword[k_reenter]

	; 以下是恢复工作
   pop gs 
   pop fs 
   pop es 
   pop ds 
   popad 
   add esp, 4 
   iretd

ALIGN	16
hwint01:		; Interrupt routine for irq 1 (keyboard)
	hwint_master	1

ALIGN	16
hwint02:		; Interrupt routine for irq 2 (cascade!)
	hwint_master	2

ALIGN	16
hwint03:		; Interrupt routine for irq 3 (second serial)
	hwint_master	3

ALIGN	16
hwint04:		; Interrupt routine for irq 4 (first serial)
	hwint_master	4

ALIGN	16
hwint05:		; Interrupt routine for irq 5 (XT winchester)
	hwint_master	5

ALIGN	16
hwint06:		; Interrupt routine for irq 6 (floppy)
	hwint_master	6

ALIGN	16
hwint07:		; Interrupt routine for irq 7 (printer)
	hwint_master	7

; ---------------------------------
%macro	hwint_slave	1
	push	%1
	call	spurious_irq
	add	esp, 4
	hlt
%endmacro
; ---------------------------------

ALIGN	16
hwint08:		; Interrupt routine for irq 8 (realtime clock).
	hwint_slave	8

ALIGN	16
hwint09:		; Interrupt routine for irq 9 (irq 2 redirected)
	hwint_slave	9

ALIGN	16
hwint10:		; Interrupt routine for irq 10
	hwint_slave	10

ALIGN	16
hwint11:		; Interrupt routine for irq 11
	hwint_slave	11

ALIGN	16
hwint12:		; Interrupt routine for irq 12
	hwint_slave	12

ALIGN	16
hwint13:		; Interrupt routine for irq 13 (FPU exception)
	hwint_slave	13

ALIGN	16
hwint14:		; Interrupt routine for irq 14 (AT winchester)
	hwint_slave	14

ALIGN	16
hwint15:		; Interrupt routine for irq 15
	hwint_slave	15


; 中断和异常 -- 异常
divide_error:
	push	0xFFFFFFFF	; no err code
	push	0		; vector_no	= 0
	jmp	exception
single_step_exception:
	push	0xFFFFFFFF	; no err code
	push	1		; vector_no	= 1
	jmp	exception
nmi:
	push	0xFFFFFFFF	; no err code
	push	2		; vector_no	= 2
	jmp	exception
breakpoint_exception:
	push	0xFFFFFFFF	; no err code
	push	3		; vector_no	= 3
	jmp	exception
overflow:
	push	0xFFFFFFFF	; no err code
	push	4		; vector_no	= 4
	jmp	exception
bounds_check:
	push	0xFFFFFFFF	; no err code
	push	5		; vector_no	= 5
	jmp	exception
inval_opcode:
	push	0xFFFFFFFF	; no err code
	push	6		; vector_no	= 6
	jmp	exception
copr_not_available:
	push	0xFFFFFFFF	; no err code
	push	7		; vector_no	= 7
	jmp	exception
double_fault:
	push	8		; vector_no	= 8
	jmp	exception
copr_seg_overrun:
	push	0xFFFFFFFF	; no err code
	push	9		; vector_no	= 9
	jmp	exception
inval_tss:
	push	10		; vector_no	= A
	jmp	exception
segment_not_present:
	push	11		; vector_no	= B
	jmp	exception
stack_exception:
	push	12		; vector_no	= C
	jmp	exception
general_protection:
	push	13		; vector_no	= D
	jmp	exception
page_fault:
	push	14		; vector_no	= E
	jmp	exception
copr_error:
	push	0xFFFFFFFF	; no err code
	push	16		; vector_no	= 10h
	jmp	exception

exception:
	call	exception_handler
	add	esp, 4*2	; 让栈顶指向 EIP，堆栈中从顶向下依次是：EIP、CS、EFLAGS
	hlt

;操作系统帮我们压入栈的信息依次为：eflags, cs, eip; 
; 我们压入的分别是错误码，vector_code
