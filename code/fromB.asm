    ;-------------------------------------------------
    ; archivo: Bin2Oct.asm
    ; Ensamblador: MASM en DOS-BOX 16-bits
    ;-------------------------------------------------
.MODEL small
.STACK 100h

PUBLIC _ToBin
PUBLIC _ToOct
PUBLIC _ToDec
PUBLIC _ToHex

.DATA
    testBuf db '111111'           ; cadena binaria de prueba
    testLen db 6                  ; longitud = 6 dígitos
    outBuf  db 6 dup('?'), '$'    ; buffer para la cadena octal + '$'

.CODE

    ;----------------------- Main -----------------------
Main PROC
                mov  ax, @data
                mov  ds, ax

                call ClearScreen

    ; invoca _ToOct(srcPtr, length, destPtr)
                lea  si, testBuf            ; SI ← offset de testBuf
                mov  cl, [testLen]          ; CL ← longitud

                xor  ch, ch                 ; CH = 0
                
                lea  di, outBuf             ; DI ← offset de outBuf
                push di                     ; destPtr
                push cx                     ; length
                push si                     ; srcPtr
                call _ToOct
                add  sp, 6                  ; limpiar pila (3 parámetros × 2 bytes)

    ; imprime outBuf con '$'
                lea  dx, outBuf
                mov  ah, 9
                int  21h

    ; termina programa
                mov  ah, 4Ch
                int  21h
Main ENDP

_ToBin PROC
    ; Acá va el código para convertir a binario
                ret
_ToBin ENDP

    ;---------------------- _ToOct -----------------------
    ; Convierte una cadena binaria (base 2) a octal y escribe la
    ; representación en la cadena apuntada por destPtr, terminada en '$'.
    ;
    ; Parámetros (pila):
    ;   [bp+4] srcPtr   ; offset de cadena de caracteres '0'/'1'
    ;   [bp+6] length   ; número de caracteres
    ;   [bp+8] destPtr  ; offset de buffer destino
    ;
_ToOct PROC NEAR
                push bp
                mov  bp, sp

                mov  si, [bp+4]             ; srcPtr
                mov  cx, [bp+6]             ; length

                mov  si, [bp+4]             ; srcPtr
                mov  cl, byte ptr [bp+6]    ; CL = length
                xor  ch, ch                 ; CH = 0

                mov  di, [bp+8]             ; destPtr
                xor  ax, ax                 ; AX como acumulador

    ; 1) Parsear binario → valor en AX
    BinLoop:    
                mov  dl, [si]
                sub  dl, '0'
                shl  ax, 1
                add  ax, dx
                inc  si
                loop BinLoop

    ; 2) Convertir AX (valor decimal) a octal apilando restos
                xor  cx, cx                 ; CX = contador de dígitos
    ConvLoop:   
                mov  bx, 8
                xor  dx, dx
                div  bx                     ; AX = AX/8, DX = AX%8
                push dx                     ; apilar dígito
                inc  cx
                cmp  ax, 0
                jne  ConvLoop

    ; 3) Desapilar y escribir dígitos en destPtr
    WriteLoop:  
                pop  dx
                add  dl, '0'
                mov  [di], dl
                inc  di
                loop WriteLoop

    ; 4) Terminar cadena con '$'
                mov  byte ptr [di], '$'

                pop  bp
                ret  6                      ; limpia parámetros (3×2 bytes)
_ToOct ENDP

_ToDec PROC
    ; Acá va el código para convertir a decimal
                ret
_ToDec ENDP

_ToHex PROC
    ; Acá va el código para convertir a hexadecimal
                ret
_ToHex ENDP

    ;------------------ Rutina auxiliar ------------------
    ; Limpia la pantalla (modo texto 80×25, página 0)
ClearScreen PROC NEAR
                mov  ah, 0
                mov  al, 3
                int  10h
                ret
ClearScreen ENDP

END Main
