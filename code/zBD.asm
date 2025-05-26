.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine    DB 13, 10, "$"
    ; Math symbols
    var_xplnB_pl   DB '+', '$'
    var_xplnB_mi   DB '-', '$'
    var_xplnB_mu   DB '*', '$'
    var_xplnB_di   DB '/', '$'
    ; Binary to Decimal explanation messages
    var_BtoD_step1 DB "-> step 1: separate each digit of the number", 13, 10, "$"
    var_BtoD_step2 DB "-> step 2: multiply each digit by 2 elevated to the position of the digit", 13, 10, "$"
    var_BtoD_step3 DB "-> BE CAREFUL: the position counts from 0 to N, from right to left", 13, 10, "$"
    var_BtoD_step4 DB "-> step 3: sum the results", 13, 10, "$"
    var_BtoD_step5 DB "-> step 4: The result of the plus it's your number in decimal format!", 13, 10, "$"
    var_BtoD_final DB "-> Your final number: $"
    var_BtoD_arrow DB "-> $"
    var_BtoD_space DB " $"
    var_BtoD_mult  DB "*$"
    var_BtoD_exp   DB "^$"
    var_BtoD_open  DB "($"
    var_BtoD_close DB ")$"
    var_BtoD_num2  DB "2$"

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_BD PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show separation of digits
                               LEA  DX, var_BtoD_step1
                               CALL PrintString
                               LEA  DX, var_BtoD_arrow
                               CALL PrintString
                               CALL PrintBinaryDigitsSeparated
                               CALL PrintNewLine
                       
    ; Step 2: Show multiplication explanation
                               LEA  DX, var_BtoD_step2
                               CALL PrintString
                               LEA  DX, var_BtoD_step3
                               CALL PrintString
                               CALL PrintMultiplicationSteps
                       
    ; Step 3: Show sum explanation
                               LEA  DX, var_BtoD_step4
                               CALL PrintString
                               LEA  DX, var_BtoD_arrow
                               CALL PrintString
                               CALL PrintSumFormula
                               CALL PrintNewLine
                       
    ; Step 4: Final message
                               LEA  DX, var_BtoD_step5
                               CALL PrintString
                       
    ; Step 5: Show final result
                               LEA  DX, var_BtoD_final
                               CALL PrintString
                               CALL CalculateAndPrintDecimalResult
                               CALL PrintNewLine
                       
                               CALL PrintNewLine
                               CALL PrintString_wait
                               RET
SUBMAIN_BD ENDP

    ; ======= BINARY TO DECIMAL EXPLANATION PROCEDURES =======
    
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
                       
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h                           ; Print current digit
                       
                               INC  SI
                               DEC  CX
                       
                               CMP  CX, 0                         ; If not last digit, print space
                               JE   _EndPrintDigits
                               LEA  DX, var_BtoD_space
                               CALL PrintString
                               JMP  _PrintDigitLoop
                       
    _EndPrintDigits:           
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintBinaryDigitsSeparated ENDP

    ; Print multiplication steps for each digit
PrintMultiplicationSteps PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
                               MOV  BL, CL                        ; BL = total length
                               DEC  BL                            ; BL = highest position (length-1)
                       
    _PrintStepLoop:            
                               CMP  CX, 0
                               JE   _EndPrintSteps
                       
    ; Print arrow and opening parenthesis
                               LEA  DX, var_BtoD_arrow
                               CALL PrintString
                               LEA  DX, var_BtoD_open
                               CALL PrintString
                       
    ; Print the digit
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                       
    ; Print "*2^"
                               LEA  DX, var_BtoD_mult
                               CALL PrintString
                               LEA  DX, var_BtoD_num2
                               CALL PrintString
                               LEA  DX, var_BtoD_exp
                               CALL PrintString
                       
    ; Print position number
                               MOV  AL, BL
                               CALL PrintSingleDigit
                       
    ; Print closing parenthesis
                               LEA  DX, var_BtoD_close
                               CALL PrintString
                               CALL PrintNewLine
                       
                               INC  SI
                               DEC  CX
                               DEC  BL                            ; Decrease position
                               JMP  _PrintStepLoop
                       
    _EndPrintSteps:            
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintMultiplicationSteps ENDP

    ; Print the complete sum formula
