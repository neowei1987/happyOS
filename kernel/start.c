
#include "const.h"
#include "types.h"
#include "protect.h"


EXTERN void* memcpy(void* dst, void* src, t_32 size);
EXTERN void	disp_str(char * pszInfo);

PUBLIC	t_8			    gdt_ptr[6];	// 0~15:Limit  16~47:Base
PUBLIC	DESCRIPTOR		gdt[GDT_SIZE];

PUBLIC void cstart() {
    disp_str("\n\n\n\n\n\n\n\n\n\n\n-----\"cstart\" begins-----\n");
    memcpy((void*)gdt, 
    (void*)(*((t_32*)(gdt_ptr + 2))),
    *((t_16*)gdt_ptr)
    );

    t_16* p_gdt_limit = (t_16*)(gdt_ptr);
	t_32* p_gdt_base  = (t_32*)(gdt_ptr + 2);
	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR);
	*p_gdt_base  = (t_32)gdt;

    disp_str("-----\"cstart\" ends-----\n");
}