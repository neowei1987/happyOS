%include  "pm.inc"

org     0100h ; 0x7c00

;xchg bx, bx 
jmp Label_Start

BaseofStack     equ     0x0100 ; 0100h??
PageDirBase 	equ 200000h ; 页目录开始地址 2M
PageTblBase equ 201000h ;页表开始地址

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

;得到内存数据
mov ebx, 0 
; 实模式下访问用_MemChkBuf，这个是相对DS的偏移【COM文件把所有的段放在了一起！】
mov di, _MemChkBuf 
.loop:
mov eax, 0E820h 
mov ecx, 20 
mov edx, 0534D4150h
int 15h 
jc LABEL_MEM_CHK_FAIL
add di, 20 
inc dword [_dwMCRNumber]
cmp ebx, 0 
jne .loop 
jmp LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
mov dword [_dwMCRNumber], 0 
LABEL_MEM_CHK_OK:

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

; 初始化Ring3 Code
xor eax, eax
mov ax, cs 
shl eax, 4
add eax, LABEL_CODE_RING3
mov word [LABEL_DESC_CODE_RING3 + 2], ax
shr eax, 16
mov byte [LABEL_DESC_CODE_RING3 + 4], al
mov byte [LABEL_DESC_CODE_RING3 + 7], ah 

; 初始化Ring3 Stack
xor eax, eax
mov ax, ss
shl eax, 4
add eax, LABEL_STACK3
mov word [LABEL_DESC_STACK_RING3 + 2], ax
shr eax, 16
mov byte [LABEL_DESC_STACK_RING3 + 4], al
mov byte [LABEL_DESC_STACK_RING3 + 7], ah 

; 初始化TSS(Task State Stack)
xor eax, eax
mov ax, ds
shl eax, 4
add eax, LABEL_TSS
mov word [LABEL_DESC_TSS + 2], ax
shr eax, 16
mov byte [LABEL_DESC_TSS + 4], al
mov byte [LABEL_DESC_TSS + 7], ah 

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

[SECTION .s32] 
[BITS 32]
LABEL_SEG_CODE32:
	mov ax, SelectorVideo
	mov gs, ax  ;视频段选择子
	mov ax, SelectorData
	mov ds, ax ; 数据段选择子
	mov ax, SelectorData
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
	push OffsetPModeMessage 
	call DispStr
	add esp, 4 
	call DispReturn 

	;call TestRead
	;call TestWrite 
	;call TestRead

	push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call DispMemSize

	call SetupPaging

	; 加载TSS，为特权级转换做准备
	mov ax, SelectorTSS
	ltr ax

	; 这里验证如何进入ring3
	push SelectorStack3
	push TopOfStack3
	push SelectorCodeRing3
	push 0
	retf
	
	;call SelectorCallGateTest:0

	;jmp SelectorCode16:0

;展示内存信息
DispMemSize:
	push esi
	push edi 
	push ecx
	
	mov esi, MemChkBuf ;地址放进去！
	mov ecx, [dwMCRNumber] ; 把dwMCRNumber里面的内容放到寄存中
.loop:
	mov edx, 5 
	mov edi, ARDStruct 
.1:	
	push dword[esi] ; 把ESI中的地址中存放的内容，放到了栈上
	call DispInt 
	pop eax ;
	stosd ;stosb需要寄存器edi配合使用。每执行一次stosb，就将al中的内容复制到[edi]中。
	add esi, 4
	dec edx
	cmp edx, 0
	jnz .1
	call DispReturn
	cmp dword[ddType], 1 
	jne .2 
	mov eax, [ddBaseAddrLow]
	add eax, [ddLengthLow]
	cmp eax, [dwMemSize]
	jb .2
	mov [dwMemSize], eax  
.2:
	loop .loop 

	call DispReturn

	push szRAMSize 
	call DispStr
	add esp, 4 

	push dword[dwMemSize]
	call DispInt
	add esp, 4 

	pop ecx
	pop edi 
	pop esi 

	ret

; 启动分页机制

SetupPaging:
	; 根据内存大小计算应该初始化多少PDE以及多少页表
	xor edx, edx 
	mov eax, [dwMemSize]
	mov ebx, 400000h ; 4M = 1024 * 4K 
	div ebx ; 商放在eax中，edx放余数
	mov ecx, eax ; ecx为页表个数
	test edx, edx  
	jz .no_remainder
	inc ecx 
.no_remainder:
	push ecx 

	;初始化页目录
	mov ax, SelectorPageDir
	mov es, ax 
	;mov ecx, 1024
	xor edi, edi 
	xor eax, eax 
	mov eax, PageTblBase | PG_P | PG_USU | PG_RWW
.4: 
	stosd 
	add eax, 4096 
	loop .4
	; PageDir的每一项，分别执行每一个TblBase

	;初始化页表, 1K个， 4M的空间
	mov ax, SelectorPageTbl
	mov es, ax 
	pop eax  ; 页表个数
	mov ebx, 1024
	mul ebx 
	mov ecx, eax  ; PTE个数 = 页表个数 * 1024
	xor edi, edi 
	xor eax, eax 
	mov eax, PG_P | PG_USU | PG_RWW
