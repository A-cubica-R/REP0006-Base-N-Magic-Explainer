;#############################################
; DecToBin.asm — Convierte cadena decimal → binario
;#############################################
.model small
.stack 100h

.data
    ; Cambia aquí la cadena de entrada (siempre termina en '$'):
    bufNumber db '123$', 0

    msgBin     db 'Binario: $'
    newLine    db 13,10,'$'

.code
start:
    ; --- Inicializar DS ---
    mov ax, @data
    mov ds, ax

    ; --- Llamar a StrToNum (dec → AX) ---
    call StrToNum

    ; --- Mostrar salto de línea + leyenda ---
    call PrintNewLine
    lea dx, msgBin
    mov ah, 09h
    int 21h

    ; --- Imprimir AX en binario (16 bits) ---
    mov cx, 16            ; bits a imprimir
    mov bx, 1000000000000000b  ; bit mask inicial (MSB)

PrintBitLoop:
    mov dx, ax
    and dx, bx
    jz  .PrintZero
    mov dl, '1'
    jmp .DoPrint
.PrintZero:
    mov dl, '0'
.DoPrint:
    mov ah, 02h
    int 21h

    shr bx, 1             ; mover máscara al siguiente bit
    loop PrintBitLoop

    ; --- Fin line ---
    call PrintNewLine

    ; --- Salir ---
    mov ah, 4Ch
    int 21h

;---------------------------------
; StrToNum: convierte bufNumber(decimal) → AX
; Cadena: dígitos '0'–'9', terminada en '$'
;---------------------------------
StrToNum PROC
    push si
    xor ax, ax             ; acumulador = 0
    mov si, OFFSET bufNumber

ConvLoop:
    mov dl, [si]
    cmp dl, '$'
    je  ConvDone
    sub dl, '0'            ; dl = valor 0–9

    ; AX = AX * 10 + DL
    mov cx, ax
    mov ax, cx
    mov dx, 0
    mov bx, 10
    mul bx                  ; AX = CX * 10
    add ax, dx              ; DX=0, así que ignorable
    mov dh, 0               ; asegurar parte alta en 0
    mov dx, dx              ; redundante, pero para claridad
    mov dh, dl              ; mover el dígito a DH
    mov dl, 0               ; limpiar DL
    add ax, dx              ; sumar el dígito (ahora en DX)

    inc si
    jmp ConvLoop

ConvDone:
    pop si
    ret
StrToNum ENDP

;---------------------------------
; PrintNewLine: imprime CR+LF
;---------------------------------
PrintNewLine PROC
    lea dx, newLine
    mov ah, 09h
    int 21h
    ret
PrintNewLine ENDP

END start
