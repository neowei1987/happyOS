#define GLOBAL_VARIABLES_HERE

#include "types.h"
#include "const.h"
#include "protect.h"
#include "global.h"
#include "func_declare.h"
#include "public.h"

PROCESS      proc_table[NR_TASKS];
char		task_stack[STACK_SIZE_TOTAL];

irq_handler irq_table[NR_IRQ];

t_sys_call	sys_call_table[NR_SYS_CALL] = {sys_get_ticks};

