all:
	nasm ldr.asm -o bin/ldr.com
	nasm lkfs.asm -o bin/fs.bsc
	nasm command.asm -o bin/command.com
	nasm io.asm -o bin/io.com
	cat bin/ldr.com bin/fs.bsc bin/command.com bin/io.com > dsk.flp
	sudo qemu-system-i386 -fda dsk.flp -nographic
