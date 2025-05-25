.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN BUFFER_OutputStr:NEAR

.DATA

    ; Util printing
    var_newLine      DB 13, 10, "$"
    ; Buffers
    BUFFER_IntputNum DD 11 DUP(0)
    ; Debugging vars
    var_TestB1       DB "BBB Break point 1 BBBB", 13, 10, "$"
    var_TestB2       DB "BBB Break point 2 BBBB", 13, 10, "$"
    var_TestB3       DB "BBB Break point 3 BBBB", 13, 10, "$"
    var_TestB4       DB "BBB Break point 4 BBBB", 13, 10, "$"
    var_TestB5       DB "BBB Break point 5 BBBB", 13, 10, "$"
.CODE

MAIN_FROMB PROC NEAR PUBLIC
                          CALL InitializeConvertionB
                          RET
MAIN_FROMB ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionB PROC
                          CALL InputToBinary
                          RET
InitializeConvertionB ENDP

    ; Convert the ASCII string to a number in binary way
InputToBinary PROC
        
                          RET
InputToBinary ENDP

    ; ======= CONV PROCEDURES =======
    ; Here the procedures that will be used to convert the num to a base-n

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

    ; Print a string to the screen from DX register
PrintString PROC
                          MOV  AH,09h
                          INT  21h
                          RET
PrintString ENDP

    ; Print a string to the screen from DX register and wait for a key press
PrintString_wait PROC
                          MOV  ah, 09h
                          INT  21h
                          MOV  ah, 0
                          INT  16h
                          RET
PrintString_wait ENDP

    ; Print a string to the screen from DX register and add a new line
PrintNewLine PROC
                          MOV  AH, 09h
                          LEA  DX, var_newLine
                          INT  21h
                          RET
PrintNewLine ENDP

    ; Erase the content of the screen
ClearScreen PROC
                          MOV  AH,0
                          MOV  AL,3
                          INT  10h
                          RET
ClearScreen ENDP

END MAIN_FROMB