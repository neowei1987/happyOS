#ifndef PUBLIC_H
#define PUBLIC_H

#include "types.h"
#include "const.h"
#include "process.h"
#include "console.h"
#include "tty.h"

//klib.asm
PUBLIC void disable_int();
PUBLIC void enable_int();
PUBLIC void	out_byte(t_port port, t_8 value);
PUBLIC t_8	in_byte(t_port port);

PUBLIC void	disp_str(char * info);
PUBLIC void	disp_color_str(char * info, int color);

PUBLIC void debug_trap();

//memory.asm
PUBLIC	void* memcpy(void* p_dst, void* p_src, int size);

//
PUBLIC void	init_descriptors();

PUBLIC void put_irq_handler(int irq, irq_handler handler);

//clock.c
PUBLIC void clock_handler(int irq);
PUBLIC void init_clock();

PUBLIC int sys_get_ticks();
PUBLIC void milli_delay(int milli_sec);

//keyboard
PUBLIC void keyboard_handler(int irq);
PUBLIC void init_keyboard();
PUBLIC void keyboard_read();

//process
PUBLIC void schedule();

//tty
PUBLIC void tty_task();
PUBLIC void in_process(TTY* p_tty, t_32 key);

//console
PUBLIC void out_char(CONSOLE* p_console, char ch);
PUBLIC void init_screen(TTY* p_tty);
PUBLIC void select_console(int nr_console);

PUBLIC int write(char* buf, int len);
PUBLIC int sys_write(char* buf, int len, PROCESS* p_proc);


#endif//PUBLIC_H