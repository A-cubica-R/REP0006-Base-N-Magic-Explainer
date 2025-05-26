.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine    DB 13, 10, "$"
    ; Binary to Hexadecimal explanation messages
    var_BtoH_step1 DB "-> Step 1: Separate the digits into groups of 4", 13, 10, "$"
    var_BtoH_step2 DB "-> Step 2: If the leftmost group has fewer than 4 digits, keep it like a group", 13, 10, "$"
    var_BtoH_step3 DB "-> Step 3: Convert each group to its decimal equivalent", 13, 10, "$"
    var_BtoH_step4 DB "-> Step 4: If the number is higher than 9, replace for the equivalent letter:", 13, 10, "$"
    var_BtoH_step5 DB "-> Step 5: Your groups converted", 13, 10, "$"
    var_BtoH_step6 DB "-> Step 6: Put your numbers together, that's your number in hexadecimal format!", 13, 10, "$"
    var_BtoH_arrow DB "-> $"
    var_BtoH_space DB " $"
    var_BtoH_openBracket  DB "[$"
    var_BtoH_closeBracket DB "]$"
    var_BtoH_equals DB " = $"
    var_BtoH_final DB "-> Final number: $"
    ; Letter equivalents
    var_BtoH_A DB "       A=10", 13, 10, "$"
    var_BtoH_B DB "       B=11", 13, 10, "$"
    var_BtoH_C DB "       C=12", 13, 10, "$"
    var_BtoH_D DB "       D=13", 13, 10, "$"
    var_BtoH_E DB "       E=14", 13, 10, "$"
    var_BtoH_F DB "       F=15", 13, 10, "$"

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_BH PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show separation into groups of 4
                               LEA  DX, var_BtoH_step1
                               CALL PrintString
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               CALL PrintBinaryDigitsSeparated
                               CALL PrintNewLine
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               CALL PrintBinaryGrouped
                               CALL PrintNewLine
                       
    ; Step 2: Show leftmost group handling
                               LEA  DX, var_BtoH_step2
                               CALL PrintString
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               CALL PrintBinaryGrouped
                               CALL PrintNewLine
                       
    ; Step 3: Show conversion of each group to decimal
                               LEA  DX, var_BtoH_step3
                               CALL PrintString
                               CALL PrintGroupConversions
                       
    ; Step 4: Show letter equivalents
                               LEA  DX, var_BtoH_step4
                               CALL PrintString
                               LEA  DX, var_BtoH_A
                               CALL PrintString
                               LEA  DX, var_BtoH_B
                               CALL PrintString
                               LEA  DX, var_BtoH_C
                               CALL PrintString
                               LEA  DX, var_BtoH_D
                               CALL PrintString
                               LEA  DX, var_BtoH_E
                               CALL PrintString
                               LEA  DX, var_BtoH_F
                               CALL PrintString
                       
    ; Step 5: Show converted groups
                               LEA  DX, var_BtoH_step5
                               CALL PrintString
                               CALL PrintGroupConversionsHex
                       
    ; Step 6: Show final result
                               LEA  DX, var_BtoH_step6
                               CALL PrintString
                               LEA  DX, var_BtoH_final
                               CALL PrintString
                               CALL PrintFinalHexResult
                               CALL PrintNewLine
                               
                               CALL PrintString_wait
                               RET
SUBMAIN_BH ENDP

    ; ======= BINARY TO HEXADECIMAL EXPLANATION PROCEDURES =======
    
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
                               
                               LEA  DX, var_BtoH_space
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

    ; Print binary digits grouped in brackets of 4
