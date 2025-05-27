.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine          DB 13, 10, "$"
    ; Octal to Decimal explanation messages
    var_OtoD_step1       DB "-> step 1: Take your octal number", 13, 10, "$"
    var_OtoD_step2       DB "-> step 2: Multiply each digit by 8^(position), starting from right (position 0)", 13, 10, "$"
    var_OtoD_careful     DB "-> BE CAREFUL: Position starts at zero from the rightmost digit", 13, 10, "$"
    var_OtoD_step3       DB "-> step 3: Plus all the results", 13, 10, "$"
    var_OtoD_step4       DB "-> step 4: Sum the results", 13, 10, "$"
    var_OtoD_arrow       DB "-> $"
    var_OtoD_example     DB "-> Example: $"
    var_OtoD_space       DB " $"
    var_OtoD_final       DB "-> Final decimal number: $"
    var_OtoD_equals      DB " = $"
    var_OtoD_plus        DB "+$"
    var_OtoD_times       DB "*$"
    var_OtoD_power       DB "^$"
    var_OtoD_openParen   DB "($"
    var_OtoD_closeParen  DB ")$"
    var_OtoD_openSquare  DB "[$"
    var_OtoD_closeSquare DB "]$"
    
    ; 32-bit number storage
    NUMBER_LOW           DW 0                                                                                                  ; Low 16 bits of number
    NUMBER_HIGH          DW 0                                                                                                  ; High 16 bits of number

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_OD PROC NEAR PUBLIC
                                    CALL ClearScreen
                                    CALL PrintNewLine
                                    CALL PrintNewLine
                       
    ; Step 1: Show the input octal number
                                    LEA  DX, var_OtoD_step1
                                    CALL PrintString
                                    LEA  DX, var_OtoD_example
                                    CALL PrintString
                                    CALL PrintInputNumber
                                    CALL PrintNewLine
                       
    ; Step 2: Show multiplication explanation
                                    LEA  DX, var_OtoD_step2
                                    CALL PrintString
                                    LEA  DX, var_OtoD_careful
                                    CALL PrintString
                                    CALL ShowDigitsWithPowers
                       
    ; Step 3: Show formula with all results
                                    LEA  DX, var_OtoD_step3
                                    CALL PrintString
                                    CALL ShowCombinedFormula
                       
    ; Step 4: Show final result
                                    LEA  DX, var_OtoD_step4
                                    CALL PrintString
                                    LEA  DX, var_OtoD_final
                                    CALL PrintString
                                    CALL Print32BitNumber
                               
                                    CALL PrintNewLine
                                    CALL PrintString_wait
                                    RET
SUBMAIN_OD ENDP

    ; ======= EXPLANATION PROCEDURES =======
    
    ; Print the input octal number separated by spaces
PrintInputNumber PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                    PUSH SI
                       
                                    LEA  SI, BUFFER_IntputStr
                                    MOV  CL, [SI + 1]                       ; Get actual length
                                    MOV  CH, 0
                                    ADD  SI, 2                              ; Point to first digit
                       
    ; Print each digit of the input number with spaces
    _PrintInputLoop:                
                                    CMP  CX, 0
                                    JE   _EndPrintInput
                               
                                    MOV  DL, [SI]                           ; Get current digit
                                    MOV  AH, 02h
                                    INT  21h                                ; Print digit
                                  
    ; Add space if not last digit
                                    CMP  CX, 1
                                    JE   _NoSpaceInput
                                    LEA  DX, var_OtoD_space
                                    CALL PrintString
                               
    _NoSpaceInput:                  
                                    INC  SI
                                    DEC  CX
                                    JMP  _PrintInputLoop
                       
    _EndPrintInput:                 
                                    POP  SI
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
PrintInputNumber ENDP

    ; Show digits with their powers (starting from rightmost = position 0)
ShowDigitsWithPowers PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                    PUSH SI
                                    PUSH DI
                       
                                    LEA  SI, BUFFER_IntputStr
                                    MOV  CL, [SI + 1]                       ; Get actual length
                                    MOV  CH, 0
                                    ADD  SI, 2                              ; Point to first digit
                                    MOV  DI, CX                             ; Save length
                                    DEC  DI                                 ; Position counter (0-based from right)
                       
    _PowerLoop:                     
                                    CMP  CX, 0
                                    JE   _EndPowerLoop
                               
                                    LEA  DX, var_OtoD_arrow
                                    CALL PrintString
                                    LEA  DX, var_OtoD_openParen
                                    CALL PrintString
                               
    ; Print the octal digit
                                    MOV  DL, [SI]
                                    MOV  AH, 02h
                                    INT  21h
                               
                                    LEA  DX, var_OtoD_times
                                    CALL PrintString
                               
    ; Print 8
                                    MOV  DL, '8'
                                    MOV  AH, 02h
                                    INT  21h
                               
                                    LEA  DX, var_OtoD_power
                                    CALL PrintString
                               
    ; Print position (from right, starting at 0)
                                    MOV  AX, DI
                                    CALL PrintSingleDigit
                               
                                    LEA  DX, var_OtoD_closeParen
                                    CALL PrintString
                                    CALL PrintNewLine
                               
                                    INC  SI
                                    DEC  CX
                                    DEC  DI
                                    JMP  _PowerLoop
                       
    _EndPowerLoop:                  
                                    POP  DI
                                    POP  SI
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
ShowDigitsWithPowers ENDP

    ; Show combined formula with calculated values
