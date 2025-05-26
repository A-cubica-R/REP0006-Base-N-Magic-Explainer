.MODEL SMALL

.DATA

    var_aboutLine1  DB "  /######  / #######   /########  /##   /##  /########",13,10,"$"
    var_aboutLine2  DB " /##__  ## | ##__  ## / ##__  ## | ##  | ## |__  ##__/",13,10,"$"
    var_aboutLine3  DB "| ##  \ ## | ##  \ ## | ##  \ ## | ##  | ##    | ##   ",13,10,"$"
    var_aboutLine4  DB "| ######## | #######  | ##  | ## | ##  | ##    | ##   ",13,10,"$"
    var_aboutLine5  DB "| ##__  ## | ##__  ## | ##  | ## | ##  | ##    | ##   ",13,10,"$"
    var_aboutLine6  DB "| ##  | ## | ##  \ ## | ##  | ## | ##  | ##    | ##   ",13,10,"$"
    var_aboutLine7  DB "| ##  | ## | #######  |  ####### |  ######/    | ##   ",13,10,"$"
    var_aboutLine8  DB "|__/  |__/ |_______/  \_______/  \______/      |__/   ",13,10,"$"
    var_aboutLine9  DB 13,10,"$"                                                             ; New Line
    var_aboutLine10 DB "================================================",13,10,"$"
    var_aboutLine11 DB "|           Base-N Magic Explainer!            |",13,10,"$"
    var_aboutLine12 DB "|               Version: 1.0.0                 |",13,10,"$"
    var_aboutLine13 DB "|                                              |",13,10,"$"
    var_aboutLine14 DB "|  Developed by: Adolfo Alejandro Arenas Ramos |",13,10,"$"
    var_aboutLine15 DB "|  Developed by: Gabriel Camilo Pinto Andrade  |",13,10,"$"
    var_aboutLine16 DB "|Contact:adolfoalejandroarenasramos@outlook.com|",13,10,"$"
    var_aboutLine17 DB "================================================",13,10,"$"
    var_pressAny    DB ">> Press any key to return to the main menu <<",13,10,"$"

.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Print the ABOUT section for the program
MAIN_SHOW PROC NEAR PUBLIC
                 CALL ClearScreen            ; Clear the screen
                 CALL PrintContent           ;  Print the content on the screen

                 MOV  AH,  1                 ; Wait for a key
                 INT  21h

                 CALL ClearScreen            ; Clear the screen again
                 RET
MAIN_SHOW ENDP

    ; ======= AUX PROCEDURES =======

    ; Print the content of the variables
PrintContent PROC
                 LEA  DX, var_aboutLine9
                 CALL PrintString
                 LEA  DX, var_aboutLine1
                 CALL PrintString
                 LEA  DX, var_aboutLine2
                 CALL PrintString
                 LEA  DX, var_aboutLine3
                 CALL PrintString
                 LEA  DX, var_aboutLine4
                 CALL PrintString
                 LEA  DX, var_aboutLine5
                 CALL PrintString
                 LEA  DX, var_aboutLine6
                 CALL PrintString
                 LEA  DX, var_aboutLine7
                 CALL PrintString
                 LEA  DX, var_aboutLine8
                 CALL PrintString
                 LEA  DX, var_aboutLine9
                 CALL PrintString
                 LEA  DX, var_aboutLine10
                 CALL PrintString
                 LEA  DX, var_aboutLine11
                 CALL PrintString
                 LEA  DX, var_aboutLine12
                 CALL PrintString
                 LEA  DX, var_aboutLine13
                 CALL PrintString
                 LEA  DX, var_aboutLine14
                 CALL PrintString
                 LEA  DX, var_aboutLine15
                 CALL PrintString
                 LEA  DX, var_aboutLine16
                 CALL PrintString
                 LEA  DX, var_aboutLine17
                 CALL PrintString
                 LEA  DX, var_pressAny
                 CALL PrintString
                 RET
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

END MAIN_SHOW