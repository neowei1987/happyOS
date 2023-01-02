#include "public.h"
#include "keyboard.h"

PUBLIC void tty_task () {
    while (1) {
        keyboard_read();
    }
}

/*======================================================================*
                           in_process
*======================================================================*/
PUBLIC void in_process(t_32 key)
{
	char output[2] = {'\0', '\0'};
	if (!(key & FLAG_EXT)) {
		output[0] = key & 0xFF;
		disp_str(output);
	}
}

