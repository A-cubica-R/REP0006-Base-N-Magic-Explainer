.MODEL SMALL
.STACK 100h

PUBLIC ToOct

.DATA
num     dw 111111b      ; binary 111111 (decimal 63)
buffer  db 8 dup(0)

.CODE
ORG 100h
start:
    mov ax, @data
    mov ds, ax

    mov ax, num
    lea di, buffer
    call ToOct

    ; print result
    lea dx, buffer
    mov ah, 09h
    int 21h

    mov ah, 4ch
    int 21h

;---------------------------------
; AX = value, DI = buffer
;---------------------------------
ToOct PROC
    push bx
    push cx
    push dx
    mov bx, 8
    mov cx, 0
    mov si, di
    cmp ax, 0
    jne convert
    mov byte ptr [di], '0'
    inc di
    jmp done

convert:
oct_loop:
    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    inc di
    inc cx
    cmp ax, 0
    jne oct_loop

done:
    mov byte ptr [di], '$'

    ; Reverse digits
    mov si, si
    dec di
    dec di
    cmp cx, 1
    jbe skip_reverse
rev_loop:
    mov al, [si]
    mov ah, [di]
    mov [si], ah
    mov [di], al
    inc si
    dec di
    cmp si, di
    jb rev_loop
skip_reverse:
    pop dx
    pop cx
    pop bx
    ret
ToOct ENDP

END start