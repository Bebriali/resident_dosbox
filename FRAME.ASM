.model tiny
.code
org 100h

start: 		mov si, [cmd_seg]

		push cx
		call GetValue		;getting width
		mov [frame_w], ax
		pop cx

		push cx
		call GetValue		;gettting height
		mov [frame_h], ax
		pop cx

		call ChFrTr		;Choose Frame Translation

		mov ax, 80d		;80d = video width
		mov bx, [frame_w]
		call CalcSlip
		shl ax, 1
		add di, ax

		mov ax, 25d		;25d = video height
		mov bx, [frame_h]
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

		mov bx, VIDEOSEG
		mov es, bx

		call ShowFrame

		cmp [type_stream], 'c'
		jne MOV_TO_CMD
		jmp STAY_IN_CMD

MOV_TO_CMD:
		mov si, [cmd_seg]
		jmp MESSAGE_OUT
STAY_IN_CMD:
		inc si
		jmp MESSAGE_OUT

MESSAGE_OUT:
		call ChMgTr		;Choose Message Translation

		call CenterString
		;sub si, cx

		mov bx, VIDEOSEG
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

		cmp ax, 00h
		je FROM_CMD
		jmp FROM_DATA

FROM_CMD:	add si, 1
		jmp EO_CH_MG_TR
FROM_DATA:	mov si, offset Message
		jmp EO_CH_MG_TR

EO_CH_MG_TR:
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

		;push cx
		mov cx, [frame_h]

nextstr:	push si
		call ShowString
		pop si

		add bx, 0ah
		mov es, bx

		loop nextstr

		add si, 3

		push cx
		call ShowString
		pop cx


		ret
		endp
;=====================================================

;=====================================================
;ShowString
;Entry: AX = symbol
;		CH = times
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

		push cx
		mov cx, [frame_w]

next:		mov es:[di], al
		mov es:[di+1], ah
		add di, 2
		loop next

		pop cx

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

		mov cmd_seg, si

		cmp ax, 00h
		je CMD_STYLE

		cmp ax, 01h
		je STYLE_1

		cmp ax, 02h
		je STYLE_2

		cmp ax, 03h
		je STYLE_3


CMD_STYLE:	inc si
		mov type_stream, 'c'
		jmp EO_CH_FR_TR

STYLE_1:	mov cmd_seg, si
		mov type_stream, 's'
		mov si, offset Style1
		jmp EO_CH_FR_TR

STYLE_2:	mov cmd_seg, si
		mov type_stream, 's'
		mov si, offset Style2
		jmp EO_CH_FR_TR

STYLE_3:	mov cmd_seg, si
		mov type_stream, 's'
		mov si, offset Style3
		jmp EO_CH_FR_TR

EO_CH_FR_TR:
		ret
		endp
;=====================================================

;=====================================================
;GetValue
;Entry:	SI = addr
;Exit: 	AX = value
;Destr: CX
;-----------------------------------------------------
GetValue	proc

		xor ax, ax
		xor cx, cx

Skip:	mov cl, [si]
		inc si

		cmp cl, ' '
		je Skip

Get:
		cmp cl, '9'
		jna DIG_CASE
LIT_CASE:
		sub cl, 21h
DIG_CASE:
		sub cl, 30h
		shl ax, 4
		add ax, cx

		mov cl, [si]

		inc si
		cmp cl, ' '
		jne Get

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

Message	db 'happy birthday!$'
Style1 	db 201d, 205d, 187d, 186d, 00d, 186d, 200d, 205d, 188d, '$'
Style2 	db 'zovl lzvz$'
Style3		db 03, 03, 03, 03, 00, 03, 03, 03, 03, '$'

VIDEOSEG 	equ 0b800h
cmd_seg		dw  81h
type_stream db  ?
frame_w		dw  ?
frame_h		dw  ?

end 		start
