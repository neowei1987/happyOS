%include  "pm.inc"

org     0100h ; 0x7c00

jmp Label_Start

BaseofStack     equ     0x0100 ; 0100h??

[SECTION .gdt]

LABEL_GDT: 			Descriptor 	0, 			0, 						0
LABEL_DESC_NORMAL: 	Descriptor	0, 			0ffffh, 				DA_DRW
LABEL_DESC_CODE32: 	Descriptor 	0, 			SegCode32Len - 1, 		DA_C + DA_32 ;非一致代码段 
LABEL_DESC_CODE16: 	Descriptor 	0, 			0ffffh, 				DA_C		 ;非一致代码段 
LABEL_DESC_CODE_CALL: Descriptor 0, 		SegCodeDestLen - 1, DA_C + DA_32  ;非一致代码段
LABEL_DESC_DATA:	Descriptor  0, 			DataLen - 1, 				DA_DRW ; 为什么此处不需要指定32？
LABEL_DESC_STACK	Descriptor	0, 			TopOfStack, 			DA_DRWA + DA_32
LABEL_DESC_TEST		Descriptor	0500000h, 	0ffffh, 				DA_DRW
LABEL_DESC_VIDEO: 	Descriptor 	0B8000h, 	0ffffh,  				DA_DRW ;显存首地址
LABEL_DESC_LDT: 	Descriptor 	0, 	LDTLen - 1, DA_LDT 			

; 门
LABEL_CALL_GATE_TEST: Gate Selector_CODE_CALL, 0, 0, DA_386CGate + DA_DPL0 

GdtLen	equ $ - LABEL_GDT

GdtPtr 	dw 	GdtLen
		dd 	0
 
SelectorNormal equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode16 equ LABEL_DESC_CODE16 - LABEL_GDT
SeletorCode32 	equ LABEL_DESC_CODE32 - LABEL_GDT
Selector_CODE_CALL equ LABEL_DESC_CODE_CALL - LABEL_GDT

SelectorData equ LABEL_DESC_DATA - LABEL_GDT
SelectorStack 	equ LABEL_DESC_STACK - LABEL_GDT
SelectorVideo 	equ LABEL_DESC_VIDEO - LABEL_GDT
SelectorTest 	equ LABEL_DESC_TEST - LABEL_GDT 
SelectorLDT 	equ LABEL_DESC_LDT - LABEL_GDT 
SelectorCallGateTest equ LABEL_CALL_GATE_TEST - LABEL_GDT

;END of [SECTION .gdt]

[SECTION .ldt] 
ALIGN 32
LABEL_LDT:
LABEL_LDT_DESC_CODE_A: Descriptor 0, CodeALen - 1, DA_C + DA_32 
LDTLen equ $ - LABEL_LDT


SelectorLDTCodeA equ LABEL_LDT_DESC_CODE_A - LABEL_LDT + SA_TIL 
;END of [SECTION .ldt]

[SECTION .s16]
[BITS 16]
 
Label_Start:
mov     ax,     cs      
mov     ds,     ax
mov     es,     ax
mov     ss,     ax
mov     sp,     BaseofStack 

; 把内存改了，CS被写入到LABEL_GO_BACK_TO_REAL处的跳转指令TARGET CS
mov [LABEL_GO_BACK_TO_REAL + 3], ax
; 把SP保存到某块内存中 
mov [SPValueInRealMode], sp

;===============clear screen    
mov ax, 0600h
mov bx, 0700h
mov cx, 0
mov dx, 0184fh
int 10h
 
;===============set focus  
 
mov ax, 0200h
mov bx, 0000h
mov dx,  0000h
int 10h
 
;============display on screen : start booting....
 
mov ax, 1301h
mov bx, 000fh
mov dx, 0000h
mov cx, 10
push ax
mov ax, ds
mov es,  ax
pop ax
mov bp, startBootMessage
int 10h
 
;======== reset floppy
xor ah,ah
xor dl,dl

; 初始化16位代码段描述符
mov ax,cs
movzx eax, ax ; 从小到大复制时，其余位用0填充
shl eax, 4
add eax, LABEL_SEG_CODE16
mov word [LABEL_DESC_CODE16 + 2], ax
shr eax, 16
mov byte [LABEL_DESC_CODE16 + 4], al
mov byte [LABEL_DESC_CODE16 + 7], ah

