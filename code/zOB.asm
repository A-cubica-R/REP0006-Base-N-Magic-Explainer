.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    
    ; Octal to Binary explanation messages
    var_OtoB_step1        DB "-> step 1: Take your number", 13, 10, "$"
    var_OtoB_step2        DB "-> step 2: Each octal digit (0-7) maps to exactly 3 binary digits", 13, 10, "$"
    var_OtoB_step3        DB "-> step 3: Convert each octal digit by dividing by 2 repeatedly", 13, 10, "$"
    var_OtoB_step4        DB "-> step 4: Combine all 3-bit binary groups to get the final result", 13, 10, "$"
    var_OtoB_arrow        DB "-> $"
    var_OtoB_space        DB " $"
    var_OtoB_final        DB "-> Your final number: $"
    var_OtoB_maps         DB " maps to $"
    var_OtoB_div          DB " / 2 = $"
    var_OtoB_mod          DB " % $"
    var_OtoB_openBracket  DB "[$"
    var_OtoB_closeBracket DB "]$"
    var_OtoB_combining    DB "-> Combining: $"

    ; Buffer to store binary result for each octal digit
    BINARY_GROUPS         DB 27 DUP(?)                                                                            ; Up to 9 octal digits * 3 binary digits each
    BINARY_COUNT          DB 0                                                                                    ; Number of binary digits
    OCTAL_DIGITS          DB 10 DUP(?)                                                                            ; Store octal digits
    OCTAL_COUNT           DB 0                                                                                    ; Number of octal digits

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_OB PROC NEAR PUBLIC
                               CALL ClearScreen
                               CALL PrintNewLine
                               CALL PrintNewLine
                       
    ; Step 1: Show the input number with spaces
                               LEA  DX, var_OtoB_step1
                               CALL PrintString
                               LEA  DX, var_OtoB_arrow
                               CALL PrintString
                               CALL PrintInputNumberWithSpaces
                               CALL PrintNewLine
                       
    ; Step 2: Explain the mapping concept
                               LEA  DX, var_OtoB_step2
                               CALL PrintString
                       
    ; Step 3: Show conversion process for each digit
                               LEA  DX, var_OtoB_step3
                               CALL PrintString
                               CALL ProcessOctalDigits
                       
    ; Step 4: Show final combination
                               LEA  DX, var_OtoB_step4
                               CALL PrintString
                               LEA  DX, var_OtoB_combining
                               CALL PrintString
                               CALL PrintCombinedBinaryResult
                               CALL PrintNewLine
                           
                               LEA  DX, var_OtoB_final
                               CALL PrintString
                               CALL PrintFinalBinaryResult
                               CALL PrintNewLine
                               
                               CALL PrintNewLine
                               CALL PrintString_wait
                               RET
SUBMAIN_OB ENDP

    ; ======= OCTAL TO BINARY CONVERSION PROCEDURES =======
    
    ; Print the input octal number with spaces between digits
PrintInputNumberWithSpaces PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                       
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                       
    ; Print each digit of the input number with spaces
    _PrintInputLoopOB:         
                               CMP  CX, 0
                               JE   _EndPrintInputOB
                               
                               MOV  DL, [SI]                      ; Get current digit
                               MOV  AH, 02h
                               INT  21h                           ; Print digit
                           
                               DEC  CX
                               CMP  CX, 0                         ; Check if this was the last digit
                               JE   _EndPrintInputOB
                           
    ; Print space between digits
                               MOV  DL, ' '
                               MOV  AH, 02h
                               INT  21h
                               
                               INC  SI
                               JMP  _PrintInputLoopOB
                       
    _EndPrintInputOB:          
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintInputNumberWithSpaces ENDP

    ; Process each octal digit and show division process
ProcessOctalDigits PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                               PUSH DI
                       
    ; Store octal digits for later use
                               LEA  SI, BUFFER_IntputStr
                               MOV  CL, [SI + 1]                  ; Get actual length
                               MOV  OCTAL_COUNT, CL
                               MOV  CH, 0
                               ADD  SI, 2                         ; Point to first digit
                           
                               LEA  DI, OCTAL_DIGITS
    _StoreOctalLoop:           
                               CMP  CX, 0
                               JE   _ProcessDigits
                           
                               MOV  AL, [SI]
                               SUB  AL, '0'                       ; Convert ASCII to value
                               MOV  [DI], AL
                           
                               INC  SI
                               INC  DI
                               DEC  CX
                               JMP  _StoreOctalLoop
                           
    _ProcessDigits:            
    ; Process each octal digit
                               LEA  SI, OCTAL_DIGITS
                               LEA  DI, BINARY_GROUPS
                               MOV  CL, OCTAL_COUNT
                               MOV  BINARY_COUNT, 0
                           
    _ProcessDigitLoop:         
                               CMP  CL, 0
                               JE   _EndProcessDigits
                           
                               PUSH CX                            ; Save counter
                           
    ; Show division process for current octal digit
                               LEA  DX, var_OtoB_arrow
                               CALL PrintString
                               LEA  DX, var_OtoB_openBracket
                               CALL PrintString
                           
                               MOV  AL, [SI]                      ; Get octal digit
                               CALL ConvertOctalDigitToBinary     ; Convert and show process
                           
                               LEA  DX, var_OtoB_closeBracket
                               CALL PrintString
                               CALL PrintNewLine
                           
                               INC  SI                            ; Move to next octal digit
                               POP  CX                            ; Restore counter
                               DEC  CL
                               JMP  _ProcessDigitLoop
                           
    _EndProcessDigits:         
                               POP  DI
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
ProcessOctalDigits ENDP

    ; Convert single octal digit (in AL) to binary and show division process
