.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine    DB 13, 10, "$"
    ; Hexadecimal to Hexadecimal explanation messages
    var_HtoH_step1 DB "-> Step 1: Your number is already in hexadecimal format!", 13, 10, "$"
    var_HtoH_step2 DB "-> Step 2: You don't need to make more steps", 13, 10, "$"
    var_HtoH_arrow DB "-> $"
    var_HtoH_space DB " $"

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_HH PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show that number is already in hexadecimal format
                               LEA  DX, var_HtoH_step1
                               CALL PrintString
                               LEA  DX, var_HtoH_arrow
                               CALL PrintString
                               CALL PrintHexDigitsSeparated
                               CALL PrintNewLine
                       
    ; Step 2: Show that no conversion is needed
                               LEA  DX, var_HtoH_step2
                               CALL PrintString
                               LEA  DX, var_HtoH_arrow
                               CALL PrintString
                               CALL PrintHexAsIs
                               CALL PrintNewLine
                               
                               CALL PrintString_wait
                               RET
SUBMAIN_HH ENDP

    ; ======= HEXADECIMAL TO HEXADECIMAL EXPLANATION PROCEDURES =======
    
    ; Print hexadecimal digits separated by spaces
PrintHexDigitsSeparated PROC
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
                               
                               LEA  DX, var_HtoH_space
                               CALL PrintString                   ; Print space
                               JMP  _PrintDigitLoop
                       
    _EndPrintDigits:           
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintHexDigitsSeparated ENDP

    ; Print hexadecimal number as is (without spaces)
PrintHexAsIs PROC
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
PrintHexAsIs ENDP

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

END SUBMAIN_HH