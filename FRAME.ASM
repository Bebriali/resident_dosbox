.model tiny
.code
org 100h

start: 		mov si, 81h

		call GetValue		;getting width
		mov cx, ax

		push cx
		call GetValue		;gettting height
		mov bp, ax
		pop cx

		call ChFrTr		;Choose Frame Translation

		mov ax, 80d		;80d = video width
		mov bx, cx
		call CalcSlip
		shl ax, 1
		add di, ax

		mov ax, 25d		;25d = video height
		mov bx, bp
		;call CalcSlip
		sub ax, bx
		shr ax, 1

		shl ax, 4
		push ax
		shl ax, 3
		add di, ax
		pop ax
		shl ax, 1
		add di, ax

		mov bx, 0b800h		;0b800h = videosegment
		mov es, bx

		call ShowFrame

		pop si			;!!!!!!!!!!!!!!!!!!!
		call ChMgTr		;Choose Message Translation

		call CenterString
		;sub si, cx

		mov bx, 0b800h
		mov es, bx
		call ShowMessage


		mov ax, 4c00h
		int 21h

;=====================================================
;Choose Message Translation
;Enter: None
;Exit:	None
;Destr: None
;-----------------------------------------------------
ChMgTr		proc
		push cx
		call GetValue
		pop cx

		cmp ax, 00
		je FROM_CMD
		jmp FROM_DATA

FROM_CMD:	add si, 1
		ret
FROM_DATA:	mov si, offset Message
		ret

		endp
;=====================================================

;=====================================================
;ShowFrame
;Enter: None
;Exit:	None
;Destr: None
;-----------------------------------------------------
ShowFrame	proc

		push cx
		call ShowString
		pop cx

		add bx, 0ah
		mov es, bx

nextstr:	push cx
		push si
		call ShowString
		pop si
		pop cx

		add bx, 0ah
		mov es, bx

		dec bp
		test bp, bp
		jne nextstr

		add si, 3

		push cx
		call ShowString
		pop cx


		ret
		endp

;=====================================================
;Calculate Slip
;Enter: AX = CONST
;		BX = variable size
;Exit: 	AX = slip
;Distr: AX
;-----------------------------------------------------
CalcSlip	proc
		sub ax, bx
		shr ax, 2		;dividing by 2 and rounding to even
		shl ax, 1		;

		ret
		endp
;=====================================================
;Choose Frame Translation
;Enter:	None
;Exit: 	None
;Destr: AX
;-----------------------------------------------------
ChFrTr	proc

		push cx
		call GetValue
		pop cx
		cmp ax, 00h
		je CMD_STYLE
		cmp ax, 01h
		je STYLE_1
		cmp ax, 02h
		je STYLE_2
		cmp ax, 03h
		je STYLE_3


CMD_STYLE:	inc si
		ret
STYLE_1:	push si
		mov si, offset Style1
		ret
STYLE_2:	push si
		mov si, offset Style2
		ret
STYLE_3:	push si
		mov si, offset Style3
		ret

		endp
;=====================================================

;=====================================================
;GetValue
;Entry:	SI = addr
;Exit: 	AX
;Destr: CX
;-----------------------------------------------------
GetValue	proc

		xor ax, ax

		mov cx, [si]
		cmp cl, ' '
		jne Get

Skip:		inc si
		mov cx, [si]
		cmp cl, ' '
		je Skip

Get:		add ch, -30h		;'0' equals to 30h in ASCII
		add cl, -30h		;
		mov al, cl
		shl al, 4
		add al, ch

		add si, 2

		endp
		ret
;=====================================================

;=====================================================
;ShowChar
;Entry: AL = char to write
;	AH = color attr
;	CX = place
;Exit:  None
;Destr: ES BX
;-----------------------------------------------------
ShowChar 	proc
		mov bx, 0b800h
		add bx, di
		mov es, bx
		shr cl, 1
		mov bl, cl
		mov bh, 00h
		shl cl, 1
		mov es:[bx], al
		ret
		endp
;=====================================================

;=====================================================
;ShowString
;Entry: AX = symbol
;	CH = times
;       CI = min
;Exit:  None
;Destr: CL
;-----------------------------------------------------
ShowString 	proc
		push di
		mov ah, 00001111b

		mov al, [si]
		mov es:[di], al
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
;CenterString
;Enter: SI = str_addr
;Exit:	DI = VIDEO_ADDR
;Distr: CX, DI
;-----------------------------------------------------
CenterString 	proc

		call StrLen

		xor di, di

		;(video_width - len_size)/2
		;cx = len_size
		;VW = video_width
		sub cx, 80d
		neg cx
		shr cx, 1
		shl cx, 1

		mov di, cx
		add di, 160 * 13

		ret
		endp
;=====================================================
;=====================================================
;ShowMessage
;Entry:	None
;Exit:	None
;Distr:	None
;-----------------------------------------------------
ShowMessage	proc

		mov al, [si]

NChar:		mov byte ptr es:[di], al
		mov byte ptr es:[di+1], 01110000b
		inc si
		add di, 2
		mov al, [si]
		cmp al, 24h
		jne NChar

		ret
		endp
;=====================================================

;=====================================================
;StrLen
;Entry:	SI = str addr
;	DS =
;Exit:	CX = string length
;Distr: CX, DI, AX, ES
;-----------------------------------------------------
StrLen		proc
		mov ax, ds
		mov es, ax
		mov di, si
		mov al, '$'

		xor cx, cx
		dec cx

		repne scasb
		neg cx
		sub cx, 2

		ret
		endp
;=====================================================

Message:	db 'happy birthday!$'
Style1: 	db 201d, 205d, 187d, 186d, 00d, 186d, 200d, 205d, 188d, '$'
Style2: 	db 'zovl lzvz$'
Style3:		db 03, 03, 03, 03, 00, 03, 03, 03, 03

end 		start
