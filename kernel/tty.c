#include "public.h"
#include "keyboard.h"
#include "const.h"
#include "global.h"

PRIVATE void init_tty(TTY* p_tty)  {
    p_tty->in_count = 0;
    p_tty->p_inbuf_head = p_tty->p_inbuf_tail = p_tty->in_buf;
    init_screen(p_tty);
}

PRIVATE void tty_do_read(TTY* p_tty) {
    if (is_current_console(p_tty->p_console)) {
        keyboard_read(p_tty);
    }
}

PRIVATE void tty_do_write(TTY* p_tty) {
    if (p_tty->in_count <= 0) {
        return;
    }

    char ch = *(p_tty->p_inbuf_tail);
    p_tty->p_inbuf_tail++;
    if (p_tty->p_inbuf_tail == p_tty->in_buf + TTY_IN_BYTES) {
        p_tty->p_inbuf_tail = p_tty->in_buf;
    }
    p_tty->in_count--;
    out_char(p_tty->p_console, ch);
}

PUBLIC void tty_task () {
    init_keyboard();
    for (int i = 0; i < NR_CONSOLES; ++i) {
        init_tty(tty_table + i);
    }
    select_console(0);

    while (1) {
        for (int i = 0; i < NR_CONSOLES; ++i) {
            tty_do_read(tty_table + i);
            tty_do_write(tty_table + i);
        }
    }
}


/*======================================================================*
                           in_process
*======================================================================*/
PUBLIC void in_process(TTY* p_tty, t_32 key)
{   char output[2] = {'\0', '\0'};
	if (!(key & FLAG_EXT)) { //将键盘输入的内容放入到缓冲区中
        if (p_tty->in_count < TTY_IN_BYTES) {
            *(p_tty->p_inbuf_head) = key;
            p_tty->p_inbuf_head++;
            if (p_tty->p_inbuf_head == p_tty->in_buf + TTY_IN_BYTES) {
                p_tty->p_inbuf_head = p_tty->in_buf;
            }
            p_tty->in_count++;
        }
    } else {
        int raw_code = key & MASK_RAW;
        switch(raw_code) {
        case F1:
		case F2:
		case F3:
		case F4:
		case F5:
		case F6:
		case F7:
		case F8:
		case F9:
		case F10:
		case F11:
		case F12:
			if ((key & FLAG_ALT_L) || (key & FLAG_ALT_R)) {	/* Alt + F1~F12 */
				select_console(raw_code - F1);
			}
			break;
		default:
			break;
        }
    }
}

