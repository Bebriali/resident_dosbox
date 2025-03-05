.model tiny
.code
org 100h    ; Начало COM-программы

jmp start   ; Прыгаем к основному коду

old_isr    dd 0  ; Переменная для хранения старого обработчика

; === Новый обработчик клавиатуры ===
new_isr:
    push ax
    push es
    mov ax, 0B800h   ; Адрес видеопамяти в текстовом режиме
    mov es, ax
    mov di, 160      ; Позиция (row 1, column 0)
    mov byte [es:di], '!'  ; Вывод символа '!' в (0,0)
    mov byte [es:di+1], 0x0F ; Белый цвет

    pop es
    pop ax
    jmp far [old_isr]  ; Передаём управление стандартному обработчику

; === Установка нового обработчика ===
start:
    cli                ; Отключаем прерывания
    mov ax, 0          ; Сегмент IVT (0000:0000)
    mov es, ax
    mov bx, 9h * 4     ; Смещение для INT 09h (IRQ1)

    ; Сохраняем старый обработчик
    mov word [old_isr], es:[bx]      ; Запоминаем оффсет
    mov word [old_isr + 2], es:[bx+2]; Запоминаем сегмент

    ; Устанавливаем новый обработчик
    mov word es:[bx], new_isr
    mov word es:[bx+2], cs

    sti                ; Включаем прерывания

; Ожидание клавиш (Бесконечный цикл)
wait_key:
    hlt                ; Ожидание прерывания (оптимизация)
    jmp wait_key

; === Восстановление старого обработчика перед выходом ===
restore:
    cli
    mov ax, 0
    mov es, ax
    mov bx, 9h * 4
    mov word es:[bx], word [old_isr]
    mov word es:[bx+2], word [old_isr + 2]
    sti
    ret
