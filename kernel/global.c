#define GLOBAL_VARIABLES_HERE

#include "types.h"
#include "const.h"
#include "protect.h"
#include "global.h"

int			disp_pos;

PROCESS      proc_table[NR_TASKS];
char		task_stack[STACK_SIZE_TOTAL];