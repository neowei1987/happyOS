#ifndef	_TINIX_CONST_H_
#define	_TINIX_CONST_H_


/* GDT 和 IDT 中描述符的个数 */
#define	GDT_SIZE	128
#define	IDT_SIZE	256

//每一个任务有单独的LDT，每一个LDT中的描述符个数
#define LDT_SIZE    2

/* Number of tasks */
#define NR_TASKS 2

#define NR_CONSOLES 3

/* stacks of tasks */
#define STACK_SIZE_TASK_TTY	0x8000
#define STACK_SIZE_TESTB	0x8000

#define STACK_SIZE_TOTAL	STACK_SIZE_TASK_TTY + STACK_SIZE_TESTB

/* 权限 */
#define	PRIVILEGE_KRNL	0
#define	PRIVILEGE_TASK	1
#define	PRIVILEGE_USER	3

/* RPL */
#define	RPL_KRNL	SA_RPL0
#define	RPL_TASK	SA_RPL1
#define	RPL_USER	SA_RPL3

/* 8259A interrupt controller ports. */
#define	INT_M_CTL	0x20	/* I/O port for interrupt controller         <Master> */
#define	INT_M_CTLMASK	0x21	/* setting bits in this port disables ints   <Master> */
#define	INT_S_CTL	0xA0	/* I/O port for second interrupt controller  <Slave>  */
#define	INT_S_CTLMASK	0xA1	/* setting bits in this port disables ints   <Slave>  */

/* 8253/8254 PIT (Programmable Interval Timer) */
#define TIMER0          0x40	/* I/O port for timer channel 0 */
#define TIMER_MODE      0x43	/* I/O port for timer mode control */
#define RATE_GENERATOR	0x34	/* 00-11-010-0 : Counter0 - LSB then MSB - rate generator - binary */
#define TIMER_FREQ	1193182L/* clock frequency for timer in PC and AT */
#define HZ		100	/* clock freq (software settable on IBM-PC) */

/* AT keyboard */
/* 8042 ports */
#define	KB_DATA		0x60	/* I/O port for keyboard data
					Read : Read Output Buffer 
					Write: Write Input Buffer(8042 Data&8048 Command) */
#define	KB_CMD		0x64	/* I/O port for keyboard command
					Read : Read Status Register
					Write: Write Input Buffer(8042 Command) */

/* VGA */
#define CRTC_ADDR_REG			0x3D4	/* CRT Controller Registers - Address Register */
#define CRTC_DATA_REG			0x3D5	/* CRT Controller Registers - Data Registers */
#define CRTC_DATA_IDX_START_ADDR_H	0xC	/* register index of video mem start address (MSB) */
#define CRTC_DATA_IDX_START_ADDR_L	0xD	/* register index of video mem start address (LSB) */
#define CRTC_DATA_IDX_CURSOR_H		0xE	/* register index of cursor position (MSB) */
#define CRTC_DATA_IDX_CURSOR_L		0xF	/* register index of cursor position (LSB) */
#define V_MEM_BASE			0xB8000	/* base of color video memory */
#define V_MEM_SIZE			0x8000	/* 32K: B8000H -> BFFFFH */

#define NR_IRQ 16 
#define	CLOCK_IRQ	0
#define	KEYBOARD_IRQ	1
#define	CASCADE_IRQ	2	/* cascade enable for 2nd AT controller */
#define	ETHER_IRQ	3	/* default ethernet interrupt vector */
#define	SECONDARY_IRQ	3	/* RS232 interrupt vector for port 2 */
#define	RS232_IRQ	4	/* RS232 interrupt vector for port 1 */
#define	XT_WINI_IRQ	5	/* xt winchester */
#define	FLOPPY_IRQ	6	/* floppy disk */
#define	PRINTER_IRQ	7
#define	AT_WINI_IRQ	14	/* at winchester */


/* system call */
#define	NR_SYS_CALL	2

#endif /* _TINIX_CONST_H_ */