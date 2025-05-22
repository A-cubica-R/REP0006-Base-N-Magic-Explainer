.MODEL SMALL
.STACK 100h

EXTERN main:NEAR ; Procedure to return to the main module cinit

.DATA
    var_aboutLine1  DB "================================================",13,10,"$"
    var_aboutLine2  DB "|      ____            _        _              |",13,10,"$"
    var_aboutLine3  DB "|     |  _ \ ___  __ _| |_ __ _| | ___  ___    |",13,10,"$"
    var_aboutLine4  DB "|     | |_) / _ \/ _` | __/ _` | |/ _ \/ __|   |",13,10,"$"
    var_aboutLine5  DB "|     |  _ <  __/ (_| | || (_| | |  __/\__ \   |",13,10,"$"
    var_aboutLine6  DB "|     |_| \_\___|\__,_|\__\__,_|_|\___||___/   |",13,10,"$"
    var_aboutLine7  DB "|                                              |",13,10,"$"
    var_aboutLine8  DB "|         BASE-N UNIT CONVERTER v1.0           |",13,10,"$"
    var_aboutLine9  DB "|                                              |",13,10,"$"
    var_aboutLine10 DB "|  Developed by: Adolfo Alejandro Arenas Ramos |",13,10,"$"
    var_aboutLine11 DB "|  Developed by: Gabriel Camilo Pinto Andrade  |",13,10,"$"
    var_aboutLine12 DB "|Contact:adolfoalejandroarenasramos@outlook.com|",13,10,"$"
    var_aboutLine13 DB "================================================",13,10,"$"
    var_pressAny    DB ">> Press any key to return to the main menu <<",13,10,"$"

.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Print the ABOUT section for the program
ShowAbout PROC NEAR PUBLIC
                 call ClearScreen            ; Clear the screen
                 CALL PrintContent           ;  Print the content on the screen

                 mov  ah,  1                 ; Wait for a key
                 int  21h

                 call ClearScreen            ; Clear the screen again
                 ret
ShowAbout ENDP

    ; ======= AUX PROCEDURES =======

    ; Print the content of the variables
PrintContent PROC
                 lea  dx, var_aboutLine1
                 call PrintString
                 lea  dx, var_aboutLine2
                 call PrintString
                 lea  dx, var_aboutLine3
                 call PrintString
                 lea  dx, var_aboutLine4
                 call PrintString
                 lea  dx, var_aboutLine5
                 call PrintString
                 lea  dx, var_aboutLine6
                 call PrintString
                 lea  dx, var_aboutLine7
                 call PrintString
                 lea  dx, var_aboutLine8
                 call PrintString
                 lea  dx, var_aboutLine9
                 call PrintString
                 lea  dx, var_aboutLine10
                 call PrintString
                 lea  dx, var_aboutLine11
                 call PrintString
                 lea  dx, var_aboutLine12
                 call PrintString
                 lea  dx, var_aboutLine13
                 call PrintString
                 lea  dx, var_pressAny
                 call PrintString
                 ret
PrintContent ENDP

    ; Print the value located in DX register
PrintString PROC
                 MOV  AH,09h
                 INT  21h
                 RET
PrintString ENDP

    ; Erase the content of the screen
ClearScreen PROC
                 MOV  AH,0
                 MOV  AL,3
                 INT  10h
                 RET
ClearScreen ENDP

END ShowAbout