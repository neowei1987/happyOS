Init8259:
    ;1
    mov al, 011h ; 00010001b; 边缘触法，启用级联，8字节中断向量，需要ICW4
    out 020h, al
    call io_delay 

    out 0A0h, al 
    call io_delay

    ;2

    mov al, 020h ;IRQ0对应中断向量0x20
    out 021h, al 
    call io_delay

    mov al, 028h ;IRQ8对应中断向量0x28
    out 0A1h, al  
    call io_delay

    ;3

    mov al, 004h ; IR2对应从8259
    out 021h, al
    call io_delay

    mov al, 002h ; 从8259对应主的IR2
    out 0A1h,al 
    call io_delay

    ;4

    mov al, 001h 
    out 021h, al
    call io_delay

    out 0A1h, al
    call io_delay

    ; OCW1

    mov al, 11111110b ; 仅仅开启定时器中断
    out 021h, al 
    call io_delay

    mov al, 11111111b 
    out 0A1h, al
    call io_delay

    ret 

io_delay:
    nop 
    nop 
    nop 
    nop 
    ret 