ShowCombinedFormula PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                    PUSH SI
                                    PUSH DI
                       
    ; Convert octal to decimal first (silently)
                                    CALL ConvertOctalStringTo32BitNumber
                       
                                    LEA  DX, var_OtoD_arrow
                                    CALL PrintString
                                    LEA  DX, var_OtoD_openSquare
                                    CALL PrintString
                       
    ; Show formula with calculated values
                                    LEA  SI, BUFFER_IntputStr
                                    MOV  CL, [SI + 1]                       ; Get actual length
                                    MOV  CH, 0
                                    ADD  SI, 2                              ; Point to first digit
                                    MOV  DI, CX                             ; Save length
                                    DEC  DI                                 ; Position counter (0-based from right)
                       
    _FormulaLoop:                   
                                    CMP  CX, 0
                                    JE   _EndFormulaLoop
                               
                                    LEA  DX, var_OtoD_openParen
                                    CALL PrintString
                               
    ; Print the octal digit
                                    MOV  DL, [SI]
                                    MOV  AH, 02h
                                    INT  21h
                               
                                    LEA  DX, var_OtoD_times
                                    CALL PrintString
                               
    ; Calculate and print 8^position
                                    CALL Calculate8ToPower
                               
                                    LEA  DX, var_OtoD_closeParen
                                    CALL PrintString
                               
                                    CMP  CX, 1
                                    JE   _NoPlus
                                    LEA  DX, var_OtoD_plus
                                    CALL PrintString
                               
    _NoPlus:                        
                                    INC  SI
                                    DEC  CX
                                    DEC  DI
                                    JMP  _FormulaLoop
                       
    _EndFormulaLoop:                
                                    LEA  DX, var_OtoD_closeSquare
                                    CALL PrintString
                                    CALL PrintNewLine
                       
                                    POP  DI
                                    POP  SI
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
ShowCombinedFormula ENDP

    ; Calculate and print 8^position (DI contains position)
Calculate8ToPower PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                  
                                    MOV  AX, 1                              ; Start with 8^0 = 1
                                    MOV  BX, DI                             ; Get position
                                  
    _PowerCalcLoop:                 
                                    CMP  BX, 0
                                    JE   _PrintPower
                                  
                                    MOV  CX, 8
                                    MUL  CX                                 ; AX = AX * 8
                                    DEC  BX
                                    JMP  _PowerCalcLoop
                                  
    _PrintPower:                    
                                    CALL Print16BitNumber
                                  
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
Calculate8ToPower ENDP

    ; Convert octal string to 32-bit number silently
ConvertOctalStringTo32BitNumber PROC
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                    PUSH SI
                                    PUSH DI
                       
                                    LEA  SI, BUFFER_IntputStr
                                    MOV  CL, [SI + 1]                       ; Get actual length
                                    MOV  CH, 0
                                    ADD  SI, 2                              ; Point to first digit
                           
    ; Initialize 32-bit result to 0
                                    MOV  NUMBER_LOW, 0
                                    MOV  NUMBER_HIGH, 0
                           
    _ConvertLoop:                   
                                    CMP  CX, 0
                                    JE   _EndConvertOctal
                               
    ; Multiply current result by 8 (32-bit multiplication)
                                    CALL Multiply32BitBy8
                           
    ; Add current octal digit
                                    MOV  AL, [SI]                           ; Get current octal digit
                                    SUB  AL, '0'                            ; Convert to decimal value (0-7)
                                    MOV  DL, AL
                                    MOV  DH, 0
                                    ADD  NUMBER_LOW, DX                     ; Add to low word
                                    JNC  _NoCarryOctal                      ; If no carry, continue
                                    INC  NUMBER_HIGH                        ; Add carry to high word
                           
    _NoCarryOctal:                  
                                    INC  SI
                                    DEC  CX
                                    JMP  _ConvertLoop
                       
    _EndConvertOctal:               
                                    POP  DI
                                    POP  SI
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    RET
ConvertOctalStringTo32BitNumber ENDP

    ; Multiply 32-bit number by 8
