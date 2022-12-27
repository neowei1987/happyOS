## debug

freedos中的debug无法调试保护模式，那如何办呢？

借助bochs的debug能力，通过xchg bx, bx指令可以让我们的程序中断在bochs的调试环境中

### 分页机制

bochs.out中有很多有用的信息

必须先关闭分页，再关闭分段；否则无法回到实模式

mov ax, cs
mov ds, ax
上面的操作，要求CS指向的段需要有Read权限，否则上面的mov操作会失败

push LenPagingDemoAll
push OffsetPagingDemoProc
push ProcPagingDemo
call MemCpy
add esp, 12

上面的add esp 12操作容易忘记，导致栈被破坏（ret的以后跳到了一个很奇怪的位置）

retf 跨段返回
