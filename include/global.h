#include "types.h"
#include "protect.h"
#include "process.h"

/* EXTERN is defined as extern except in global.c */
#ifdef	GLOBAL_VARIABLES_HERE
#undef	EXTERN
#define	EXTERN
#endif

EXTERN	t_8			gdt_ptr[6];	// 0~15:Limit  16~47:Base
EXTERN	DESCRIPTOR	gdt[GDT_SIZE];
EXTERN	t_8			idt_ptr[6];	// 0~15:Limit  16~47:Base
EXTERN	GATE		idt[IDT_SIZE];
EXTERN TSS      tss;

EXTERN	PROCESS*	p_proc_ready;

EXTERN u32 k_reenter;

extern PROCESS      proc_table[];
extern char		task_stack[];
extern TASK    task_table[];