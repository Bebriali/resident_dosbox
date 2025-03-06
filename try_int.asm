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
		je STRING

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

STRING:
    push ds                ; save old DS
    push cs
    pop ds                 ; make DS = CS, for reading message correct

    mov bx, 0b800h
    mov es, bx
    mov bx, 160 * 10 + 80

    mov si, offset message

NEXT_LIT:
    mov al, [si]
    mov es:[bx], al
    mov byte ptr es:[bx + 1], 00101111b  ; white text of green background
    inc si
    add bx, 2
    cmp byte ptr [si], '$'  ; '$' — string termination symbol
    jne NEXT_LIT

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


message   db '<3<3<3<3<3<3<3<3<3<3<3<3<3<3<3<3$'
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

