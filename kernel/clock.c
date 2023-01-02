#include "types.h"
#include "global.h"
#include "public.h"

PUBLIC void init_clock() {
    /* 初始化 8253 PIT*/
    out_byte(TIMER_MODE, RATE_GENERATOR);
    out_byte(TIMER0, (t_8)(TIMER_FREQ/HZ));
    out_byte(TIMER0, (t_8)((TIMER_FREQ/HZ) >> 8));

    //设置时钟中断处理函数
    put_irq_handler(CLOCK_IRQ, clock_handler);
    enable_irq(CLOCK_IRQ);
} 

PUBLIC void clock_handler(int irq) {
    ticks++;
    p_proc_ready->ticks--;

    //disp_str("#");
    if (k_reenter != 0) {
        //disp_str("!");
        return;
    }

    if (p_proc_ready->ticks > 0) {
        return;
    }

    schedule();
}

PUBLIC int sys_get_ticks() {
    return ticks;
}

PUBLIC void milli_delay(int milli_sec) {
    int t = get_ticks();
    while (((get_ticks() - t) * 1000 / HZ) < milli_sec) {}
}