Multiply32BitBy8 PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                  
    ; Multiply low word by 8
                                    MOV  AX, NUMBER_LOW
                                    MOV  BX, 8
                                    MUL  BX                                 ; DX:AX = AX * 8
                                    MOV  NUMBER_LOW, AX                     ; Store new low word
                                    MOV  CX, DX                             ; Save carry
                                  
    ; Multiply high word by 8 and add carry
                                    MOV  AX, NUMBER_HIGH
                                    MUL  BX                                 ; DX:AX = AX * 8
                                    ADD  AX, CX                             ; Add carry from low word
                                    MOV  NUMBER_HIGH, AX                    ; Store new high word
                                  
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
Multiply32BitBy8 ENDP

    ; ======= UTILITY PROCEDURES =======
    
    ; Print a single digit number (0-15)
PrintSingleDigit PROC
                                    PUSH AX
                                    PUSH DX
                                  
                                    CMP  AX, 9
                                    JLE  _SingleDigitOnly
                                  
    ; Handle numbers 10-15 (print as two digits)
                                    MOV  DX, 0
                                    MOV  BX, 10
                                    DIV  BX                                 ; AX = quotient, DX = remainder
                                  
                                    ADD  AL, '0'
                                    MOV  AH, 02h
                                    MOV  DL, AL
                                    INT  21h                                ; Print tens digit
                                  
                                    ADD  DL, '0'
                                    MOV  AH, 02h
                                    INT  21h                                ; Print units digit
                                    JMP  _EndSingleDigit
                                  
    _SingleDigitOnly:               
                                    ADD  AL, '0'
                                    MOV  DL, AL
                                    MOV  AH, 02h
                                    INT  21h
                                  
    _EndSingleDigit:                
                                    POP  DX
                                    POP  AX
                                    RET
PrintSingleDigit ENDP

    ; Print a 16-bit number
Print16BitNumber PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                  
                                    MOV  BX, 10
                                    MOV  CX, 0                              ; Digit counter
                                  
    _Divide16Loop:                  
                                    MOV  DX, 0
                                    DIV  BX                                 ; AX = AX / 10, DX = remainder
                                    PUSH DX                                 ; Save digit on stack
                                    INC  CX
                                    CMP  AX, 0
                                    JNE  _Divide16Loop
                                  
    _Print16Loop:                   
                                    POP  DX
                                    ADD  DL, '0'
                                    MOV  AH, 02h
                                    INT  21h
                                    DEC  CX
                                    CMP  CX, 0
                                    JNE  _Print16Loop
                                  
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
Print16BitNumber ENDP

    ; Print a 32-bit number
Print32BitNumber PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                    PUSH DX
                                    PUSH SI
                                  
                                    MOV  CX, 0                              ; Digit counter
                                  
    _Divide32Loop:                  
                                    CALL Divide32BitBy10
                                    PUSH DX                                 ; Save remainder (digit) on stack
                                    INC  CX
                                  
                                    CMP  NUMBER_HIGH, 0
                                    JNE  _Divide32Loop
                                    CMP  NUMBER_LOW, 0
                                    JNE  _Divide32Loop
                                  
    _Print32Loop:                   
                                    POP  DX
                                    ADD  DL, '0'
                                    MOV  AH, 02h
                                    INT  21h
                                    DEC  CX
                                    CMP  CX, 0
                                    JNE  _Print32Loop
                                  
                                    POP  SI
                                    POP  DX
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
Print32BitNumber ENDP

    ; Divide 32-bit number by 10
Divide32BitBy10 PROC
                                    PUSH AX
                                    PUSH BX
                                    PUSH CX
                                  
                                    MOV  BX, 10
                                  
    ; Divide high word first
                                    MOV  AX, NUMBER_HIGH
                                    MOV  DX, 0
                                    DIV  BX                                 ; AX = quotient, DX = remainder
                                    MOV  NUMBER_HIGH, AX
                                    MOV  CX, DX                             ; Save remainder for low word
                                  
    ; Divide low word with remainder from high word
                                    MOV  AX, NUMBER_LOW
                                    MOV  DX, CX                             ; Use remainder from high word
                                    DIV  BX                                 ; AX = quotient, DX = final remainder
                                    MOV  NUMBER_LOW, AX
                                  
    ; DX contains the final remainder (digit)
                                  
                                    POP  CX
                                    POP  BX
                                    POP  AX
                                    RET
Divide32BitBy10 ENDP

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

END SUBMAIN_OD