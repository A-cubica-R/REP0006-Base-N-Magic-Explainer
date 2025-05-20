; Updated fromB.asm with working BToDec conversion
.MODEL SMALL
.STACK 100h

PUBLIC DToOct
PUBLIC DToDec
PUBLIC DToHex
PUBLIC DToBin

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

DToBin PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
DToBin ENDP

DToOct PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
DToOct ENDP

DToDec PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
DToDec ENDP

DToHex PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
DToHex ENDP

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