PrintSumFormula PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
                               MOV  BL, CL                        ; BL = total length
                               DEC  BL                            ; BL = highest position (length-1)
                       
    _PrintFormulaLoop:         
                               CMP  CX, 0
                               JE   _EndPrintFormula
                       
    ; Print opening parenthesis
                               LEA  DX, var_BtoD_open
                               CALL PrintString
                       
    ; Print the digit
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                       
    ; Print "*2^"
                               LEA  DX, var_BtoD_mult
                               CALL PrintString
                               LEA  DX, var_BtoD_num2
                               CALL PrintString
                               LEA  DX, var_BtoD_exp
                               CALL PrintString
                       
    ; Print position number
                               MOV  AL, BL
                               CALL PrintSingleDigit
                       
    ; Print closing parenthesis
                               LEA  DX, var_BtoD_close
                               CALL PrintString
                       
    ; Print + if not last element
                               DEC  CX
                               CMP  CX, 0
                               JE   _EndPrintFormula
                               LEA  DX, var_xplnB_pl
                               CALL PrintString
                       
                               INC  SI
                               DEC  BL                            ; Decrease position
                               JMP  _PrintFormulaLoop
                       
    _EndPrintFormula:          
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintSumFormula ENDP

    ; Calculate and print the final decimal result
CalculateAndPrintDecimalResult PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
                               MOV  AX, 0                         ; Result accumulator
                               MOV  BL, CL                        ; BL = total length
                               DEC  BL                            ; BL = highest position (length-1)
                       
    _CalcLoop:                 
                               CMP  CX, 0
                               JE   _EndCalc
                       
                               MOV  DL, [SI]                      ; Get current digit
                               SUB  DL, '0'                       ; Convert ASCII to value
                       
                               CMP  DL, 1                         ; Only process if digit is 1
                               JNE  _NextDigit
                       
    ; Add 2^BL to result
                               PUSH AX
                               PUSH CX
                               MOV  CL, BL                        ; Power to calculate
                               MOV  AX, 1
                               CALL PowerOf2BD                    ; AX = 2^CL
                               MOV  DX, AX                        ; Save power result
                               POP  CX
                               POP  AX
                               ADD  AX, DX                        ; Add to result
                       
    _NextDigit:                
                               INC  SI
                               DEC  CX
                               DEC  BL                            ; Decrease position
                               JMP  _CalcLoop
                       
    _EndCalc:                  
                               CALL PrintDecimalNumber            ; Print the final result
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
CalculateAndPrintDecimalResult ENDP

    ; Calculate 2^CL and return in AX
PowerOf2BD PROC
                               PUSH CX
                               MOV  AX, 1
                               CMP  CL, 0
                               JE   _EndPowerBD
                       
    _PowerLoopBD:              
                               SHL  AX, 1                         ; AX = AX * 2
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PowerLoopBD
                       
    _EndPowerBD:               
                               POP  CX
                               RET
PowerOf2BD ENDP

    ; Print decimal number in AX
PrintDecimalNumber PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                       
                               MOV  BX, 10                        ; Divisor
                               MOV  CX, 0                         ; Digit counter
                       
    ; Convert number to string (reverse order)
    _ConvertLoop:              
                               MOV  DX, 0                         ; Clear DX for division
                               DIV  BX                            ; AX = AX / 10, DX = remainder
                               PUSH DX                            ; Save digit
                               INC  CX                            ; Count digits
                               CMP  AX, 0
                               JNE  _ConvertLoop
                       
    ; Print digits in correct order
    _PrintLoop:                
                               POP  DX                            ; Get digit
                               ADD  DL, '0'                       ; Convert to ASCII
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                               DEC  CX
                               CMP  CX, 0
                               JNE  _PrintLoop
                       
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintDecimalNumber ENDP

    ; Print a single digit number (0-9)
PrintSingleDigit PROC
                               PUSH DX
                               ADD  AL, '0'                       ; Convert to ASCII
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               POP  DX
                               RET
PrintSingleDigit ENDP

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

END SUBMAIN_BD