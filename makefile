
######################
# Makefile for Tinix #
######################


# Entry point of Tinix
# It must be as same as 'KernelEntryPointPhyAddr' in load.inc!!!
ENTRYPOINT	= 0x30400

# Offset of entry point in kernel file
# It depends on ENTRYPOINT
ENTRYOFFSET	=   0x400


# Programs, flags, etc.
ASM		= nasm
DASM	= ndisasm
CC		= x86_64-elf-gcc
LD		= x86_64-linux-gnu-ld
ASMBFLAGS	= -I boot/include
ASMKFLAGS	= -I include -f elf32
CFLAGS		= -I include -m32 -c -fno-builtin
LDFLAGS		= -m elf_i386 -n -s -Ttext $(ENTRYPOINT)
DASMFLAGS	= -u -o $(ENTRYPOINT) -e $(ENTRYOFFSET)

# This Program
TINIXBOOT	= boot/boot.bin boot/loader.bin
TINIXKERNEL	= kernel.bin
OBJS		= kernel/kernel.o kernel/start.o kernel/main.o \
			kernel/8259.o kernel/interupt.o kernel/protect.o kernel/syscall.o \
			kernel/clock.o kernel/keyboard.o kernel/tty.o \
			kernel/process.o lib/klib.o lib/memory.o lib/mylib.o \
			kernel/global.o 
DASMOUTPUT	= kernel.bin.asm

# All Phony Targets
.PHONY : everything final image clean realclean disasm all buildimg

# Default starting position
everything : $(TINIXBOOT) $(TINIXKERNEL)

all : realclean everything

final : all clean

image : final img

clean :
	rm -f $(OBJS)

realclean :
	rm -f $(OBJS) $(TINIXBOOT) $(TINIXKERNEL)

disasm :
	$(DASM) $(DASMFLAGS) $(TINIXKERNEL) > $(DASMOUTPUT)

# Write "boot.bin" & "loader.bin" into floppy image "TINIX.IMG"
# We assume that "TINIX.IMG" exists in current folder
img :
	cp -f boot/loader.bin  /Volumes/Untitled
	cp -f kernel.bin  /Volumes/Untitled

boot/boot.bin : boot/boot.asm boot/include/phy_addr.inc boot/include/fat12hdr.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

boot/loader.bin : boot/loader.asm boot/include/phy_addr.inc boot/include/fat12hdr.inc boot/include/pm.inc
	$(ASM) $(ASMBFLAGS) -o $@ $<

$(TINIXKERNEL) : $(OBJS)
	$(LD) $(LDFLAGS) -o $(TINIXKERNEL) $(OBJS)

kernel/start.o : kernel/start.c ./include/types.h ./include/const.h ./include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/clock.o : kernel/clock.c ./include/types.h ./include/const.h ./include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/protect.o : kernel/protect.c ./include/types.h ./include/const.h ./include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/main.o : kernel/main.c include/public.h include/types.h include/const.h \
		include/process.h include/protect.h include/process.h include/protect.h \
		include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/keyboard.o : kernel/keyboard.c include/public.h include/types.h include/const.h \
		include/process.h include/protect.h include/process.h include/protect.h \
		include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/tty.o : kernel/tty.c include/public.h include/types.h include/const.h \
		include/process.h include/protect.h include/process.h include/protect.h \
		include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/process.o : kernel/process.c include/public.h include/types.h include/const.h \
		include/process.h include/protect.h include/process.h include/protect.h \
		include/global.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/interupt.o : kernel/interupt.c ./include/types.h ./include/const.h ./include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/global.o : kernel/global.c ./include/types.h ./include/const.h ./include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

lib/mylib.o: lib/mylib.c include/types.h include/const.h include/protect.h include/types.h include/global.h include/protect.h
	$(CC) $(CFLAGS) -o $@ $<

kernel/kernel.o : kernel/kernel.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

kernel/syscall.o : kernel/syscall.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/klib.o : lib/klib.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<

lib/memory.o : lib/memory.asm
	$(ASM) $(ASMKFLAGS) -o $@ $<
