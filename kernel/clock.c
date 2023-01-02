#include "types.h"
#include "global.h"

PUBLIC void clock_handler(int irq) {
    ticks++;
    p_proc_ready->ticks--;

    disp_str("#");
    if (k_reenter != 0) {
        disp_str("!");
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