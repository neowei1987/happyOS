#include "const.h"
#include "global.h"
#include "protect.h"

//段名称 求 绝对地址
PUBLIC u32 seg2phys(u16 seg) {
    DESCRIPTOR* p_dest = gdt + (seg >> 3);
    return p_dest->base_high << 24 | p_dest->base_mid << 16 | p_dest->base_low;
}

/*======================================================================*
                             init_descriptor
 *----------------------------------------------------------------------*
 初始化段描述符
 *======================================================================*/
PRIVATE void init_descriptor(DESCRIPTOR* p_desc, u32 base, u32 limit, u16 attribute)
{
    p_desc->limit_low = limit & 0x0FFFF;
    p_desc->base_low = base & 0x0FFFF;
    p_desc->base_mid = (base >> 16) & 0x0FF;
    p_desc->attr1 = attribute & 0xFF;
    p_desc->limit_high_attr2 = ((limit >> 16) & 0x0F) | (attribute >> 8) & 0xF0;
    p_desc->base_high = (base >> 24) & 0x0FF;
}

/*======================================================================*
                            init_descriptors
 *----------------------------------------------------------------------*
 描述符相关初始化 
 *======================================================================*/
PUBLIC void init_descriptors()
{
    //中断描述符 
	init_idt();

    //填充TSS描述符
    memset(&tss, 0, sizeof(tss));
    tss.ss0 = SELECTOR_KERNEL_DS;
    init_descriptor(gdt + INDEX_TSS, 
        //0,
        vir2phys(seg2phys(SELECTOR_KERNEL_DS), &tss), 
        sizeof(tss), 
        DA_386TSS);
    tss.iobase = sizeof(tss); //没有IO许可位图

    //填充GDT中，进程的LDT描述符
	init_descriptor(gdt + INDEX_LDT_FIRST,
        //0,
        vir2phys(seg2phys(SELECTOR_KERNEL_DS), proc_table[0].ldts), 
        LDT_SIZE * sizeof(DESCRIPTOR) - 1, 
        DA_LDT);
}


