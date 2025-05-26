.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; Decimal to Octal explanation messages
    var_DtoO_step1        DB "-> step 1: Take your number", 13, 10, "$"
    var_DtoO_step2        DB "-> step 2: Divide your number by 8, take the quotient, and divide it again", 13, 10, "$"
    var_DtoO_step3        DB "-> BE CAREFUL: Repeat until the final quotient is 0 (not float)", 13, 10, "$"
    var_DtoO_step4        DB "-> Number left of % is the quotient for each case", 13, 10, "$"
    var_DtoO_step5        DB "-> step 3: Put your remainders together (from bottom to top)", 13, 10, "$"
    var_DtoO_step6        DB "-> BE CAREFUL: You don't need to include the quotients", 13, 10, "$"
    var_DtoO_step7        DB "-> step 4: The result is your number in octal format!", 13, 10, "$"
    var_DtoO_arrow        DB "-> $"
    var_DtoO_space        DB " $"
    var_DtoO_final        DB "-> Your final number: $"
    var_DtoO_div          DB " / 8 = $"
    var_DtoO_mod          DB " % $"
    var_DtoO_openBracket  DB "[$"
    var_DtoO_closeBracket DB "]$"

    ; Buffer to store division remainders (only remainders needed for octal)
    DIVISION_REMAINDERS   DB 20 DUP(?)                      ; Space for up to 20 octal digits
    DIVISION_COUNT        DB 0                              ; Number of divisions performed
    
    ; 32-bit number storage
    NUMBER_LOW            DW 0                              ; Low 16 bits of number
    NUMBER_HIGH           DW 0                              ; High 16 bits of number

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_DO PROC NEAR PUBLIC
                           CALL ClearScreen
                           CALL PrintNewLine
                           CALL PrintNewLine
                       
    ; Step 1: Show the input number
                           LEA  DX, var_DtoO_step1
                           CALL PrintString
                           LEA  DX, var_DtoO_arrow
                           CALL PrintString
                           CALL PrintInputNumber
                           CALL PrintNewLine
                       
    ; Step 2: Show division explanation
                           LEA  DX, var_DtoO_step2
                           CALL PrintString
                           LEA  DX, var_DtoO_step3
                           CALL PrintString
                           LEA  DX, var_DtoO_step4
                           CALL PrintString
                           CALL PerformDivisions
                       
    ; Step 3: Show how to read the result
                           LEA  DX, var_DtoO_step5
                           CALL PrintString
                           LEA  DX, var_DtoO_step6
                           CALL PrintString
                       
    ; Step 4: Show final result
                           LEA  DX, var_DtoO_step7
                           CALL PrintString
                           LEA  DX, var_DtoO_final
                           CALL PrintString
                           CALL PrintFinalOctalResult
                           CALL PrintNewLine
                               
                           CALL PrintNewLine
                           CALL PrintString_wait
                           RET
SUBMAIN_DO ENDP

    ; ======= DECIMAL TO OCTAL EXPLANATION PROCEDURES =======
    
    ; Print the input decimal number
PrintInputNumber PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           PUSH SI
                       
                           LEA  SI, BUFFER_IntputStr
                           MOV  CL, [SI + 1]                 ; Get actual length
                           MOV  CH, 0
                           ADD  SI, 2                        ; Point to first digit
                       
    ; Print each digit of the input number
    _PrintInputLoop:       
                           CMP  CX, 0
                           JE   _EndPrintInput
                               
                           MOV  DL, [SI]                     ; Get current digit
                           MOV  AH, 02h
                           INT  21h                          ; Print digit
                               
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

    ; Convert input string to number and perform divisions
PerformDivisions PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           PUSH SI
                           PUSH DI
                       
    ; Convert input string to 32-bit number
                           CALL ConvertStringTo32BitNumber   ; Result in NUMBER_HIGH:NUMBER_LOW
                               
    ; Initialize division results buffer
                           LEA  DI, DIVISION_REMAINDERS
                           MOV  DIVISION_COUNT, 0
                       
    _DivisionLoop:         
    ; Check if number is 0 (both high and low parts)
                           MOV  AX, NUMBER_HIGH
                           OR   AX, NUMBER_LOW
                           JZ   _EndDivisions                ; If number is 0, we're done
                               
    ; Print this division step
                           LEA  DX, var_DtoO_arrow
                           CALL PrintString
                           LEA  DX, var_DtoO_openBracket
                           CALL PrintString
                               
    ; Print: [number / 8 = quotient, remainder = remainder]
                           CALL Print32BitNumber             ; Print current number
                           LEA  DX, var_DtoO_div
                           CALL PrintString
                           
    ; Perform 32-bit division by 8
                           CALL Divide32BitBy8               ; Result: quotient in NUMBER_HIGH:NUMBER_LOW, remainder in DL
                           
    ; Store remainder for later octal construction
                           MOV  [DI], DL                     ; Store remainder (0-7)
                           INC  DI                           ; Move to next position
                           INC  DIVISION_COUNT
                           
    ; Print quotient
                           CALL Print32BitNumber             ; Print quotient
                           LEA  DX, var_DtoO_mod
                           CALL PrintString
                           
    ; Print remainder as octal digit (0-7)
                           MOV  AL, [DI-1]                   ; Get the remainder we just stored
                           ADD  AL, '0'                      ; Convert to ASCII (0-7 are all single digits)
                           MOV  DL, AL
                           MOV  AH, 02h
                           INT  21h
                           LEA  DX, var_DtoO_closeBracket
                           CALL PrintString
                           CALL PrintNewLine
                           
                           JMP  _DivisionLoop
                       
    _EndDivisions:         
                           POP  DI
                           POP  SI
                           POP  DX
                           POP  CX
                           POP  BX
                           POP  AX
                           RET
