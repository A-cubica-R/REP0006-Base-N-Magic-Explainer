.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; Binary to Octal explanation messages
    var_BtoO_step1        DB "-> Step 1: Separate the digits into groups of 3", 13, 10, "$"
    var_BtoO_step2        DB "-> Step 2: If the leftmost group has fewer than 3 digits, keep it like a group", 13, 10, "$"
    var_BtoO_step3        DB "-> Step 3: Convert each group to its decimal equivalent", 13, 10, "$"
    var_BtoO_step4        DB "-> Step 4: Put the numbers together. That's your number in octal format!", 13, 10, "$"
    var_BtoO_arrow        DB "-> $"
    var_BtoO_space        DB " $"
    var_BtoO_openBracket  DB "[$"
    var_BtoO_closeBracket DB "]$"
    var_BtoO_equals       DB " = $"
    var_BtoO_final        DB "-> Final octal number: $"

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_BO PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show separation into groups of 3
                               LEA  DX, var_BtoO_step1
                               CALL PrintString
                               LEA  DX, var_BtoO_arrow
                               CALL PrintString
                               CALL PrintBinaryDigitsSeparated
                               CALL PrintNewLine
                               LEA  DX, var_BtoO_arrow
                               CALL PrintString
                               CALL PrintBinaryGrouped
                               CALL PrintNewLine
                       
    ; Step 2: Show leftmost group handling
                               LEA  DX, var_BtoO_step2
                               CALL PrintString
                               LEA  DX, var_BtoO_arrow
                               CALL PrintString
                               CALL PrintBinaryGrouped
                               CALL PrintNewLine
                       
    ; Step 3: Show conversion of each group
                               LEA  DX, var_BtoO_step3
                               CALL PrintString
                               CALL PrintGroupConversions
                       
    ; Step 4: Show final result
                               LEA  DX, var_BtoO_step4
                               CALL PrintString
                               LEA  DX, var_BtoO_final
                               CALL PrintString
                               CALL PrintFinalOctalResult
                               CALL PrintNewLine
                               CALL PrintString_wait
                       
                               RET
SUBMAIN_BO ENDP

    ; ======= BINARY TO OCTAL EXPLANATION PROCEDURES =======
    
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
                               
                               LEA  DX, var_BtoO_space
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

    ; Print binary digits grouped in brackets of 3
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
                               MOV  BL, 3
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Print leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _PrintCompleteGroups
                               
                               LEA  DX, var_BtoO_openBracket
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
                               
                               LEA  DX, var_BtoO_closeBracket
                               CALL PrintString
                               
                               CMP  BL, 0                         ; If no complete groups, finish
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoO_space
                               CALL PrintString
                       
    _PrintCompleteGroups:      
                               CMP  BL, 0
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoO_openBracket
                               CALL PrintString
                               
    ; Print 3 digits
                               MOV  CL, 3
    _PrintGroupDigits:         
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintGroupDigits
                               
                               LEA  DX, var_BtoO_closeBracket
                               CALL PrintString
                               
                               DEC  BL
                               CMP  BL, 0
                               JE   _EndPrintGrouped
                               
                               LEA  DX, var_BtoO_space
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
                               MOV  BL, 3
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Convert leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _ConvertCompleteGroups
                               
                               LEA  DX, var_BtoO_arrow
                               CALL PrintString
                               LEA  DX, var_BtoO_openBracket
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
                               
                               LEA  DX, var_BtoO_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoO_equals
                               CALL PrintString
                               
    ; Calculate and print the decimal value for remainder group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, BH                        ; Number of digits in group
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintSingleDigit
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
                               LEA  DX, var_BtoO_arrow
                               CALL PrintString
                               LEA  DX, var_BtoO_openBracket
                               CALL PrintString
                               
    ; Print 3 digits
                               PUSH SI
                               MOV  CL, 3
    _PrintThreeDigits:         
                               MOV  DL, [SI]
                               MOV  AH, 02h
                               INT  21h
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _PrintThreeDigits
                               
                               LEA  DX, var_BtoO_closeBracket
                               CALL PrintString
                               LEA  DX, var_BtoO_equals
                               CALL PrintString
                               
    ; Calculate and print decimal value for this group
                               POP  SI                            ; Restore SI to start of group
                               MOV  CL, 3                         ; Always 3 digits for complete groups
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintSingleDigit
                               CALL PrintNewLine
                               
                               ADD  SI, 3                         ; Move to next group
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

    ; Print the final octal result
PrintFinalOctalResult PROC
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
                               MOV  BL, 3
                               DIV  BL                            ; AL = complete groups, AH = remainder
                               
                               MOV  BH, AH                        ; BH = remainder digits
                               MOV  BL, AL                        ; BL = complete groups
                       
    ; Convert leftmost incomplete group if exists
                               CMP  BH, 0
                               JE   _PrintCompleteResults
                               
                               MOV  CL, BH                        ; Number of digits in remainder group
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintSingleDigit
                               
    ; Move SI to next group
                               MOV  CL, BH
    _SkipRemainder:            
                               INC  SI
                               DEC  CL
                               CMP  CL, 0
                               JNE  _SkipRemainder
                       
    _PrintCompleteResults:     
                               CMP  BL, 0
                               JE   _EndFinalResult
                               
    _PrintResultLoop:          
                               MOV  CL, 3                         ; Always 3 digits for complete groups
                               CALL CalculateGroupValueFromSI     ; Calculate value
                               CALL PrintSingleDigit
                               ADD  SI, 3                         ; Move to next group
                               DEC  BL
                               CMP  BL, 0
                               JNE  _PrintResultLoop
                       
    _EndFinalResult:           
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintFinalOctalResult ENDP

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

END SUBMAIN_BO