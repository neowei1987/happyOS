#include "process.h"
#include "global.h"

PUBLIC void schedule() {
    PROCESS * p;
    int greatest_ticks = 0;

    while (!greatest_ticks) {
        for (p = proc_table; p < proc_table + NR_TASKS + NR_USER_PROCESS; p++) {
            if (p->ticks > greatest_ticks) {
                greatest_ticks = p->ticks;
                p_proc_ready = p;
            }
        }

		if (!greatest_ticks) {
			for (p=proc_table; p<proc_table+NR_TASKS + NR_USER_PROCESS; p++) {
				p->ticks = p->priority;
			}
		}
    }

}