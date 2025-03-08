.model tiny
.code
org 100h



start:  mov ax, 0faceh
    mov bx, 0dedah
    mov cx, 0fedah
    mov dx, 0edaah

    push ax bx cx es ds di si bp sp
    call ShowReg
    pop sp bp si di ds es cx bx ax

    mov ax, 4c00h
    int 21h

;=====================================================
;ShowReg
;-----------------------------------------------------
ShowReg		proc

		mov cx, 4d
		mov di, 0

        push sp
        pop bp

		mov cx, [nxt_reg_ptr]		;first pushed in stack register (ax)
		add bp, cx
		mov cx, regs_num
		add bp, 2d

CONT_SHOW:
		sub bp, 2d
		mov bx, word ptr [bp]

		call CalcReg
		call OutReg
		
		mov ax, [str_num]
		add ax, 160d
		mov str_num, ax

		loop CONT_SHOW

		ret
		endp
;=====================================================
hex_num 	db 4 dup(0)

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

LITERA:     add bx, 41h
        sub bx, 0ah
	    jmp SAVE&OUT
DIGIT:      add bx, 30h
        jmp SAVE&OUT

SAVE&OUT:   mov byte ptr [hex_num + di], bl
	    pop bx
        shr bx, 4

		inc di

		loop CONT_SH_REG

END_SH_REG: mov bx, 0b800h
	    mov es, bx
        mov di, 8d

		pop cx

		ret
		endp
;=====================================================

;=====================================================
;Out register
;-----------------------------------------------------
OutReg		proc

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
VIDEOSEG 	equ 0b800h
slip    	equ 4h
regs_num	equ 9d
nxt_reg_ptr dw 12h
str_num		dw 160 * 10
col_num		dw 40d

end     start