.2: 
	stosd 
	add eax, 4096 
	loop .2

	; 把页目录表基地址放入Cr3
	mov eax, PageDirBase
	mov cr3, eax 
	;设置CR0 的 PG（第232行到第234行），这样，分页机制就启动完成了。
	mov eax, cr0 
	or eax, 80000000h 
	mov cr0, eax 
	jmp short .3
.3:
	nop 
	ret

%include "lib.inc"

SegCode32Len equ $-LABEL_SEG_CODE32

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

	; 我们再进行调试的时候，发现无法回到dos下面。在将pe为清零的时候，出错提示：
	;check_CR0(0xe0000010): attempt to set CR0.PG with CR0.PE cleared 
	;答案：mov cr0，ax这句，尝试在pe=0的情况下，设置pg，显然是失败的。
	;因此，书中的代码实际上是不对的，必须先关闭分页机制，然后再关闭分段机制。
	jmp $

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
	mov edi, (80 * 15 + 2) * 2 
	mov ah, 0Ch 
	mov al, 'L'
	mov [gs:edi], ax 

	;mov al, 'L'
	;call DispAL
	;call DispReturn

	jmp SelectorCode16:0

CodeALen equ $-LABEL_CODE_A

;END of [SECTION .la]

[Section .sdest]
[bits 32]
LABEL_SEG_CODE_DEST:

	mov ax, SelectorVideo 
	mov gs, ax 
	mov edi, (80 * 15 + 1) * 2 
	mov ah, 0Ch 
	mov al, 'C'
	mov [gs:edi], ax 
	;mov al, 'C'
	;call DispAL
	;call DispReturn

	; 加载LDT
	mov ax, SelectorLDT
	lldt ax 

	jmp SelectorLDTCodeA:0 ; 局部任务

	;retf ; 与常规的ret有何区别？

SegCodeDestLen equ $ - LABEL_SEG_CODE_DEST

; ring3代码段
[section .ring3]
ALIGN 32
[bits 32]
LABEL_CODE_RING3:
	mov ax, SelectorVideo 
	mov gs, ax 
	mov edi, (80 * 15 + 0) * 2 
	mov ah, 0Ch 
	mov al, '3'
	mov [gs:edi], ax 
	;mov al, '3'
	;call DispAL
	;call DispReturn

	;ring3 通过调用门调用ring3代码
	call SelectorCallGateTest:0

	jmp $

SegCodeRing3Len equ $ - LABEL_CODE_RING3

; TSS ---------------------------------------------------------------------------------------------
[SECTION .tss]
ALIGN	32
[BITS	32]
LABEL_TSS:
		DD	0			; Back
		DD	TopOfStack		; 0 级堆栈
		DD	SelectorStack		; 
		DD	0			; 1 级堆栈
		DD	0			; 
		DD	0			; 2 级堆栈
		DD	0			; 
		DD	0			; CR3
		DD	0			; EIP
		DD	0			; EFLAGS
		DD	0			; EAX
		DD	0			; ECX
		DD	0			; EDX
		DD	0			; EBX
		DD	0			; ESP
		DD	0			; EBP
		DD	0			; ESI
		DD	0			; EDI
		DD	0			; ES
		DD	0			; CS
		DD	0			; SS
		DD	0			; DS
		DD	0			; FS
		DD	0			; GS
		DD	0			; LDT
		DW	0			; 调试陷阱标志
		DW	$ - LABEL_TSS + 2	; I/O位图基址
		DB	0ffh			; I/O位图结束标志
TSSLen 	equ $ - LABEL_TSS

; Ring3
; ring3堆栈段
[section .s3]
ALIGN 32
[bits 32]
LABEL_STACK3:
	times 512 db 0

TopOfStack3 equ $ - LABEL_STACK3 - 1 ;？ 为啥有的-1，有的不减呢？

[SECTION .gdt]

LABEL_GDT: 			Descriptor 	0, 			0, 						0
LABEL_DESC_NORMAL: 	Descriptor	0, 			0ffffh, 				DA_DRW
LABEL_DESC_CODE32: 	Descriptor 	0, 			SegCode32Len - 1, 		DA_C + DA_32 ;非一致代码段 
LABEL_DESC_CODE16: 	Descriptor 	0, 			0ffffh, 				DA_C		 ;非一致代码段 
LABEL_DESC_CODE_CALL: Descriptor 0, 		SegCodeDestLen - 1, DA_C + DA_32  ;非一致代码段
LABEL_DESC_CODE_RING3: Descriptor 0, 		SegCodeRing3Len - 1, DA_C + DA_32 + DA_DPL3 ;非一致代码段