PerformDivisions ENDP

    ; Convert decimal string to 32-bit number
ConvertStringTo32BitNumber PROC
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           PUSH SI
                       
                           LEA  SI, BUFFER_IntputStr
                           MOV  CL, [SI + 1]                 ; Get actual length
                           MOV  CH, 0
                           ADD  SI, 2                        ; Point to first digit
                       
    ; Initialize 32-bit result to 0
                           MOV  NUMBER_LOW, 0
                           MOV  NUMBER_HIGH, 0
                       
    _ConvertLoop:          
                           CMP  CX, 0
                           JE   _EndConvert
                               
    ; Multiply current result by 10 (32-bit multiplication)
                           CALL Multiply32BitBy10
                           
    ; Add current digit
                           MOV  DL, [SI]                     ; Get current digit
                           SUB  DL, '0'                      ; Convert ASCII to value
                           MOV  DH, 0
                           ADD  NUMBER_LOW, DX               ; Add to low word
                           JNC  _NoCarry                     ; If no carry, continue
                           INC  NUMBER_HIGH                  ; Add carry to high word
                           
    _NoCarry:              
                           INC  SI
                           DEC  CX
                           JMP  _ConvertLoop
                       
    _EndConvert:           
                           POP  SI
                           POP  DX
                           POP  CX
                           POP  BX
                           RET
ConvertStringTo32BitNumber ENDP

    ; Multiply 32-bit number (NUMBER_HIGH:NUMBER_LOW) by 10
Multiply32BitBy10 PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           
    ; Save original number
                           MOV  AX, NUMBER_LOW
                           MOV  BX, NUMBER_HIGH
                           
    ; Multiply by 2 (shift left by 1)
                           SHL  AX, 1                        ; Low word * 2
                           RCL  BX, 1                        ; High word * 2 with carry
                           
    ; Save result of *2
                           MOV  CX, AX                       ; CX = low * 2
                           MOV  DX, BX                       ; DX = high * 2
                           
    ; Multiply by 4 more (shift left by 2 more times)
                           SHL  AX, 1
                           RCL  BX, 1
                           SHL  AX, 1
                           RCL  BX, 1
                           ; Now AX:BX = original * 8
                           
    ; Add the *2 result to get *10
                           ADD  AX, CX                       ; low = low*8 + low*2
                           ADC  BX, DX                       ; high = high*8 + high*2 + carry
                           
                           MOV  NUMBER_LOW, AX
                           MOV  NUMBER_HIGH, BX
                           
                           POP  DX
                           POP  CX
                           POP  BX
                           POP  AX
                           RET
Multiply32BitBy10 ENDP

    ; Divide 32-bit number by 8, return remainder in DL
Divide32BitBy8 PROC
                           PUSH AX
                           PUSH BX
                           
                           MOV  AX, NUMBER_HIGH              ; Get high word
                           MOV  BX, NUMBER_LOW               ; Get low word
                           
    ; Get the remainder (bottom 3 bits of low word) BEFORE division
                           MOV  DL, BL
                           AND  DL, 7                        ; DL = remainder (0-7)
                           
    ; Divide by 8 (shift right by 3)
                           SHR  AX, 1                        ; High word / 2
                           RCR  BX, 1                        ; Low word / 2 with carry from high
                           SHR  AX, 1                        ; High word / 4
                           RCR  BX, 1                        ; Low word / 4 with carry from high
                           SHR  AX, 1                        ; High word / 8
                           RCR  BX, 1                        ; Low word / 8 with carry from high
                           
                           MOV  NUMBER_HIGH, AX
                           MOV  NUMBER_LOW, BX
                           
                           POP  BX
                           POP  AX
                           RET
Divide32BitBy8 ENDP

    ; Print 32-bit number stored in NUMBER_HIGH:NUMBER_LOW
