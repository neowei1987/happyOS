#include "public.h"
#include "process.h"
#include "protect.h"
#include "global.h"

extern void simple();

extern int			disp_pos;

PUBLIC void TestA() {
    int i = 0;
    while (1) {
        disp_str("A");
        disp_int(i++);
        disp_str(".");
        if (disp_pos >= 0xF8E) {
            disp_pos = 0;
        }
        //simple();
        delay(1);
    }
}

PUBLIC void TestB() {
    int i = 0;
    while (1) {
        disp_str("B");
        disp_int(i++);
        disp_str(".");
        delay(1);
    }
}

TASK    task_table[NR_TASKS] = {
    {TestA, STACK_SIZE_TESTA, "TestA"},
    {TestB, STACK_SIZE_TESTB, "TestB"}
};

PUBLIC int happy_main() {
    disp_str("----kernel_main_begin____\n");
    //设置中断处理函数
    put_irq_handler(CLOCK_IRQ, clock_handler);
    enable_irq(CLOCK_IRQ);
    k_reenter = 0;
    u16 selector_ldt = SELECTOR_LDT_FIRST; //28
    char* p_task_stack = task_stack + STACK_SIZE_TOTAL;

    for (int i = 0; i < NR_TASKS; ++i) {
        TASK *p_task = task_table + i; 
        PROCESS* p_proc = proc_table + i;
        //TODO copy task name
        p_proc->pid = i;

        //LDT selector
        p_proc->ldt_selector = selector_ldt;

        //LDT
        memcpy(p_proc->ldts + 0, gdt + (SELECTOR_KERNEL_CS >> 3), sizeof(DESCRIPTOR));
        p_proc->ldts[0].attr1 = DA_C | PRIVILEGE_TASK << 5; //change the DPL
        memcpy(p_proc->ldts +1, gdt + (SELECTOR_KERNEL_DS >> 3), sizeof(DESCRIPTOR));
        p_proc->ldts[1].attr1 = DA_DRW | PRIVILEGE_TASK << 5; //change the DPL 

        //寄存器初始化
        p_proc->regs.cs = (0 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.ds = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.es = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.fs = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.ss = (8 & SA_RPL_MASK & SA_TI_MASK) | SA_TIL | RPL_TASK;
        p_proc->regs.gs = (SELECTOR_KERNEL_GS & SA_RPL_MASK) | RPL_TASK;

        p_proc->regs.eip = (u32)p_task->initial_eip;
        p_proc->regs.esp = (u32)p_task_stack;
        p_proc->regs.eflags = 0x1202; //IF = 1(打开中断), IOPL = 1; bit2 is always 1 WHY？？
   
        p_task_stack -= p_task->stack_size;
        selector_ldt += (1 << 3); //偏移量加8 
    }

    p_proc_ready = proc_table;

    restart();

    while (1) {}
}


