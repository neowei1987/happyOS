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

PUBLIC int is_current_console(CONSOLE* p_console) {
    return p_console == (console_table + nr_current_console);
}

PUBLIC void out_char(CONSOLE* p_console, char ch) {
    u8* p_vmem = (u8*)(V_MEM_BASE + disp_pos);
    *p_vmem++ = ch;
    *p_vmem++ = DEFAULT_CHAR_COLOR;
    disp_pos += 2;

    set_cursor(disp_pos / 2);
}