Print32BitNumber PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           PUSH SI
                           
    ; Check if number is 0
                           MOV  AX, NUMBER_HIGH
                           OR   AX, NUMBER_LOW
                           JNZ  _NotZero
                           
    ; Print 0
                           MOV  DL, '0'
                           MOV  AH, 02h
                           INT  21h
                           JMP  _EndPrint32
                           
    _NotZero:
    ; Save current number for restoration later
                           MOV  AX, NUMBER_LOW
                           MOV  BX, NUMBER_HIGH
                           PUSH AX
                           PUSH BX
                           
    ; Use a temporary buffer for storing digits
                           LEA  SI, DIVISION_REMAINDERS      ; Reuse buffer for digits (safe since we're in middle of calculation)
                           ADD  SI, 10                       ; Use second half of buffer to avoid conflicts
                           MOV  CX, 0                        ; Digit counter
                           
    _Convert32Loop:
    ; Check if number is 0
                           MOV  AX, NUMBER_HIGH
                           OR   AX, NUMBER_LOW
                           JZ   _Print32Digits
                           
    ; Divide by 10
                           CALL Divide32BitBy10              ; Quotient in NUMBER_HIGH:NUMBER_LOW, remainder in DL
                           MOV  [SI], DL                     ; Store digit
                           INC  SI
                           INC  CX
                           JMP  _Convert32Loop
                           
    _Print32Digits:
    ; Print digits in reverse order
                           DEC  SI                           ; Point to last digit
                           
    _Print32Loop:
                           CMP  CX, 0
                           JE   _Restore32Number
                           
                           MOV  DL, [SI]
                           ADD  DL, '0'                      ; Convert to ASCII
                           MOV  AH, 02h
                           INT  21h
                           
                           DEC  SI
                           DEC  CX
                           JMP  _Print32Loop
                           
    _Restore32Number:
    ; Restore original number
                           POP  BX
                           POP  AX
                           MOV  NUMBER_HIGH, BX
                           MOV  NUMBER_LOW, AX
                           
    _EndPrint32:
                           POP  SI
                           POP  DX
                           POP  CX
                           POP  BX
                           POP  AX
                           RET
Print32BitNumber ENDP

    ; Divide 32-bit number by 10, return remainder in DL
Divide32BitBy10 PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           
    ; Use simple algorithm for 32-bit division by 10
                           MOV  AX, NUMBER_HIGH              ; High 16 bits
                           MOV  DX, 0                        ; Clear DX for division
                           MOV  BX, 10
                           DIV  BX                           ; AX = high/10, DX = remainder from high part
                           MOV  NUMBER_HIGH, AX              ; Store new high part
                           
    ; Now divide low part with remainder from high part
                           MOV  AX, NUMBER_LOW               ; Low 16 bits  
                           ; DX already contains remainder from high part
                           DIV  BX                           ; AX = (remainder*65536 + low)/10, DX = final remainder
                           MOV  NUMBER_LOW, AX               ; Store new low part
                           
                           ; DL now contains the remainder (0-9)
                           
                           POP  CX
                           POP  BX
                           POP  AX
                           RET
Divide32BitBy10 ENDP

    ; Print the final octal result by reading remainders from last to first
PrintFinalOctalResult PROC
                           PUSH AX
                           PUSH BX
                           PUSH CX
                           PUSH DX
                           PUSH SI
                       
                           MOV  CL, DIVISION_COUNT
                           CMP  CL, 0
                           JE   _PrintZero                   ; If no divisions, number was 0
                               
    ; Start from the last remainder and work backwards
                           LEA  SI, DIVISION_REMAINDERS
                           MOV  AL, CL                       ; Number of remainders
                           DEC  AL                           ; Last index
                           MOV  BL, 1                        ; Each remainder is 1 byte
                           MUL  BL                           ; AX = offset to last remainder
                           ADD  SI, AX                       ; SI points to last remainder
                               
    ; Print remainders from last to first to form octal number
    _PrintRemainderLoop:   
                           CMP  CL, 0
                           JE   _EndPrintOctal
                               
                           MOV  AL, [SI]                     ; Get remainder (0-7)
                           ADD  AL, '0'                      ; Convert to ASCII (all octal digits are 0-7)
                           MOV  DL, AL
                           MOV  AH, 02h
                           INT  21h
                               
                           DEC  SI                           ; Move to previous remainder
                           DEC  CL
                           JMP  _PrintRemainderLoop
                               
                           JMP  _EndPrintOctal
                       
    _PrintZero:            
                           MOV  DL, '0'
                           MOV  AH, 02h
                           INT  21h
                       
    _EndPrintOctal:        
                           POP  SI
                           POP  DX
                           POP  CX
                           POP  BX
                           POP  AX
                           RET
PrintFinalOctalResult ENDP

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

END SUBMAIN_DO