; Updated fromB.asm with working BToDec conversion
.MODEL SMALL
.STACK 100h

PUBLIC BToOct
PUBLIC BToDec
PUBLIC BToHex
PUBLIC BToBin

EXTERN bufResult:BYTE   ; 'cselect.asm' result buffer

.DATA
    msgInit         db 'Conversion initialized', 13,10,'$'
    msgNotAvailable db 'Conversion not available', 13,10,'$'
    msgEnd          db 'Conversion finished, press any key to exit', 13,10,'$'
.CODE

Start PROC
                mov  ax, @data
                mov  ds, ax
                call ClearScreen
                call PrintInit
Start ENDP

HToBin PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
HToBin ENDP

HToOct PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
HToOct ENDP

    ; convert AX result from StrToNum into decimal string
HToDec PROC
                call PrintInit             ; Print the initialization message
                push ax
                push bx
                push cx
                push dx
                push di

                lea  di, bufResult         ; DI -> start of output buffer
                mov  cx, 0                 ; digit count

.ReverseLoop:
                xor  dx, dx                ; clear DX for div
                mov  bx, 10
                div  bx                    ; AX = AX / 10, DX = remainder
                add  dl, '0'               ; convert remainder to ASCII
                mov  [di], dl              ; store digit (reversed)
                inc  di
                inc  cx
                cmp  ax, 0
                jne  .ReverseLoop

    ; reverse the digits in-place
                lea  si, bufResult         ; SI -> first digit
                lea  di, bufResult
                add  di, cx
                dec  di                    ; DI -> last digit

.ReverseSwap:
                cmp  si, di
                jae  .ReverseDone
                mov  al, [si]
                mov  bl, [di]
                mov  [si], bl
                mov  [di], al
                inc  si
                dec  di
                jmp  .ReverseSwap

.ReverseDone:
    ; append terminator
                lea  di, bufResult
                add  di, cx
                mov  byte ptr [di], '$'

                pop  di
                pop  dx
                pop  cx
                pop  bx
                pop  ax
                call PrintEndg             ; Print the finalization message
                ret
HToDec ENDP

HToHex PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
HToHex ENDP

    ; ===================== AUX METHODS =====================

ClearScreen PROC
                mov  ah, 0
                mov  al, 3
                int  10h
                ret
ClearScreen ENDP

PrintInit PROC
                mov  dx, OFFSET msgInit
                mov  ah, 09h
                int  21h
                ret
PrintInit ENDP

PrintNot PROC
                mov  dx, OFFSET msgNotAvailable
                mov  ah, 09h
                int  21h
                ret
PrintNot ENDP

PrintEndg PROC
                mov  dx, OFFSET msgEnd
                mov  ah, 09h
                int  21h
                mov  ah, 08h
                int  21h
                ret
PrintEndg ENDP

END Start
