#ifndef PROCESS_H
#define PROCESS_H

#include "types.h"
#include "protect.h"

typedef struct s_stackframe {
    u32 gs;
    u32 fs;
    u32 es;
    u32 ds;
    u32 edi;
    u32 esi;
    u32 ebp;
    //以上pushed by save
    u32 kernel_esp;  //popad 忽略这些。
    u32 ebx; 
    u32 edx;
    u32 ecx;
    u32 eax;

    u32 ret_addr; //kernel save 

    u32 eip; 
    u32 cs;
    u32 eflags;
    u32 esp;
    u32 ss;
    //以上几个 pushed by CPU during interupt

}STACK_FRAME;

typedef struct s_proc {
    STACK_FRAME regs;
    u16 ldt_selector;
    DESCRIPTOR ldts[LDT_SIZE];
    u32 pid;
    char p_name[16];
} PROCESS;

#endif//PROCESS_H
