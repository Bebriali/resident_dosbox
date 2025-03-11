.model tiny
.code
org 100h

start:

;=====================================================
;GetPassword
;Entry: None
;Exit:  None
;Distr: None
;-----------------------------------------------------
GetPassWrd  proc

        mov si, cmd_seg

        ret
        endp
;=====================================================

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
password    db 'crack_passcontroller$'
cmd_seg     equ 81h
user_enter  db ?
;-----------------------------------------------------
;variables
;- - - - - - - - - - - - - - - - - - - - - - - - - - -

end     start
