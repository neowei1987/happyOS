
#include "const.h"
#include "types.h"
#include "protect.h"
#include "global.h"

PUBLIC void cstart() {
    disp_str("\n\n\n\n\n\n\n\n\n\n\n-----\"cstart\" begins-----\n");
    memcpy((void*)gdt, 
    (void*)(*((t_32*)(gdt_ptr + 2))),
    *((t_16*)gdt_ptr)
    );

    disp_str("-----Init GDT-----\n");
    t_16* p_gdt_limit = (t_16*)(gdt_ptr);
	t_32* p_gdt_base  = (t_32*)(gdt_ptr + 2);
	*p_gdt_limit = GDT_SIZE * sizeof(DESCRIPTOR);
	*p_gdt_base  = (t_32)gdt;

    disp_str("-----Init IDT-----\n");
    t_16* p_idt_limit = (t_16*)(idt_ptr);
	t_32* p_idt_base  = (t_32*)(idt_ptr + 2); 
    *p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
    *p_idt_base = (t_32)idt;

    disp_str("-----Init descriptor-----\n");
    init_descriptors();

    disp_str("-----\"cstart\" ends-----\n");
}