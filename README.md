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

异常中断

异常源于内部

中断源于外部

mov al, 011h ; 00010001b; 边缘触法，启用级联，8字节中断向量，需要ICW4

调试了很久，发现011h错误的写成了011;
结果很奇怪，时钟中断没有被触发

常用命令：

bximage

dd if=boot/boot.bin of=a.img bs=512 count=1 conv=notrunc

cp loader.bin /Volumes/Untitled

交叉编译问题

安装交叉编译工具链
brew install x86_64-linux-gnu-binutils

编译出32位机器上的ELF o
nasm -f elf32 -o kernel_i386_32.o kernel.asm
链接，-m表示模拟器模式 elf_i386 也就是32位ELF
x86_64-linux-gnu-ld -m elf_i386 -n -s -Ttext 0x30400 -o kernel.bin kernel_i386_32.o
下面的-n参数，会忽略4k对齐要求，大幅降低elf文件大小【耗费半天】

2023.1.1 07:59

不知何故，程序运行一段时间后，EIP、ESP等寄存器会被覆盖成“随机数据”，导致运行时出现GP。

实验半小时，未能复现问题. 

