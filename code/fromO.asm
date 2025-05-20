; Updated fromB.asm with working BToDec conversion
.MODEL SMALL
.STACK 100h

PUBLIC OToOct
PUBLIC OToDec
PUBLIC OToHex
PUBLIC OToBin

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

OToBin PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
OToBin ENDP

OToOct PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
OToOct ENDP

OToDec PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
OToDec ENDP

OToHex PROC
                call PrintInit
                call PrintNot
                call PrintEndg
                ret
OToHex ENDP

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
