org 0x7c00
mov [0x630], dl

jmp _start

strcpy:
        push bx
        push si
.main:
        mov al, byte [si]
        mov byte [bx], al
        cmp byte [si], 0
        je .done
        inc si
        inc bx
        jmp .main

.done:
        pop si
        pop bx
        ret

print:
	push si
.main:
	mov al, byte [si]
	cmp al, 0
	je .done
	mov ah, 0x0e
	int 0x10
	inc si
	jmp .main
.done:
	pop si
	ret
strcmp:
        push si
        push bx
.main:
        mov al, byte [bx]
        cmp al, byte [si]
        jne .upper
        cmp al, 0
        je .equ
        inc bx
        inc si
        jmp .main
.upper:
        sub al, 32
        cmp al, byte [si]
        jne .notequ
        inc si
        inc bx
        jmp .main
.equ:
        pop bx
        pop si
        stc
        ret
.notequ:
        pop bx
        pop si
        clc
        ret

Error:
	mov si, .msg
	call print
	xor ax, ax
	int 0x16
	int 0x18

.msg: db 13,10,"Press any key to continue...",13,10,0

non_lkfs:
	mov si, .msg
	call print
	xor ax, ax
	int 0x16
	int 0x19

.msg: db "Non-LKFS disk or disk error.",13,10,"Press any key to try again.",0

DiskError:
	mov si, .msg
	call print
	jmp Error
.msg: db "Disk error",0

notfound:
	mov si, .msg
	call print
	jmp Error
.msg: db "Could not find IO.COM/COMMAND.COM",0

_start:
	xor ax, ax
	mov di, ax
	mov ah, 0x02
	mov al, 12
	mov cl, 2
	mov ch, 0
	mov dh, 0
	mov dl, [0x630]
	xor bx, bx
	mov es, bx
	mov bx, 0x1000
	int 0x13
	jc DiskError
	cmp byte [0x1000], 'S'
	jne non_lkfs
	mov si, msg.endl
	call print
entry:
	mov si, 0x1016
_find:
	mov bx, img
	call strcmp
	jc found
	cmp byte [si], 28
	je notfound
	add si, 28
	jmp _find
	
found:
	cmp byte [si+21], 0
	jne .dir
	xor ax, ax
	mov di, ax
	add si, 25
	mov dh, byte [si]
	inc si
	mov cl, byte [si]
	inc si
	mov al, byte [si]
	mov ah, 0x02
	mov dl, byte [0x630]
	mov ch, 0
	xor bx, bx
	mov es, bx
	mov bx, [address]
	int 0x13
	jc DiskError
	call [address]
	mov si, imgcpy
	mov bx, img
	call strcpy
	mov word [address], 0x1000
	jmp entry
.dir:
	add si, 28
	jmp _find

img: db "IO.COM",0
imgcpy: db "COMMAND.COM",0
address: dw 0x700
msg:
.endl: db 13,10,0
times (510-($-$$)) db 0
dw 0xaa55