; 初始化32位代码段描述符
xor eax, eax
mov ax, cs ; cs -> ax
shl eax, 4
add eax, LABEL_SEG_CODE32
mov word [LABEL_DESC_CODE32 + 2], ax
shr eax, 16
mov byte [LABEL_DESC_CODE32 + 4], al
mov byte [LABEL_DESC_CODE32 + 7], ah

; 初始化数据段描述符
xor eax, eax
mov ax, ds 
shl eax, 4
add eax, LABEL_DATA
mov word [LABEL_DESC_DATA + 2], ax
shr eax, 16
mov byte [LABEL_DESC_DATA + 4], al
mov byte [LABEL_DESC_DATA + 7], ah

; 初始化堆栈段？
xor eax, eax
mov ax, ds  ; 为什么不是SS?
shl eax, 4
add eax, LABEL_STACK
mov word [LABEL_DESC_STACK + 2], ax
shr eax, 16
mov byte [LABEL_DESC_STACK + 4], al
mov byte [LABEL_DESC_STACK + 7], ah

; 初始化LDT在GDT中的描述符
xor eax, eax
mov ax, ds  
shl eax, 4
add eax, LABEL_LDT
mov word [LABEL_DESC_LDT + 2], ax
shr eax, 16
mov byte [LABEL_DESC_LDT + 4], al
mov byte [LABEL_DESC_LDT + 7], ah

; 初始化调用门
xor eax, eax
mov ax, cs 
shl eax, 4
add eax, LABEL_SEG_CODE_DEST
mov word [LABEL_DESC_CODE_CALL + 2], ax
shr eax, 16
mov byte [LABEL_DESC_CODE_CALL + 4], al
mov byte [LABEL_DESC_CODE_CALL + 7], ah 

; 初始化LDT中的描述符
xor eax, eax
mov ax, ds 
shl eax, 4
add eax, LABEL_CODE_A
mov word [LABEL_LDT_DESC_CODE_A + 2], ax
shr eax, 16
mov byte [LABEL_LDT_DESC_CODE_A + 4], al
mov byte [LABEL_LDT_DESC_CODE_A + 7], ah 


; 为加载GDTR做准备
xor eax, eax
mov ax, ds 
shl eax, 4
; ear <-gdt 基地址
add eax, LABEL_GDT
; 【GdtPtr+2】<- gdt基地址
mov dword [GdtPtr + 2], eax 

; 加载GDTR
lgdt [GdtPtr]

; 关中断
cli

; 打开地址线A20
in al, 92h
or al, 00000010b
out 92h, al

; 准备切换到保护模式
mov eax, cr0
or eax, 1
mov cr0, eax 

jmp dword SeletorCode32:0

;;;;;;;;;;;;;

LABEL_REAL_ENTRY:
	mov ax, cs 
	mov ds, ax 
	mov es, ax 
	mov ss, ax 

	mov sp, [SPValueInRealMode]

	in al, 92h
	and al, 11111101b ;关闭A20地址线

	sti ;开中断
	mov ax, 4c00h 
	int 21h ;回到DOS ？ 不需要CR0吗？

; END of [SECTION .s16]

;数据段
[SECTION .data1] 
ALIGN	32
[BITS 32]

LABEL_DATA:

SPValueInRealMode	dw 0

PModeMessage:	db "In ProtectMode now..."
OffsetPModeMessage 	equ PModeMessage - $$
StrTest:	db "ABCDEFGHIJKLMNOPORSTUVWXYZ", 0
OffsetStrTest equ StrTest - $$
DataLen equ $-LABEL_DATA

