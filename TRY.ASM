.model tiny
.code 
org 100h
.186

VIDEOSEG 	equ 0b800h

start:		in al, 61h

		mov bx, VIDEOSEG

		mov es, bx
		mov di, 160*5+40

		mov es:[di], al

next:		in al, 60h
		mov es:[di], al
		mov byte ptr es:[di+1], 01100000b

		cmp al, 1
		jne next 

		mov ax, 4c00h
		int 21h

end 		start

