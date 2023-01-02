#ifndef TTY_H
#define TTY_H

#include "types.h"

#define TTY_IN_BYTES 256 
struct s_console;

typedef struct s_tty {
    t_32 in_buf[TTY_IN_BYTES];
    t_32* p_inbuf_head;
    t_32* p_inbuf_tail;
    int in_count;
    struct s_console* p_console;
}TTY;
#endif//TTY_H