LABEL_DESC_DATA:	Descriptor  0, 			DataLen - 1, 				DA_DRW ; 为什么此处不需要指定32？
LABEL_DESC_STACK	Descriptor	0, 			TopOfStack, 			DA_DRWA + DA_32
LABEL_DESC_STACK_RING3 	Descriptor 0, 		TopOfStack3, 			DA_DRWA + DA_32 + DA_DPL3
LABEL_DESC_TEST		Descriptor	0500000h, 	0ffffh, 				DA_DRW
LABEL_DESC_VIDEO: 	Descriptor 	0B8000h, 	0ffffh,  				DA_DRW + DA_DPL3 ;显存首地址
LABEL_DESC_LDT: 	Descriptor 	0, 	LDTLen - 1, DA_LDT 			
LABEL_DESC_TSS: 	Descriptor 	0, 	TSSLen - 1, DA_386TSS 			

; 门
LABEL_CALL_GATE_TEST: Gate Selector_CODE_CALL, 0, 0, DA_386CGate + DA_DPL3 

LABEL_DESC_PAGE_DIR: Descriptor PageDirBase, 4096, DA_DRW 
LABEL_DESC_PAGE_TBL: Descriptor PageTblBase, 8 * 4096, DA_DRW; 为啥去掉这个flag了？?+ DA_LIMIT_4K

GdtLen	equ $ - LABEL_GDT

GdtPtr 	dw 	GdtLen
		dd 	0
 
SelectorNormal equ LABEL_DESC_NORMAL - LABEL_GDT
SelectorCode16 equ LABEL_DESC_CODE16 - LABEL_GDT
SeletorCode32 	equ LABEL_DESC_CODE32 - LABEL_GDT
Selector_CODE_CALL equ LABEL_DESC_CODE_CALL - LABEL_GDT
SelectorCodeRing3 equ LABEL_DESC_CODE_RING3 - LABEL_GDT + SA_RPL3

SelectorData equ LABEL_DESC_DATA - LABEL_GDT
SelectorStack 	equ LABEL_DESC_STACK - LABEL_GDT
SelectorStack3 equ LABEL_DESC_STACK_RING3 - LABEL_GDT + SA_RPL3
SelectorVideo 	equ LABEL_DESC_VIDEO - LABEL_GDT
SelectorTest 	equ LABEL_DESC_TEST - LABEL_GDT 
SelectorLDT 	equ LABEL_DESC_LDT - LABEL_GDT 
SelectorCallGateTest equ LABEL_CALL_GATE_TEST - LABEL_GDT + SA_RPL3
SelectorTSS 	equ LABEL_DESC_TSS - LABEL_GDT
SelectorPageDir equ LABEL_DESC_PAGE_DIR - LABEL_GDT
SelectorPageTbl equ LABEL_DESC_PAGE_TBL - LABEL_GDT 

;END of [SECTION .gdt]

[SECTION .ldt] 
ALIGN 32
LABEL_LDT:
LABEL_LDT_DESC_CODE_A: Descriptor 0, CodeALen - 1, DA_C + DA_32 
LDTLen equ $ - LABEL_LDT

SelectorLDTCodeA equ LABEL_LDT_DESC_CODE_A - LABEL_LDT + SA_TIL 
;END of [SECTION .ldt]

;数据段
[SECTION .data1] 
ALIGN	32
[BITS 32]

LABEL_DATA:

startBootMessage:   db  "start Boot"
SPValueInRealMode	dw 0
; 内存获取与展示相关
_MemChkBuf: times 256 dd 0
_szMemChkTitle:			db	"BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0	; 进入保护模式后显示此字符串
_szRAMSize			db	"RAM size:", 0
_szReturn db 0Ah, 0 

_dwMCRNumber: dd 0 
_dwDispPos:	dd (80 * 3 + 0) * 2
_dwMemSize: dd 0 
_ARDStruct: 	; Address Range Descriptor Structure
	_ddBaseAddrLow: dd 0 
	_dBaseAddrHigh: dd 0
	_ddLengthLow: dd 0 
	_ddLengthHigh: dd 0
	_ddType: dd 0
PModeMessage:	db "In ProtectMode now...", 0Ah, 0
StrTest:	db "ABCDEFGHIJKLMNOPORSTUVWXYZ", 0

OffsetPModeMessage 	equ PModeMessage - $$
OffsetStrTest equ StrTest - $$
szReturn		equ	_szReturn	- $$
szMemChkTitle	equ	_szMemChkTitle	- $$
szRAMSize		equ	_szRAMSize	- $$
MemChkBuf equ  _MemChkBuf - $$ ; 相对这一SECION的偏移量？
ARDStruct equ	_ARDStruct	- $$
	ddBaseAddrLow	equ	_ddBaseAddrLow	- $$
	dBaseAddrHigh	equ	_dBaseAddrHigh	- $$
	ddLengthLow	equ	_ddLengthLow	- $$
	ddLengthHigh	equ	_ddLengthHigh	- $$
	ddType		equ	_ddType		- $$
dwDispPos		equ	_dwDispPos	- $$
dwMemSize		equ	_dwMemSize	- $$
dwMCRNumber		equ	_dwMCRNumber	- $$

DataLen equ $-LABEL_DATA

; 全局堆栈段
[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
	times 512 db 0

TopOfStack equ $ - LABEL_STACK 
