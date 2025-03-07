.model tiny
.code
org 100h

;=====================================================
start:	jmp main

VIDEOSEG 	equ 0b800h

;=====================================================
new09 	proc
		push ax bx cx es ds di si bp sp

		push cs
		pop ds

		in al, 60h			;gets scan-code of pressed button

		cmp al, 02h			;button '1'\'!' on keyboard
		je FRAME1

		cmp al, 03h			;button '2'\'@' on keyboard
		je FRAME2

		cmp al, 04h			;button '3'\'#' on keyboard
		je SHOW_REGS

		cmp al, 05h			;button '4'\'$' on keyboard
		je A_OUT

		jmp WRONG_BUTTON

;-----------------------------------------------------
;frame to the screen

FRAME1:
		mov si, offset Style1
		jmp VID_PREP
FRAME2:
		mov si, offset Style2
		jmp VID_PREP

VID_PREP:
		mov bx, VIDEOSEG
		mov es, bx
		mov bx, 0

		mov cx, 8
		mov bp, 10
		mov di, 160 * 10 + 50

		call DrawFrame
		jmp END_OF_INT_09H
;-----------------------------------------------------

;-----------------------------------------------------
;mov registers to VIDEOSEG

SHOW_REGS:
		mov bx, VIDEOSEG
		mov es, bx
		xor bx, bx

		call ShowReg
		add bx, 160d

COMMENT *
		push bx
		call ShowReg
		add bx, 160d

		push cx
		call ShowReg
		add bx, 160d

		push dx
		call ShowReg
		add dx, 160d
*

		jmp END_OF_INT_09H
;-----------------------------------------------------

;-----------------------------------------------------
;symbol A to the screen

A_OUT:	mov bx, VIDEOSEG
		mov es, bx
		xor bx, bx

		mov word ptr es:[bx], 'A'
		mov byte ptr es:[bx+1], 11010010b
;-----------------------------------------------------

WRONG_BUTTON:
		in al, 61h
		or al, 80h

		out 61h, al
		and al, 7fh
		out 61h, al
		mov al, 20h
		out 20h, al

END_OF_INT_09H:
		pop sp bp si di ds es cx bx ax

;-----------------------
		db 0eah
oldoffs09h 	dw 0
oldsegm09h	dw 0
;-----------------------

		iret
		endp
;=====================================================


;=====================================================
;ShowReg
;-----------------------------------------------------
ShowReg		proc

        ;push sp
        ;add sp, 10d
		mov cx, 4d
		mov di, 0

		mov bx, word ptr [bp + 4]
CONT_SH_REG:
		cmp bx, 0h
		je END_SH_REG

        push bx
		and bx, 0fh
	    cmp bx, 9h
        ja LITERA
	    jmp DIGIT

LITERA:     add bx, 41h
        sub bx, 0ah
	    jmp SAVE&OUT
DIGIT:      add bx, 30h
        jmp SAVE&OUT

SAVE&OUT:   mov byte ptr [hex_num + di], bl
	    pop bx
        shr bx, 4
	    push bx

		inc di
        inc di

		loop CONT_SH_REG

END_SH_REG: mov bx, 0b800h
	    mov es, bx
        mov di, 8d


CONT_OUT:   mov bl, [hex_num + di]
        neg di
	    mov es:[slip + di], bl
		neg di
		dec di
		dec di
		cmp di, -2h
		jne CONT_OUT

		;sub sp, 2

		;pop sp

		ret
		endp
;=====================================================
slip    	equ 6h
hex_num 	db 4 dup(0)

;=====================================================
;DrawFrame
;-----------------------------------------------------
DrawFrame	proc

		mov ax, VIDEOSEG
		mov es, ax
		mov bx, 0

		push cx
		call ShowString
		pop cx

		add di, 160d
		;add bx, 0ah
		;mov es, bx

nextstr:	push cx
		push si
		call ShowString
		pop si
		pop cx

		add di, 160d
		;add bx, 0ah
		;mov es, bx

		dec bp
		test bp, bp
		jne nextstr

		add si, 3

		push cx
		call ShowString
		pop cx

		add di, 160d

		ret
		endp
;=====================================================

;=====================================================
;ShowString
;-----------------------------------------------------
ShowString	proc

		push di
		mov ah, 00001111b
		mov al, [si]
		mov es:[di],   al
		mov es:[di+1], ah

		add di, 2

		inc si
		mov al, [si]

next:		mov es:[di], al
		mov es:[di+1], ah
		add di, 2
		loop next

		inc si
		mov al, [si]

		mov es:[di], al
		mov es:[di+1], ah
		add di, 2

		inc si

		pop di

		ret
		endp
;=====================================================

Style1: 	db 201d, 205d, 187d, 186d, 00d, 186d, 200d, 205d, 188d, '$'
Style2:		db  03d,  03d,  03d,  03d, 00d,  03d,  03d,  03d,  03d, '$'

EOP:

main:	cli			;turn off hardware interrupts
		mov ah, 35h
		mov al, 9 	;we want the vector(memory location) of int 09h	(ex:[bx])
		int 21h

		mov oldoffs09h, bx
		mov oldsegm09h, es

		xor ax, ax
		mov es, ax
		mov bx, 09h * 4

		mov word ptr es:[bx], offset new09
		push cs
		pop ax
		mov es:[bx+2], ax

		sti

		mov ax, 3100h

		mov dx, offset EOP

		int 21h

end 		start

