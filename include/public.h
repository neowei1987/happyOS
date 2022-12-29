#ifndef PUBLIC_H
#define PUBLIC_H

#include "types.h"
#include "const.h"

PUBLIC void	out_byte(t_port port, t_8 value);
PUBLIC t_8	in_byte(t_port port);
PUBLIC void	disp_str(char * info);
PUBLIC void	disp_color_str(char * info, int color);


PUBLIC void	init_prot();

PUBLIC	void* memcpy(void* p_dst, void* p_src, int size);

#endif//PUBLIC_H