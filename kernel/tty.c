#include "public.h"
#include "keyboard.h"
#include "const.h"
#include "global.h"

PRIVATE void init_tty(TTY* p_tty)  {
    p_tty->in_count = 0;
    p_tty->p_inbuf_head = p_tty->p_inbuf_tail = p_tty->in_buf;
    p_tty->p_console = console_table + (p_tty - tty_table);
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
    nr_current_console = 0;

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
    }

    /*
	char output[2] = {'\0', '\0'};
	if (!(key & FLAG_EXT)) {
		output[0] = key & 0xFF;
		disp_str(output);

	} else {
        int raw_code = key & MASK_RAW;
		switch(raw_code) {
		case UP: //向上卷15行
			if ((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {	// Shift + Up 
				disable_int();
				out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_START_ADDR_H);
				out_byte(CRTC_DATA_REG, ((80*15) >> 8) & 0xFF);
				out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_START_ADDR_L);
				out_byte(CRTC_DATA_REG, (80*15) & 0xFF);
				enable_int();
			}
			break;
		case DOWN:
			if ((key & FLAG_SHIFT_L) || (key & FLAG_SHIFT_R)) {	// Shift + Down 
			}
			break;
		default:
			break;
		}
    }*/
}

