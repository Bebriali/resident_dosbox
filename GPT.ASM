.model tiny
.code
org 100h

start:
    cli
    mov ah, 35h
    mov al, 8          ; Get INT 8 vector
    int 21h
    mov word [old8h], bx
    mov word [old8h+2], es  ; Save old INT 8 handler

    mov dx, bx
    push es
    pop ds
    mov al, 0C8h
    mov ah, 25h
    int 21h             ; INT C8 now points to old INT 8

    push cs
    pop ds
    mov dx, offset OURTSRCODE
    mov al, 8
    mov ah, 25h
    int 21h             ; INT 8 now points to our handler

    mov word [counter], 182   ; 182 ticks = 10 seconds

    mov al, 0
    mov dx, 10h         ; Allocate minimal memory for TSR
    mov ah, 31h
    int 21h

OURTSRCODE:
    cli
    push ax bx cx dx ds

    dec word [counter]   ; Decrease the counter
    jnz continue        ; If not zero, keep running

    ; Restore original INT 8h handler before exiting
    mov dx, word [old8h]
    mov ds, word [old8h+2]
    mov al, 8
    mov ah, 25h
    int 21h

    ; Exit the TSR
    mov ah, 4Ch
    int 21h

continue:
    ; Call old INT 8h handler
    pushf
    call dword ptr cs:[old8h]

    mov al, 20h
    out 20h, al        ; Send EOI to PIC
    pop ds dx cx bx ax
    sti

end 		start