.MODEL SMALL
.STACK 100h

; exportamos ShowAbout para que el linker lo encuentre
PUBLIC ShowAbout
EXTERN main:NEAR

; -------------------------------------------------------------------
.DATA
    aboutLine1 DB "UNIT CONVERTER 8-BIT v1.0", 13,10, "$"
    aboutLine2 DB "Developed by: Adolfo Alejandro Arenas Ramos", 13,10, "$"
    aboutLine3 DB "Developed by: Gabriel Camilo Pinto Andrade", 13,10, "$"
    aboutLine4 DB "Contacto: adolfoalejandroarenasramos@outlook.com", 13,10, "$"
    pressAny   DB "PPlease use any key to exit of this screen...",13,10,"$"
    ; -------------------------------------------------------------------

.CODE

ShowAbout PROC NEAR
    ; despeja pantalla
                call ClearScreen

    ; imprime las líneas
                lea  dx, aboutLine1
                call PrintString
                lea  dx, aboutLine2
                call PrintString
                lea  dx, aboutLine3
                call PrintString
                lea  dx, aboutLine4
                call PrintString
                lea  dx, pressAny
                call PrintString

    ; espera cualquier tecla
                mov  ah,  1
                int  21h

    ; limpia y regresa al menú
                call ClearScreen

    ; llama a la función principal de converser_init
                call main

                ret
ShowAbout ENDP

PrintString PROC
                mov  ah,09h
                int  21h
                ret
PrintString ENDP

ClearScreen PROC
                mov  ah,0
                mov  al,3
                int  10h
                ret
ClearScreen ENDP

END ShowAbout