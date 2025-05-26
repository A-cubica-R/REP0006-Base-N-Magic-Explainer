.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine    DB 13, 10, "$"
    ; Binary to Binary explanation messages
    var_BtoB_step1 DB "-> Step 1: Your number is already in binary format!", 13, 10, "$"
    var_BtoB_step2 DB "-> Step 2: You don't need to make more steps", 13, 10, "$"
    var_BtoB_arrow DB "-> $"
    var_BtoB_space DB " $"

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_BB PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show that number is already in binary format
                               LEA  DX, var_BtoB_step1
                               CALL PrintString
                               LEA  DX, var_BtoB_arrow
                               CALL PrintString
                               CALL PrintBinaryDigitsSeparated
                               CALL PrintNewLine
                       
    ; Step 2: Show that no conversion is needed
                               LEA  DX, var_BtoB_step2
                               CALL PrintString
                               LEA  DX, var_BtoB_arrow
                               CALL PrintString
                               CALL PrintBinaryAsIs
                               CALL PrintNewLine
                               
                               CALL PrintString_wait
                               RET
SUBMAIN_BB ENDP

    ; ======= BINARY TO BINARY EXPLANATION PROCEDURES =======
    
    ; Print binary digits separated by spaces
PrintBinaryDigitsSeparated PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    _PrintDigitLoop:           
                               CMP  CX, 0
                               JE   _EndPrintDigits
                               
                               MOV  DL, [SI]                      ; Get current digit
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                               
                               INC  SI
                               DEC  CX
                               
                               CMP  CX, 0                         ; Don't print space after last digit
                               JE   _EndPrintDigits
                               
                               LEA  DX, var_BtoB_space
                               CALL PrintString                   ; Print space
                               JMP  _PrintDigitLoop
                       
    _EndPrintDigits:           
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintBinaryDigitsSeparated ENDP

    ; Print binary number as is (without spaces)
PrintBinaryAsIs PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    _PrintAsIsLoop:            
                               CMP  CX, 0
                               JE   _EndPrintAsIs
                               
                               MOV  DL, [SI]                      ; Get current digit
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                               
                               INC  SI
                               DEC  CX
                               JMP  _PrintAsIsLoop
                       
    _EndPrintAsIs:             
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintBinaryAsIs ENDP

    ; ======= AUX PROCEDURES =======

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

END SUBMAIN_BB