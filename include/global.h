#include "types.h"
#include "protect.h"
#include "process.h"
#include "tty.h"
#include "console.h"

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

EXTERN int disp_pos;

EXTERN	PROCESS*	p_proc_ready;

EXTERN u32 k_reenter;

extern PROCESS      proc_table[];
extern char		task_stack[];
extern TASK    task_table[];

extern irq_handler irq_table[];

extern t_sys_call	sys_call_table[];

EXTERN int ticks;

EXTERN TTY tty_table[NR_CONSOLES];
EXTERN CONSOLE console_table[NR_CONSOLES];
EXTERN int nr_current_console;