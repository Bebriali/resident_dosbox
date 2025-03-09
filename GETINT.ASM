.model tiny
.code
org 100h

;=====================================================
start:	jmp main ;--------->------->-------->-------->------->-TO_MAIN->---....

;=====================================================
new08 	proc
		push ax bx cx dx es ds di si bp sp

		push cs
		pop ds
		
		cmp [operation], 02h		;button '1'\'!' on keyboard
		je FRAME1

		cmp [operation], 03h		;button '2'\'@' on keyboard
		je FRAME2

		cmp [operation], 04h		;button '3'\'#' on keyboard
		je SHOW_REGS

		cmp [operation], 05h		;button '4'\'$' on keyboard
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

		mov cx, 9
		mov bp, 10
		mov di, 160 * 10 + 48

		call DrawFrame
		jmp END_OF_INT_08H
;-----------------------------------------------------

;-----------------------------------------------------
;mov registers to VIDEOSEG

SHOW_REGS:
		mov ax, 0faceh
		mov bx, 0dedah
		mov cx, 0fedah
		mov dx, 0edaah

		push ax bx cx dx es ds di si bp sp

		call ShowReg

		pop sp bp si di ds es dx cx bx ax

		jmp END_OF_INT_08H
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

END_OF_INT_08H:
		pop sp bp si di ds es dx cx bx ax

;-----------------------
; 0eah is a machine code
; of far jump
;- - - - - - - - - - - - 
		db 0eah
oldoffs08h 	dw 0
oldsegm08h	dw 0
;-----------------------

		iret
		endp
;=====================================================


;=====================================================
;ShowReg
;-----------------------------------------------------
ShowReg		proc

		mov cx, 4d
		mov di, 0

	        push sp
        	pop bp

		call OutRegName

		push [str_num]

		mov cx, [nxt_reg_ptr]		;first pushed in stack register (ax)
		add bp, cx
		xor cx, cx

		mov cx, regs_num
		add bp, 2d

CONT_SHOW:
		sub bp, 2d
		mov bx, word ptr [bp]

		call CalcReg
		call OutRegVal
		
		mov ax, [str_num]
		add ax, 160d
		mov str_num, ax

		loop CONT_SHOW

		pop [str_num]

		ret
		endp
;=====================================================

;=====================================================
;Calculate register
;-----------------------------------------------------
CalcReg		proc

		push cx
		mov cx, 4h

CONT_SH_REG:	cmp bx, 0h
		je END_SH_REG

	        push bx
		and bx, 0fh
	        cmp bx, 9h
	       	ja LITERA
	        jmp DIGIT

LITERA:         add bx, 41h
	        sub bx, 0ah
	    	jmp SAVE&OUT
DIGIT:          add bx, 30h
        	jmp SAVE&OUT

SAVE&OUT:       mov byte ptr [hex_num + di], bl
	        pop bx
        	shr bx, 4

		inc di

		loop CONT_SH_REG

END_SH_REG:     mov bx, 0b800h
	        mov es, bx
        	mov di, 8d

		pop cx

		ret
		endp
;=====================================================

;=====================================================
;out register's name
OutRegName	proc
		
		mov si, offset reg_store
		mov cx, regs_num

		mov bx, VIDEOSEG
		mov es, bx
		xor bx, bx
		add bx, [col_num]
		sub bx, 8d
		add bx, [str_num]

NAME_OUT:
		push bx
	STR_OUT:	
		mov al, [si]
		mov es:[bx], al
		add bx, 2d

		inc si
		cmp byte ptr [si], '$'
		jne STR_OUT

		inc si
		pop bx
		add bx, 160d		;move to next string

		loop NAME_OUT		

		ret 
		endp
;=====================================================
;Out register value
;-----------------------------------------------------
OutRegVal	proc

		push cx
		mov cx, 4h
        	mov di, 4h

CONT_OUT:
		push di

        	neg di
		mov al, [hex_num + di + slip]
        	neg di

		;mov si, hex_num
		;add di, si

		shl di, 1
		add di, [str_num]
		add di, [col_num]
	        mov es:[di], al
		sub di, [str_num]
		sub di, [col_num]
		shr di, 1

		pop di 
		dec di
		
		loop CONT_OUT

		pop cx

		ret
		endp
;=====================================================

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

;=====================================================
new09	proc
		push ax bx cx dx es ds di si bp sp

		push cs
		pop ds

		in al, 60h			;gets scan-code of pressed button

		mov operation, al

END_OF_INT_09H:
		in al, 61h
		or al, 80h

		out 61h, al
		and al, 7fh
		out 61h, al
		mov al, 20h
		out 20h, al

		pop sp bp si di ds es dx cx bx ax

;-----------------------
; 0eah is a machine code
; of far jump
;- - - - - - - - - - - - 
		db 0eah
oldoffs09h 	dw 0
oldsegm09h	dw 0
;-----------------------

		iret
		endp
;=====================================================

Style1: 	db 201d, 205d, 187d, 186d, 00d, 186d, 200d, 205d, 188d, '$'
Style2:		db  03d,  03d,  03d,  03d, 00d,  03d,  03d,  03d,  03d, '$'

;-----------------------------------------------------|
;   	*constants or variables are stored here*      |
;- - - - - - - - - - - - - - - - - - - - - - - - - - -|
VIDEOSEG 	equ 0b800h			      ;
slip    	equ 4h				      ;
regs_num	equ 10d				      ;
nxt_reg_ptr     dw 14h				      ;
str_num		dw 160 * 11                           ;
col_num		dw 58d				      ;
hex_num 	db 4 dup(0)			      ;--------------------------|
reg_store	db 'ax = $bx = $cx = $dx = $es = $ds = $di = $si = $bp = $sp = $';							  ;
						      ;--------------------------|
operation   db  ?		                      ;
;-----------------------------------------------------|

EOP:

main:	;<-------<------<--------<--------<---------<-------<--TO_MAIN-<---....

		mov ah, 35h
		mov al, 9 		;we want the vector(memory location)
						; of int 09h	(ex:[bx])
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

		cli 
		mov ah, 35h
		mov al, 8
		int 21h

		mov oldoffs08h, bx
		mov oldsegm08h, es

		xor ax, ax
		mov es, ax
		mov bx, 08h * 4

		mov word ptr es:[bx], offset new08
		push cs
		pop ax
		mov es:[bx+2], ax
		sti

		mov ax, 3100h

		mov dx, offset EOP

		int 21h
;=====================================================

end 		start

