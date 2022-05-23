org 0x1200

mov dx, msg.onstart
mov ah, 0x09
int 0x21
jmp _start

_start:
	mov dx, prompt
	mov ah, 0x09
	int 0x21
	mov bx, buffer
	mov ah, 0x0A
	int 0x21
	cmp byte [buffer], 0
	je _start
	mov ah, 0xF0
	mov dx, buffer
	int 0x21
	mov dx, msg.endl
	mov ah, 0x09
	int 0x21
	jmp _start

prompt: db "A>$"

msg:
.onstart: db 13,10,"LK-DOS COMMAND.COM",13,10,'$'
.endl: db 13,10,'$'
buffer: times (40) db '$'
times (512*5-($-$$)) db 0
