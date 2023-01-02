#include "public.h"

PUBLIC void tty_task () {
    while (1) {
        keyboard_read();
    }
}