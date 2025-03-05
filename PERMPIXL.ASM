.model tiny
.code
org 100h

;A TSR which forces one pixel to remain on

start:

mov ah, 0		;set video mode
mov al, 13h 		;320x200 256-color vga
int 10h
;the above three lines just set the video mode

;Get the int vector of int 8

cli		;turn off hardware interrupts

;int 21,36 gets an interrupt vector

mov ah, 35h
mov al, 8 	;we want the vector(memory location) of int 8
int 21h
;ES:BX is now a pointer to the int routine for int 8

;make another interrupt behave like int 8
;by pointing another int at the vector fo rint 8
;we can set an int's vector using int 21,25
;set DS:DX to the desired vector point, set AL to the int number
;then just call int 21h
mov dx, bx
push es
pop ds
;now DS:DX equals whatever ES:BX was
mov al, 0c8h
mov ah, 25h
int 21h
;int c8 now points to the code location of int 8

;set int 8's vector to your own TSR routine.
;need to set DS:DX to point to "OURTSRCODE"
push cs
pop ds ;sets DS to equal the code segment (where this program is running now)
mov dx, offset OURTSRCODE
mov al, 8 		;we want to change the vector point to int 8
mov ah, 25h		;set int-pt vector point
int 21h

;do int 21,31 and we're done
mov al, 0 		;exit code (for batch files)
mov dx, 0ffh		;how much memory is reserved for this TSR
mov ah, 31h		;make this into a TSR
int 21h



OURTSRCODE:

cli 			;disable int's just to be sure in safety

push ax bx cx dx			;preserves AX, BX, CX, etc.
push ds

;here i'll put my code for int-pt
;change the third bit of memory location 40:17 to be zero.
mov ax, 0a000h
mov ds, ax		;start of the VGA vide memory
mov bx, 35100		;location of the pixel on the screen
mov ax, 44h		;yellow
mov [bx], ax
;DONE!

pop ds			;restore ds
pop dx cx bx ax 	;and everything else (AX, BX, etc.)

int 0c8h		;do the old int 8h as well

push ax
mov al, 20h
out 20h, al		;sends an End-Of-Interrupt signal to the 8259 interrupt controller
pop ax

sti			;re-enable hardware interrupts
iret			;return from interrupt (signifies that the interrupt is over)

end			start