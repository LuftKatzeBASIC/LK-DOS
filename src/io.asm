org 0x900

xor ax, ax
mov es, ax
cli
mov word [132], int0x21				; MS-DOS API
mov word [134], cs
mov word [128], int0x20				; Return to CLI
mov word [130], cs
mov word [160], api
mov word [162], cs
sti
ret

api:
	cmp ah, 0x00
	je 0x1200
	cmp ah, 0x01
	je api_printnull
	iret


int0x20:
	jmp 0x1200

int0x21:
	cmp ah, 0x00
	je 0x1200
	cmp ah, 0x01
	je api_getche
	cmp ah, 0x02
	je api_putch
	cmp ah, 0x03
	je api_getche
	cmp ah, 0x04
	je api_putch
	cmp ah, 0x05
	je api_printer
	cmp ah, 0x06
	je api_directio
	cmp ah, 0x07
	je api_direct_char_inp
	cmp ah, 0x08
	je api_getch
	cmp ah, 0x09
	je api_printdollar
	cmp ah, 0xF0
	je api_printnull
	cmp ah, 0x0a
	je api_readln
	iret

api_readln:
	push bx
	push cx
	push ax
	xor cx, cx
.main:
	xor ax, ax
	int 0x16
	cmp ah, 0x0e
	je .backspace
	cmp ah, 0x1c
	je .enter
	cmp ah, 0x01
	je .escape
	cmp ah, 0x53
	je .backspace
	cmp ax, 0x2e03
	je .ctrlc
	cmp ax, 0x2c1a
	je .ctrlc
	mov ah, 0x0e
	int 0x10
	push ax
	mov byte [bx], al
	pop ax
	inc bx
	inc cx
	jmp .main
.ctrlc:
	pop ax
	pop cx
	pop bx
	jmp ctrl_c

.escape:
	cmp cx, 0x00
        je .main
        dec cx
        dec bx
        mov dx, .backspc
        mov ah, 0x09
        int 0x21
	jmp .escape

.backspace:
	cmp cx, 0x00
	je .main
	dec cx
	dec bx
	mov dx, .backspc
	mov ah, 0x09
	int 0x21
	jmp .main
.enter:
	mov byte [bx], 0
	pop ax
	pop cx
	pop bx
	push dx
	mov dx, .endl
	mov ah, 0x09
	int 0x21
	pop dx
	iret
.backspc: db 8,' ',8,'$'
.endl: db 13,10,'$'

api_printnull:
	push si
	push ax
	mov si, dx
.main:
	mov al, byte [si]
	cmp al, 0
	je .done
	mov ah, 0x0e
	int 0x10
	inc si
	jmp .main
.done:
	pop ax
	pop si
	iret

ctrl_c:
	mov dx, MSG_CTRLC
	mov ah, 0x09
	int 0x21
	jmp 0x1200

api_printdollar:
	push ax
	push si
	mov si, dx
.main:
	mov al, byte [si]
	cmp al, '$'
	je .done
	mov ah, 0x0e
	int 0x10
	inc si
	jmp .main
.done:
	pop si
	pop ax
	mov al, 0x24
	iret


api_directio:
	cmp dl, 0xFF
	je .input
.output:
	push ax
	mov al, dl
	mov ah, 0x02
	int 0x21
	pop ax
	iret
.input:
	xor ax, ax
	int 0x16
	iret

api_direct_char_inp:
	xor ax, ax
	int 0x16
	iret

api_getch:
        xor ax, ax
        int 0x16
        cmp ax, 0x2e03
        je ctrl_c
        cmp ax, 0x2c1a
        je ctrl_c
        iret

api_printer:
	push ax
	mov ah, 0x01
	int 0x17
	mov ah, 0x00
	int 0x17
	pop ax
	iret

api_putch:
	push ax
	mov ah, 0x0e
	int 0x10
	pop ax
	iret

api_getche:
	xor ax, ax
	int 0x16
	push ax
	mov ah, 0x0e
	int 0x10
	pop ax
	cmp ax, 0x2e03			; CTRL+C
	je ctrl_c
	cmp ax, 0x2c1a			; CTRL+Z
	je ctrl_c
	iret



MSG_CTRLC: db 13,10,"Program terminated.",13,10,'$'

times (512*3-($-$$)) db 0