PrintBinaryGrouped PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    ; Calculate number of complete groups and remaining digits
                               MOV  AX, CX
                               MOV  BL, 4                         ; Groups of 4 for hexadecimal
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Print leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _PrintCompleteGroups
                               
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
                               MOV  CL, BH                        ; Print remainder digits
    _PrintRemainder:           
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintRemainder
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               
                               CMP  BL, 0                         ; If no complete groups, finish
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoH_space
                               CALL PrintString
                       
    _PrintCompleteGroups:      
                               CMP  BL, 0
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
    ; Print 4 digits
                               MOV  CL, 4
    _PrintGroupDigits:         
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintGroupDigits
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               
                               DEC  BL
                               CMP  BL, 0
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoH_space
                               CALL PrintString
                               JMP  _PrintCompleteGroups
                       
    _EndPrintGrouped:          
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintBinaryGrouped ENDP

    ; Print the conversion of each group to decimal
PrintGroupConversions PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    ; Calculate groups
                               MOV  AX, CX
                               MOV  BL, 4                         ; Groups of 4 for hexadecimal
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Convert leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _ConvertCompleteGroups
                               
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
    ; Print remainder group digits
                               PUSH SI
                               MOV  CL, BH                        ; Number of digits to print
    _PrintRemainderDigits:     
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintRemainderDigits
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoH_equals
                               CALL PrintString
                               
    ; Calculate and print the decimal value for remainder group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, BH                        ; Number of digits in group
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintDecimalValue            ; Print as decimal
                               CALL PrintNewLine
                               
    ; Move SI to next group
                               MOV  CL, BH
    _SkipRemainderDigits:      
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _SkipRemainderDigits
                       
    _ConvertCompleteGroups:    
                               CMP  BL, 0
                               JE   _EndConversions
                               
    ; Convert each complete group
    _ConvertGroupLoop:         
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
    ; Print 4 digits
                               PUSH SI
                               MOV  CL, 4
    _PrintFourDigits:          
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintFourDigits
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoH_equals
                               CALL PrintString
                               
    ; Calculate and print decimal value for this group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, 4                         ; Always 4 digits for complete groups
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintDecimalValue            ; Print as decimal
                               CALL PrintNewLine
                               
                               ADD  SI, 4                         ; Move to next group
                               DEC  BL
                               CMP  BL, 0
                               JNE  _ConvertGroupLoop
                       
    _EndConversions:           
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintGroupConversions ENDP

    ; Print the conversion of each group to hexadecimal (Step 5)
PrintGroupConversionsHex PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    ; Calculate groups
                               MOV  AX, CX
                               MOV  BL, 4                         ; Groups of 4 for hexadecimal
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Convert leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _ConvertCompleteGroupsHex
                               
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
    ; Print remainder group digits
                               PUSH SI
                               MOV  CL, BH                        ; Number of digits to print
    _PrintRemainderDigitsHex:  
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintRemainderDigitsHex
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoH_equals
                               CALL PrintString
                               
    ; Calculate and print the hex value for remainder group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, BH                        ; Number of digits in group
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintHexValue                 ; Print as hex (digit or letter)
                               CALL PrintNewLine
                               
    ; Move SI to next group
                               MOV  CL, BH
    _SkipRemainderDigitsHex:   
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _SkipRemainderDigitsHex
                       
    _ConvertCompleteGroupsHex: 
                               CMP  BL, 0
                               JE   _EndConversionsHex
                               
    ; Convert each complete group
    _ConvertGroupLoopHex:      
                               LEA  DX, var_BtoH_arrow
                               CALL PrintString
                               LEA  DX, var_BtoH_openBracket
                               CALL PrintString
                               
    ; Print 4 digits
                               PUSH SI
                               MOV  CL, 4
    _PrintFourDigitsHex:       
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintFourDigitsHex
                               
                               LEA  DX, var_BtoH_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoH_equals
                               CALL PrintString
                               
    ; Calculate and print hex value for this group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, 4                         ; Always 4 digits for complete groups
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintHexValue                 ; Print as hex (digit or letter)
                               CALL PrintNewLine
                               
                               ADD  SI, 4                         ; Move to next group
                               DEC  BL
                               CMP  BL, 0
                               JNE  _ConvertGroupLoopHex
                       
    _EndConversionsHex:        
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintGroupConversionsHex ENDP

    ; Print the final hexadecimal result
