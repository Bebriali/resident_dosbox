.model tiny
.code
org 100h

start:  call GetPassWrd
        call CmpPassWrd

        mov ax, 4c00h
        int 21h

;=====================================================
;GetPassword
;Entry: None
;Exit:  None
;Distr: None
;-----------------------------------------------------
GetPassWrd  proc

        mov si, cmd_seg_ptr
        xor di, di

GETTING:
        mov al, [si]
        mov [user_enter + di], al
        inc di
        inc si

        cmp al, '$'
        jne GETTING


        ret
        endp
;=====================================================

;=====================================================
;CmpPassword
;Entry: None
;Exit:  None
;Distr: None
;-----------------------------------------------------
CmpPassWrd     proc
        mov di, offset password
        mov si, offset user_enter

COMPARE:
        mov al, [si]
        cmp al, [di]
        jne WRNG_PSSWRD
        inc di
        inc si

        cmp byte ptr [di], '$'
        jne COMPARE
        ;cmp byte ptr [si], '$'
        ;jne COMPARE

        jmp CRCT_PSSWRD

WRNG_PSSWRD:
        mov ah, 09h
        mov dx, offset wr_pwrd
        int 21h

        jmp END_CMP

CRCT_PSSWRD:
        mov ah, 09h
        mov dx, offset rt_pwrd
        int 21h

        jmp END_CMP

END_CMP:
        ret
        endp

;-----------------------------------------------------
;messages
;- - - - - - - - - - - - - - - - - - - - - - - - - - -
wr_pwrd     db 'access denied$'
col_wr      db 00001100b            ;light red   on black background
rt_pwrd     db 'access granted$'
col_rt      db 00001010b            ;light green on black background
;-----------------------------------------------------
;constants
;- - - - - - - - - - - - - - - - - - - - - - - - - - -
user_enter  db 10 dup(?)
password    db 'crack_passcontroller$'
cmd_seg_ptr equ 82h
;-----------------------------------------------------
;variables
;- - - - - - - - - - - - - - - - - - - - - - - - - - -

end     start