; 全局堆栈段
[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
	times 512 db 0

TopOfStack equ $ - LABEL_STACK 

[SECTION .s32] 
[BITS 32]
LABEL_SEG_CODE32:
	mov ax, SelectorVideo
	mov gs, ax  ;视频段选择子
	mov ax, SelectorData
	mov ds, ax ; 数据段选择子
	mov ax, SelectorTest
	mov es, ax ; 测试段选择子

	mov ax, SelectorStack
	mov ss, ax ; 堆栈段选择子
	mov esp, TopOfStack

	; 屏幕第11行，第79列
	mov ah, 0Ch ; 0000: 黑底    1100: 红字
	;汇编语言中，串操作指令LODSB/LODSW是块读出指令，
	;其具体操作是把SI指向的存储单元读入累加器,
	;其中LODSB是读入AL,LODSW是读入AX中,
	;然后SI自动增加或减小1或2位.当方向标志位DF=0时，则SI自动增加；
	;DF=1时，SI自动减小。
	xor esi, esi 
	xor edi, edi 
	mov esi, OffsetPModeMessage
	mov edi, (80 * 11 + 0) * 2 
	cld 
.1:	
	lodsb 
	test al, al
	jz .2
	mov [gs:edi], ax 
	add edi, 2
	jmp .1
.2:	
	call DispReturn 

	call TestRead
	call TestWrite 
	call TestRead

	call DispReturn

	call SelectorCallGateTest:0

	; 加载LDT
	mov ax, SelectorLDT
	lldt ax 

	jmp SelectorLDTCodeA:0 ; 局部任务

	;jmp SelectorCode16:0

TestRead:
	xor esi, esi 
	mov ecx, 8 
.loop:
	mov al, [es:esi]
	call DispAL 
	inc esi 
	loop .loop 

	call DispReturn
	ret 
;TestRead结束

TestWrite:
	push esi
	push edi 
	xor esi, esi
	xor edi, edi 
	mov esi, OffsetStrTest
	cld 
.1:
	lodsb 
	test al, al 
	jz .2 
	mov [es:edi], al 
	inc edi 
	jmp .1
.2: 	
	pop edi 
	pop esi 
	ret 
;TestRead结束

; ------------------------------------------------------------------------
; 显示 AL 中的数字
; 默认地:
;	数字已经存在 AL 中
;	edi 始终指向要显示的下一个字符的位置
; 被改变的寄存器:
;	ax, edi
; ------------------------------------------------------------------------
DispAL:
	push ecx
	push edx
	mov ah, 0Ch 
	mov dl, al 
	shr al, 4 
	mov ecx, 2 
.begin: 
	and al, 01111b 
	cmp al, 9
	ja .1
	add al, '0'
	jmp .2 
.1:	
	sub al, 0Ah 
	add al, 'A'
.2:
 	mov [gs:edi], ax 
	add edi, 2 

	mov al, dl 
	loop .begin 
	add edi, 2 

	pop edx
	pop ecx 
	ret	
;DispAL结束

; 对edi做更改
DispReturn:
	push eax
	push ebx 
	mov eax, edi 
	mov bl, 160 
	div bl 
	and eax, 0FFh 
	inc eax 
	mov bl, 160 
	mul bl
	mov edi, eax 
	pop ebx 
	pop eax 
	ret 
; DispReturn结束

SegCode32Len equ $-LABEL_SEG_CODE32

startBootMessage:   db  "start Boot"

;=========fill zero until whole sector
; $表示当前行被汇编后的地址
;那么$$表示什么呢？它表示一个节（section0）的开始处被汇编后的地
;址。在这里，我们的程序只有1个节，所以，$$实际上就表示程序被编
;译后的开始地址，也就是0x7c00。
 
; times 510 - 36 - 144 -($ - $$) db 0

; 16 位代码段. 由 32 位代码段跳入, 跳出后到实模式
[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:
	mov ax, SelectorNormal
	mov ds, ax 
	mov es, ax 
	mov fs, ax 
	mov gs, ax 
	mov ss, ax 
	mov eax, cr0
	and al, 11111110b 
	mov cr0, eax 

LABEL_GO_BACK_TO_REAL:
	jmp 0:LABEL_REAL_ENTRY ; 段地址会在程序开始处被设置成正确的值

Code16Len	equ	$ - LABEL_SEG_CODE16

[SECTION .la]
ALIGN 32
[BITS 32]
LABEL_CODE_A:
	mov ax, SelectorVideo 
	mov gs, ax 
	mov edi, (80 * 15 + 0) * 2 
	mov ah, 0Ch 
	mov al, 'L'
	mov [gs:edi], ax 

	jmp SelectorCode16:0

CodeALen equ $-LABEL_CODE_A

;END of [SECTION .la]

[Section .sdest]
[bits 32]
LABEL_SEG_CODE_DEST:
	mov ax, SelectorVideo 
	mov gs, ax 
	mov edi, (80 * 12 + 1) * 2 
	mov ah, 0Ch 
	mov al, 'C'
	mov [gs:edi], ax 

	retf ; 与常规的ret有何区别？

SegCodeDestLen equ $ - LABEL_SEG_CODE_DEST