PrintFinalHexResult PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    ; Calculate groups
                               MOV  AX, CX
                               MOV  BL, 4                         ; Groups of 4 for hexadecimal
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Convert leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _PrintCompleteResultsHex
                               
                               MOV  CL, BH                        ; Number of digits in remainder group
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintHexValue                 ; Print as hex
                               
    ; Move SI to next group
                               MOV  CL, BH
    _SkipRemainderHex:         
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _SkipRemainderHex
                       
    _PrintCompleteResultsHex:  
                               CMP  BL, 0
                               JE   _EndFinalResultHex
                               
    _PrintResultLoopHex:       
                               MOV  CL, 4                         ; Always 4 digits for complete groups
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintHexValue                 ; Print as hex
                               ADD  SI, 4                         ; Move to next group
                               DEC  BL
                               CMP  BL, 0
                               JNE  _PrintResultLoopHex
                       
    _EndFinalResultHex:        
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintFinalHexResult ENDP

    ; Calculate the decimal value of a binary group starting at SI
    ; CL = number of digits in the group
    ; Returns value in AL
CalculateGroupValueFromSI PROC
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                               
                               MOV  AL, 0                         ; Result
                               MOV  BL, CL                        ; Save digit count
                               DEC  BL                            ; Power starts at count-1 for leftmost digit
                               
    _CalcLoop:                 
                               CMP  CL, 0                         ; Check if we've processed all digits
                               JE   _EndCalc
                               
                               MOV  DL, [SI]                      ; Get current digit
                               SUB  DL, '0'                       ; Convert ASCII to value
                               
                               CMP  DL, 1                         ; Only process if digit is 1
                               JNE  _NextCalcDigit
                               
    ; Add 2^BL to result
                               PUSH AX
                               PUSH CX
                               MOV  CL, BL                        ; Power to calculate
                               MOV  AL, 1
                               CALL PowerOf2                      ; AL = 2^CL
                               MOV  DL, AL                        ; Save power result
                               POP  CX
                               POP  AX
                               ADD  AL, DL                        ; Add to result
                               
    _NextCalcDigit:            
                               INC  SI                            ; Move to next digit
                               DEC  CL                            ; Decrease digit count
                               DEC  BL                            ; Decrease power
                               JMP  _CalcLoop
                               
    _EndCalc:                  
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               RET
CalculateGroupValueFromSI ENDP

    ; Calculate 2^CL and return in AL
PowerOf2 PROC
                               PUSH CX
                               MOV  AL, 1
                               CMP  CL, 0
                               JE   _EndPower
                               
    _PowerLoop:                
                               SHL  AL, 1                         ; AL = AL * 2
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PowerLoop
                               
    _EndPower:                 
                               POP  CX
                               RET
PowerOf2 ENDP

    ; Print a decimal value (0-15)
PrintDecimalValue PROC
                               PUSH DX
                               CMP  AL, 10
                               JL   _PrintSingleDigit
                               
    ; Print two-digit number
                               PUSH AX
                               MOV  DL, '1'                       ; First digit is always 1 for 10-15
                               MOV  AH, 02h
                               INT  21h
                               POP  AX
                               SUB  AL, 10                        ; Get second digit
                               ADD  AL, '0'
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               JMP  _EndPrintDecimal
                               
    _PrintSingleDigit:         
                               ADD  AL, '0'                       ; Convert to ASCII
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               
    _EndPrintDecimal:          
                               POP  DX
                               RET
PrintDecimalValue ENDP

    ; Print a hexadecimal value (0-9, A-F)
PrintHexValue PROC
                               PUSH DX
                               CMP  AL, 10
                               JL   _PrintHexDigit
                               
    ; Print letter A-F
                               SUB  AL, 10                        ; Convert to 0-5
                               ADD  AL, 'A'                       ; Convert to A-F
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               JMP  _EndPrintHex
                               
    _PrintHexDigit:            
                               ADD  AL, '0'                       ; Convert to ASCII
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               
    _EndPrintHex:              
                               POP  DX
                               RET
PrintHexValue ENDP

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

END SUBMAIN_BH