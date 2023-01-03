#ifndef PROCESS_H
#define PROCESS_H

#include "types.h"
#include "protect.h"
#include "const.h"
typedef struct s_stackframe {
    //以下在save中挨个push
    u32 gs;
    u32 fs;
    u32 es;
    u32 ds;

    // save中通过pushad来设置
    u32 edi;
    u32 esi;
    u32 ebp;
    u32 kernel_esp;
    u32 ebx; 
    u32 edx;
    u32 ecx;
    u32 eax;

    //kernel 调用save的时候，把save的下一句地址放到了这里！
    u32 ret_addr; 

    //以下几个 pushed by CPU during interupt
    u32 eip; 
    u32 cs;
    u32 eflags;
    u32 esp;
    u32 ss;

}STACK_FRAME;

typedef struct s_proc {
    STACK_FRAME regs;
    u16 ldt_selector;
    DESCRIPTOR ldts[LDT_SIZE];

    int ticks;
    int priority;

    u32 pid;
    char p_name[16];
    int nr_tty; //所属的tty
} PROCESS;

typedef void (*task_f) ();

#define PROCESS_TYPE_TASK 1
#define PROCESS_TYPE_USER 2
typedef struct s_task {
    task_f initial_eip;
    int stack_size;
    char name[32];
    int priority;
    int type; 
} TASK;

#endif//PROCESS_H
