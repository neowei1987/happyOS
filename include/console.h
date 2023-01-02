#ifndef CONSOLE_H
#define CONSOLE_H

#include "types.h"
typedef struct s_console {
    t_32 current_start_addr; //当前显示到什么位置
    t_32 origal_addr; //当前控制台对应显存位置
    t_32 v_mem_limit; //当前控制台占的显存大小
    t_32 cursor;    //当前光标位置
}CONSOLE;

#define DEFAULT_CHAR_COLOR	0x07	/* 0000 0111 黑底白字 */

#endif//CONSOLE_H