ConvertOctalDigitToBinary PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH DI
                           
    ; Store the octal digit value
                               MOV  BH, AL                        ; BH = octal digit value (0-7)
                           
    ; Print the octal digit
                               ADD  AL, '0'                       ; Convert back to ASCII for display
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                           
                               LEA  DX, var_OtoB_maps
                               CALL PrintString
                           
    ; Get pointer to store binary digits for this octal digit
                               LEA  DI, BINARY_GROUPS
                               MOV  AL, BINARY_COUNT
                               MOV  AH, 0
                               ADD  DI, AX                        ; DI points to where to store next binary digits
                           
    ; Convert octal digit to binary by successive division by 2
                               MOV  AL, BH                        ; Restore octal digit value (0-7)
                               MOV  CX, 3                         ; Need exactly 3 binary digits
                           
    ; We'll store the binary digits in correct order (left to right)
                               PUSH DI                            ; Save start position
                               ADD  DI, 2                         ; Start from rightmost position
                           
    _DivisionLoop_OB:          
                               CMP  CX, 0
                               JE   _ShowBinaryResult
                           
    ; Show current number being divided
                               PUSH AX                            ; Save current value
                               CALL PrintDecimalDigit             ; Print current number
                               POP  AX                            ; Restore current value
                           
                               LEA  DX, var_OtoB_div
                               CALL PrintString
                           
    ; Perform division by 2
                               MOV  AH, 0                         ; Clear high byte
                               MOV  BL, 2
                               DIV  BL                            ; AL = quotient, AH = remainder
                           
    ; Save remainder before printing quotient (PrintDecimalDigit modifies AH)
                               PUSH AX                            ; Save both quotient and remainder
                               MOV  BH, AH                        ; Save remainder in BH
                               CALL PrintDecimalDigit             ; Print quotient (in AL)
                               POP  AX                            ; Restore original values
                           
                               LEA  DX, var_OtoB_mod
                               CALL PrintString
                           
    ; Store and print remainder
                               MOV  [DI], BH                      ; Store remainder (0 or 1)
                               MOV  DL, BH                        ; Use saved remainder
                               ADD  DL, '0'
                               PUSH AX
                               MOV  AH, 02h
                               INT  21h
                               POP  AX
                           
    ; Prepare for next iteration - quotient becomes the new number to divide
    ; AL already contains the quotient from the division
                           
                               CMP  CX, 1                         ; Last iteration?
                               JE   _LastDivision_OB
                           
                               MOV  DL, ','                       ; Add comma between divisions
                               PUSH AX
                               MOV  AH, 02h
                               INT  21h
                               MOV  DL, ' '
                               MOV  AH, 02h
                               INT  21h
                               POP  AX
                           
    _LastDivision_OB:          
                               DEC  DI                            ; Move to next position (going right to left)
                               DEC  CX
                               JMP  _DivisionLoop_OB
                           
    _ShowBinaryResult:         
                               POP  DI                            ; Restore start position
    ; Update binary count
                               MOV  AL, BINARY_COUNT
                               ADD  AL, 3
                               MOV  BINARY_COUNT, AL
                           
                               POP  DI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
ConvertOctalDigitToBinary ENDP

    ; Print combined binary result showing the grouping
PrintCombinedBinaryResult PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                           
                               LEA  SI, BINARY_GROUPS
                               MOV  CL, BINARY_COUNT
                               MOV  CH, 0
                           
    _PrintCombinedLoop:        
                               CMP  CX, 0
                               JE   _EndPrintCombined
                           
    ; Print binary digit
                               MOV  DL, [SI]
                               ADD  DL, '0'
                               MOV  AH, 02h
                               INT  21h
                           
    ; Add space every 3 digits to show grouping
                               MOV  AX, CX
                               MOV  BX, 3
                               MOV  DX, 0
                               DIV  BX                            ; DX = remainder
                               CMP  DX, 1                         ; If remainder is 1, we're at group boundary
                               JNE  _NoGroupSpace
                               CMP  CX, 1                         ; Don't add space at the very end
                               JE   _NoGroupSpace
                           
                               MOV  DL, ' '
                               MOV  AH, 02h
                               INT  21h
                           
    _NoGroupSpace:             
                               INC  SI
                               DEC  CX
                               JMP  _PrintCombinedLoop
                           
    _EndPrintCombined:         
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintCombinedBinaryResult ENDP

    ; Print final binary result without spaces
PrintFinalBinaryResult PROC
                               PUSH AX
                               PUSH BX
                               PUSH CX
                               PUSH DX
                               PUSH SI
                           
                               LEA  SI, BINARY_GROUPS
                               MOV  CL, BINARY_COUNT
                               MOV  CH, 0
                           
    _PrintFinalLoop:           
                               CMP  CX, 0
                               JE   _EndPrintFinal
                           
                               MOV  DL, [SI]
                               ADD  DL, '0'
                               MOV  AH, 02h
                               INT  21h
                           
                               INC  SI
                               DEC  CX
                               JMP  _PrintFinalLoop
                           
    _EndPrintFinal:            
                               POP  SI
                               POP  DX
                               POP  CX
                               POP  BX
                               POP  AX
                               RET
PrintFinalBinaryResult ENDP

    ; Print a decimal digit (0-9) in AL
PrintDecimalDigit PROC
                               PUSH DX
                               ADD  AL, '0'
                               MOV  DL, AL
                               MOV  AH, 02h
                               INT  21h
                               POP  DX
                               RET
PrintDecimalDigit ENDP

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

END SUBMAIN_OB