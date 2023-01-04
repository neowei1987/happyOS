#include "types.h"
#include "const.h"
#include "protect.h"
#include "global.h"

PUBLIC char * itoa(char * str, int num)
{
	char *	p = str;
	char	ch;
	int	i;
	t_bool	flag = FALSE;

	*p++ = '0';
	*p++ = 'x';

	if(num == 0){
		*p++ = '0';
	}
	else{	
		for(i=28;i>=0;i-=4){
			ch = (num >> i) & 0xF;
			if(flag || (ch > 0)){
				flag = TRUE;
				ch += '0';
				if(ch > '9'){
					ch += 7;
				}
				*p++ = ch;
			}
		}
	}

	*p = 0;

	return str;
}


/*======================================================================*
                               disp_int
 *======================================================================*/
PUBLIC void disp_int(int input)
{
	char output[16];
	itoa(output, input);
	disp_str(output);
}

PUBLIC void delay(int time) {
	int i, j, k;
	for (k = 0; k < time; ++k) {
		for (i = 0;i < 10; i++) {
			for (j = 0; j < 100000; j++) {}
		}
	}
}

/*======================================================================*
                                vsprintf
 *======================================================================*/
int vsprintf(char *buf, const char *fmt, va_list args)
{
	char*	p;
	char	tmp[256];
	va_list	p_next_arg = args;

	for (p=buf;*fmt;fmt++) {
		if (*fmt != '%') {
			*p++ = *fmt;
			continue;
		}

		fmt++;

		switch (*fmt) {
		case 'x':
			itoa(tmp, *((int*)p_next_arg));
			strcpy(p, tmp);
			p_next_arg += 4;
			p += strlen(tmp);
			break;
		case 's':
			break;
		default:
			break;
		}
	}

	return (p - buf);
}

int printf(const char *fmt, ...)
{
	int i;
	char buf[256];

	//debug_trap();

	va_list arg = (va_list)((char*)(&fmt) + 4);        /* 4 是参数 fmt 所占堆栈中的大小 */
	i = vsprintf(buf, fmt, arg);
	write(buf, i);

	return i;
}
