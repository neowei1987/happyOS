#include "console.h"
#include "global.h"

PRIVATE void set_cursor(int cursor) {
  disable_int();
    out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_CURSOR_H);
    out_byte(CRTC_DATA_REG, (cursor >> 8 ) & 0xFF);
        out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_CURSOR_L);
    out_byte(CRTC_DATA_REG, cursor & 0xFF);
    enable_int();
}

PRIVATE set_video_start_addr(t_32 addr) {
    disable_int();
    out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_START_ADDR_H);
    out_byte(CRTC_DATA_REG, ((addr) >> 8) & 0xFF);
    out_byte(CRTC_ADDR_REG, CRTC_DATA_IDX_START_ADDR_L);
    out_byte(CRTC_DATA_REG, (addr) & 0xFF);
    enable_int();
}


PRIVATE void flush(CONSOLE* p_console) {
    if (is_current_console(p_console)) {
        set_video_start_addr(p_console->current_start_addr);
        set_cursor(p_console->cursor);
    }
}

PUBLIC void init_screen(TTY* p_tty)  {
    int idx_tty = p_tty - tty_table;
    p_tty->p_console = console_table + idx_tty;

    int v_mem_size = V_MEM_SIZE >> 1; //显存总大小，WORD
    int console_vmem_size = v_mem_size / NR_CONSOLES;

    p_tty->p_console->origal_addr = idx_tty * console_vmem_size;
    p_tty->p_console->v_mem_limit = console_vmem_size;
    p_tty->p_console->current_start_addr = p_tty->p_console->origal_addr;

    p_tty->p_console->cursor = p_tty->p_console->origal_addr;

    if (idx_tty == 0) {
        p_tty->p_console->cursor = disp_pos / 2;
        disp_pos = 0;
    } else {
        out_char(p_tty->p_console, idx_tty + '0');
        out_char(p_tty->p_console, '#');
    }
    set_cursor(p_tty->p_console->cursor);
}


PUBLIC void select_console(int nr_console) {
    if (nr_console < 0 || nr_console >= NR_CONSOLES) {
        return;
    }

    nr_current_console = nr_console;
    flush(console_table + nr_console);
}

PUBLIC int is_current_console(CONSOLE* p_console) {
    return p_console == (console_table + nr_current_console);
}

PUBLIC void out_char(CONSOLE* p_console, char ch) {
    u8* p_vmem = (u8*)(V_MEM_BASE + p_console->cursor * 2);
    switch (ch) {
        case '\n':
        if (p_console->cursor < p_console->origal_addr + p_console->v_mem_limit - SCREEN_WIDTH) {
            p_console->cursor = p_console->origal_addr + SCREEN_WIDTH * ((p_console->cursor - p_console->origal_addr) / SCREEN_WIDTH + 1);
        }
        break;
        case '\b':
        if (p_console->cursor > p_console->origal_addr) {
            p_console->cursor--;
            *(p_vmem-2) = ' ';
            *(p_vmem-1) = DEFAULT_CHAR_COLOR;
        }
        break;
        default:
        if (p_console->cursor < p_console->origal_addr + p_console->v_mem_limit - 1) {
             *p_vmem++ = ch;
             *p_vmem++ = DEFAULT_CHAR_COLOR;
             p_console->cursor++;
         }
        break;
    }

    while (p_console->cursor >= p_console->current_start_addr + SCREEN_SIZE) {
        scroll_screen(p_console, SCROLL_SCREEN_DOWN);
    }


    flush(p_console);
}

PUBLIC void scroll_screen(CONSOLE* p_console, int direction) {
    if (direction == SCROLL_SCREEN_UP) {
        if (p_console->current_start_addr > p_console->origal_addr) {
            p_console->current_start_addr -= SCREEN_WIDTH;
        }
    }
    else if (direction == SCROLL_SCREEN_DOWN) {
        if (p_console->current_start_addr + SCREEN_SIZE < p_console->origal_addr + p_console->v_mem_limit) {
            p_console->current_start_addr += SCREEN_WIDTH;
        }
    }

}

