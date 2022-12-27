

freedos中的debug无法调试保护模式，那如何办呢？

借助bochs的debug能力，通过xchg bx, bx指令可以让我们的程序中断在bochs的调试环境中

### 分页机制

bochs.out中有很多有用的信息

必须先关闭分页，再关闭分段；否则无法回到实模式

