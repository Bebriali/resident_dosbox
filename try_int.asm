.model tiny
.code
org 100h

;=====================================================
start:	jmp main

;-----------------------------------------------;
;	some constants are stored here		;
;-----------------------------------------------;
VIDEOSEG 	equ 0b800h
;-----------------------------------------------;

;=====================================================
new09 	proc
		push ax bx cx es

		in al, 60h			;gets scan-code of pressed button

		cmp al, 02h			;button '1'\'!' on keyboard
		je A_OUT

		cmp al, 03h			;button '2'\'@' on keyboard
		je FRAME

		jmp WRONG_BUTTON

;-----------------------------------------------------
;symbol A to the screen

A_OUT:	mov bx, 0b800h
		mov es, bx
		mov bx, 160 * 10 + 80

		mov word ptr es:[bx], 'A'
		mov byte ptr es:[bx+1], 11010010b

		jmp END_OF_INT_09H
;-----------------------------------------------------

;-----------------------------------------------------
;frame to the screen

FRAME:
    push ds                ; save old DS
    push cs
    pop ds                 ; make DS = CS, for reading message correct

    mov bx, 0b800h
    mov es, bx

	mov cx, 8
	mov bp, 10
	mov di, 160 * 10 + 50

    mov si, offset message

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

    pop ds                 ; reset old DS
    jmp END_OF_INT_09H
;-----------------------------------------------------

END_OF_INT_09H:
		in al, 61h
		or al, 80h

		out 61h, al
		and al, 7fh
		out 61h, al

		mov al, 20h
		out 20h, al


WRONG_BUTTON:	pop es cx bx ax

;-----------------------
		db 0eah
oldoffs09h 	dw 0
oldsegm09h	dw 0
;-----------------------

		iret
		endp
;=====================================================

;=====================================================
;ShowString
;-----------------------------------------------------
ShowString	proc

		push di
		mov ah, 00101111b
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


message   db '/=\| |\=/$'
;----------------------------------------------------|
EOP:		; end of interrupt instructions			 |
;====================================================|
heart 	  db '♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥$'
;=====================================================
;main
;-----------------------------------------------------
main:	cli			;turn off hardware interrupts

		mov ah, 35h
		mov al, 9 	;we need the vector(memory location) of int 09h	(es:[bx])
		int 21h

		mov oldoffs09h, bx	;remember old interrupt segment
		mov oldsegm09h, es

		xor ax, ax
		mov es, ax
		mov bx, 09h * 4

		mov word ptr es:[bx], offset new09	;put new interrupt segment
		push cs
		pop ax
		mov es:[bx+2], ax

		sti			;turn on hardware interrupts

		mov ax, 3100h		;command for staying resident
		mov dx, offset EOP
		int 21h
;=====================================================

end 		start

