.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; Hexadecimal to Binary explanation messages
    var_HtoB_step1        DB "-> step 1: Take your hexadecimal number", 13, 10, "$"
    var_HtoB_step2        DB "-> step 2: Convert the hexadecimal number to decimal", 13, 10, "$"
    var_HtoB_step3        DB "-> BE CAREFUL: Multiply each digit by 16^(number position)", 13, 10, "$"
    var_HtoB_step4        DB "-> step 3: Divide youy number by 2, take the quotient, and divide it again", 13, 10, "$"
    var_HtoB_step5        DB "-> HEY!: Repeat until the final quotient is 0", 13, 10, "$"
    var_HtoB_step6        DB "-> Number left of % is the quotient for each case", 13, 10, "$"
    var_HtoB_step7        DB "-> step 4: Put your remainders together (from bottom to top)", 13, 10, "$"
    var_HtoB_arrow        DB "-> $"
    var_HtoB_space        DB " $"
    var_HtoB_final        DB "-> Your final binary number: $"
    var_HtoB_div          DB " / 2 = $"
    var_HtoB_mod          DB " % $"
    var_HtoB_openBracket  DB "[$"
    var_HtoB_closeBracket DB "]$"
    var_HtoB_equals       DB " = $"
    var_HtoB_plus         DB " + $"
    var_HtoB_times        DB "*$"
    var_HtoB_power        DB "^$"
    var_HtoB_openParen    DB "($"
    var_HtoB_closeParen   DB ")$"
    var_HtoB_openSquare   DB "[$"
    var_HtoB_closeSquare  DB "]$"
    var_HtoB_backtick     DB "`$"

    ; Buffer to store division remainders for binary result
    DIVISION_REMAINDERS   DB 40 DUP(?)                                                                                            ; Space for up to 40 binary digits
    DIVISION_COUNT        DB 0                                                                                                    ; Number of divisions performed
    
    ; 32-bit number storage
    NUMBER_LOW            DW 0                                                                                                    ; Low 16 bits of number
    NUMBER_HIGH           DW 0                                                                                                    ; High 16 bits of number

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_HB PROC NEAR PUBLIC
                                  CALL ClearScreen
                                  CALL PrintNewLine
                                  CALL PrintNewLine
                       
    ; Step 1: Show the input hexadecimal number
                                  LEA  DX, var_HtoB_step1
                                  CALL PrintString
                                  LEA  DX, var_HtoB_arrow
                                  CALL PrintString
                                  CALL PrintInputNumber
                                  CALL PrintNewLine
                       
    ; Step 2: Convert hex to decimal and show the process
                                  LEA  DX, var_HtoB_step2
                                  CALL PrintString
                                  LEA  DX, var_HtoB_step3
                                  CALL PrintString
                                  CALL ShowHexToDecimalConversion
                       
    ; Step 3: Show binary conversion explanation
                                  LEA  DX, var_HtoB_step4
                                  CALL PrintString
                                  LEA  DX, var_HtoB_step5
                                  CALL PrintString
                                  LEA  DX, var_HtoB_step6
                                  CALL PrintString
                                  CALL PerformBinaryDivisions
                       
    ; Step 4: Show final result
                                  LEA  DX, var_HtoB_step7
                                  CALL PrintString
                                  LEA  DX, var_HtoB_final
                                  CALL PrintString
                                  LEA  DX, var_HtoB_backtick
                                  CALL PrintString
                                  CALL PrintFinalBinaryResult
                                  LEA  DX, var_HtoB_backtick
                                  CALL PrintString
                               
                                  CALL PrintNewLine
                                  CALL PrintString_wait
                                  RET
SUBMAIN_HB ENDP

    ; ======= HEXADECIMAL TO BINARY EXPLANATION PROCEDURES =======
    
    ; Print the input hexadecimal number
PrintInputNumber PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  LEA  SI, BUFFER_IntputStr
                                  MOV  CL, [SI + 1]                     ; Get actual length
                                  MOV  CH, 0
                                  ADD  SI, 2                            ; Point to first digit
                       
    ; Print each digit of the input number
    _PrintInputLoop:              
                                  CMP  CX, 0
                                  JE   _EndPrintInput
                               
                                  MOV  DL, [SI]                         ; Get current digit
                                  MOV  AH, 02h
                                  INT  21h                              ; Print digit
                               
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

    ; Show the hex to decimal conversion process with explanation
ShowHexToDecimalConversion PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
    ; Convert hex string to 32-bit number and show the process
                                  CALL ConvertHexStringTo32BitNumber
                           
    ; Show the final decimal result
                                  LEA  DX, var_HtoB_arrow
                                  CALL PrintString
                                  CALL Print32BitNumber
                           
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ShowHexToDecimalConversion ENDP

    ; Convert input string to number and perform binary divisions
PerformBinaryDivisions PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
    ; Initialize division results buffer
                                  LEA  DI, DIVISION_REMAINDERS
                                  MOV  DIVISION_COUNT, 0
                       
    _DivisionLoop:                
    ; Check if number is 0 (both high and low parts)
                                  MOV  AX, NUMBER_HIGH
                                  OR   AX, NUMBER_LOW
                                  JZ   _EndDivisions                    ; If number is 0, we're done
                               
    ; Print this division step
                                  LEA  DX, var_HtoB_arrow
                                  CALL PrintString
                                  LEA  DX, var_HtoB_openBracket
                                  CALL PrintString
                               
    ; Print: [number / 2 = quotient % remainder]
                                  CALL Print32BitNumber                 ; Print current number
                                  LEA  DX, var_HtoB_div
                                  CALL PrintString
                           
    ; Perform 32-bit division by 2
                                  CALL Divide32BitBy2                   ; Result: quotient in NUMBER_HIGH:NUMBER_LOW, remainder in DL
                           
    ; Store remainder for later binary construction
                                  MOV  [DI], DL                         ; Store remainder (0-1)
                                  INC  DI                               ; Move to next position
                                  INC  DIVISION_COUNT
                           
    ; Print quotient
                                  CALL Print32BitNumber                 ; Print quotient
                                  LEA  DX, var_HtoB_mod
                                  CALL PrintString
                           
    ; Print remainder as binary digit (0 or 1)
                                  MOV  AL, [DI-1]                       ; Get the remainder we just stored
                                  ADD  AL, '0'                          ; Convert to ASCII
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                                  LEA  DX, var_HtoB_closeBracket
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
PerformBinaryDivisions ENDP

    ; Convert hexadecimal string to 32-bit number with detailed explanation
ConvertHexStringTo32BitNumber PROC
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
                                  LEA  SI, BUFFER_IntputStr
                                  MOV  CL, [SI + 1]                     ; Get actual length
                                  MOV  CH, 0
                                  ADD  SI, 2                            ; Point to first digit
                           
    ; Initialize 32-bit result to 0
                                  MOV  NUMBER_LOW, 0
                                  MOV  NUMBER_HIGH, 0
                           
    ; Show the conversion formula first
                                  LEA  DX, var_HtoB_arrow
                                  CALL PrintString
                                  LEA  DX, var_HtoB_openSquare
                                  CALL PrintString
                           
    ; Print the formula: [(digit×16^pos)+...]
                                  PUSH SI
                                  PUSH CX
                                  MOV  DI, CX                           ; Save length
                                  DEC  DI                               ; Position counter (0-based from right)
                           
    _FormulaLoop:                 
                                  CMP  CX, 0
                                  JE   _EndFormula
                           
                                  LEA  DX, var_HtoB_openParen
                                  CALL PrintString
                           
    ; Print the hex digit
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                           
                                  LEA  DX, var_HtoB_times
                                  CALL PrintString
                           
    ; Print 16
                                  MOV  DL, '1'
                                  MOV  AH, 02h
                                  INT  21h
                                  MOV  DL, '6'
                                  MOV  AH, 02h
                                  INT  21h
                           
                                  LEA  DX, var_HtoB_power
                                  CALL PrintString
                           
    ; Print position
                                  MOV  AX, DI                           ; Move DI (position) to AX
                                  CALL PrintSingleDigit
                           
                                  LEA  DX, var_HtoB_closeParen
                                  CALL PrintString
                           
                                  CMP  CX, 1
                                  JE   _NoPlus
                                  LEA  DX, var_HtoB_plus
                                  CALL PrintString
                           
    _NoPlus:                      
                                  INC  SI
                                  DEC  CX
                                  DEC  DI
                                  JMP  _FormulaLoop
                           
    _EndFormula:                  
                                  LEA  DX, var_HtoB_closeSquare
                                  CALL PrintString
                           
    ; Show equals sign and result
                                  LEA  DX, var_HtoB_equals
                                  CALL PrintString
                           
    ; Restore and do actual conversion
                                  POP  CX
                                  POP  SI
                           
    _ConvertLoop:                 
                                  CMP  CX, 0
                                  JE   _EndConvertHex
                               
    ; Multiply current result by 16 (32-bit multiplication)
                                  CALL Multiply32BitBy16
                           
    ; Add current hex digit
                                  MOV  AL, [SI]                         ; Get current hex digit
                                  CALL ConvertHexCharToDecimal          ; Convert to decimal value (0-15)
                                  MOV  DL, AL
                                  MOV  DH, 0
                                  ADD  NUMBER_LOW, DX                   ; Add to low word
                                  JNC  _NoCarryHex                      ; If no carry, continue
                                  INC  NUMBER_HIGH                      ; Add carry to high word
                           
    _NoCarryHex:                  
                                  INC  SI
                                  DEC  CX
                                  JMP  _ConvertLoop
                       
    _EndConvertHex:               
    ; Print the final result
                                  CALL Print32BitNumber
                                  CALL PrintNewLine
                           
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  RET
ConvertHexStringTo32BitNumber ENDP

    ; Convert hex character to decimal value (0-15)
ConvertHexCharToDecimal PROC
                                  CMP  AL, '9'
                                  JLE  _IsDigit
                           
    ; Convert A-F to 10-15
                                  CMP  AL, 'F'
                                  JLE  _IsUpperHex
    ; Must be lowercase a-f
                                  SUB  AL, 'a' - 10
                                  JMP  _EndConvertHex2
                           
    _IsUpperHex:                  
                                  SUB  AL, 'A' - 10
                                  JMP  _EndConvertHex2
                           
    _IsDigit:                     
                                  SUB  AL, '0'
                           
    _EndConvertHex2:              
                                  RET
ConvertHexCharToDecimal ENDP

    ; Calculate 16^power, result in AX (for powers 0-4, sufficient for display)
Calculate16Power PROC
                                  PUSH BX
                                  PUSH CX
                           
                                  CMP  AL, 0
                                  JNE  _NotZeroPower
                                  MOV  AX, 1                            ; 16^0 = 1
                                  JMP  _EndPower
                           
    _NotZeroPower:                
                                  MOV  BX, 16
                                  MOV  CL, AL                           ; Power counter
                                  MOV  CH, 0
                                  MOV  AX, 1                            ; Start with 1
                           
    _PowerLoop:                   
                                  CMP  CX, 0
                                  JE   _EndPower
                                  MUL  BX                               ; AX = AX * 16
                                  DEC  CX
                                  JMP  _PowerLoop
                           
    _EndPower:                    
                                  POP  CX
                                  POP  BX
                                  RET
Calculate16Power ENDP

    ; Print 16-bit number in AX
Print16BitNumber PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                           
                                  MOV  BX, 10                           ; Divisor
                                  MOV  CX, 0                            ; Digit counter
                           
    ; Handle zero case
                                  CMP  AX, 0
                                  JNE  _Convert16Loop
                                  MOV  DL, '0'
                                  MOV  AH, 02h
                                  INT  21h
                                  JMP  _End16Print
                           
    ; Convert number to string (reverse order)
    _Convert16Loop:               
                                  MOV  DX, 0                            ; Clear DX for division
                                  DIV  BX                               ; AX = AX / 10, DX = remainder
                                  PUSH DX                               ; Save digit
                                  INC  CX                               ; Count digits
                                  CMP  AX, 0
                                  JNE  _Convert16Loop
                           
    ; Print digits in correct order
    _Print16Loop:                 
                                  CMP  CX, 0
                                  JE   _End16Print
                                  POP  DX                               ; Get digit
                                  ADD  DL, '0'                          ; Convert to ASCII
                                  MOV  AH, 02h
                                  INT  21h                              ; Print digit
                                  DEC  CX
                                  JMP  _Print16Loop
                           
    _End16Print:                  
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
Print16BitNumber ENDP

    ; Multiply 32-bit number (NUMBER_HIGH:NUMBER_LOW) by 16
Multiply32BitBy16 PROC
                                  PUSH AX
                                  PUSH BX
                           
                                  MOV  AX, NUMBER_LOW
                                  MOV  BX, NUMBER_HIGH
                           
    ; Multiply by 16 (shift left by 4)
                                  SHL  AX, 1                            ; * 2
                                  RCL  BX, 1
                                  SHL  AX, 1                            ; * 4
                                  RCL  BX, 1
                                  SHL  AX, 1                            ; * 8
                                  RCL  BX, 1
                                  SHL  AX, 1                            ; * 16
                                  RCL  BX, 1
                           
                                  MOV  NUMBER_LOW, AX
                                  MOV  NUMBER_HIGH, BX
                           
                                  POP  BX
                                  POP  AX
                                  RET
Multiply32BitBy16 ENDP

    ; Divide 32-bit number by 2, return remainder in DL
Divide32BitBy2 PROC
                                  PUSH AX
                                  PUSH BX
                           
                                  MOV  AX, NUMBER_HIGH                  ; Get high word
                                  MOV  BX, NUMBER_LOW                   ; Get low word
                           
    ; Get the remainder (LSB of low word) BEFORE division
                                  MOV  DL, BL
                                  AND  DL, 1                            ; DL = remainder (0 or 1)
                           
    ; Divide by 2 (shift right by 1)
                                  SHR  AX, 1                            ; High word / 2
                                  RCR  BX, 1                            ; Low word / 2 with carry from high
                           
                                  MOV  NUMBER_HIGH, AX
                                  MOV  NUMBER_LOW, BX
                           
                                  POP  BX
                                  POP  AX
                                  RET
Divide32BitBy2 ENDP

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
                                  JNZ  _NotZero32
                           
    ; Print 0
                                  MOV  DL, '0'
                                  MOV  AH, 02h
                                  INT  21h
                                  JMP  _EndPrint32
                           
    _NotZero32:                   
    ; Save current number for restoration later
                                  MOV  AX, NUMBER_LOW
                                  MOV  BX, NUMBER_HIGH
                                  PUSH AX
                                  PUSH BX
                           
    ; Use a temporary buffer for storing digits
                                  LEA  SI, DIVISION_REMAINDERS          ; Reuse buffer for digits
                                  ADD  SI, 20                           ; Use second half to avoid conflicts
                                  MOV  CX, 0                            ; Digit counter
                           
    _Convert32Loop:               
    ; Check if number is 0
                                  MOV  AX, NUMBER_HIGH
                                  OR   AX, NUMBER_LOW
                                  JZ   _Print32Digits
                           
    ; Divide by 10
                                  CALL Divide32BitBy10                  ; Quotient in NUMBER_HIGH:NUMBER_LOW, remainder in DL
                                  MOV  [SI], DL                         ; Store digit
                                  INC  SI
                                  INC  CX
                                  JMP  _Convert32Loop
                           
    _Print32Digits:               
    ; Print digits in reverse order
                                  DEC  SI                               ; Point to last digit
                           
    _Print32Loop:                 
                                  CMP  CX, 0
                                  JE   _Restore32Number
                           
                                  MOV  DL, [SI]
                                  ADD  DL, '0'                          ; Convert to ASCII
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
                                  MOV  AX, NUMBER_HIGH                  ; High 16 bits
                                  MOV  DX, 0                            ; Clear DX for division
                                  MOV  BX, 10
                                  DIV  BX                               ; AX = high/10, DX = remainder from high part
                                  MOV  NUMBER_HIGH, AX                  ; Store new high part
                           
    ; Now divide low part with remainder from high part
                                  MOV  AX, NUMBER_LOW                   ; Low 16 bits
    ; DX already contains remainder from high part
                                  DIV  BX                               ; AX = (remainder*65536 + low)/10, DX = final remainder
                                  MOV  NUMBER_LOW, AX                   ; Store new low part
                           
    ; DL now contains the remainder (0-9)
                           
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
Divide32BitBy10 ENDP

    ; Print the final binary result with spacing every 4 bits
PrintFinalBinaryResult PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  MOV  CL, DIVISION_COUNT
                                  CMP  CL, 0
                                  JE   _PrintZero                       ; If no divisions, number was 0
                               
    ; Start from the last remainder and work backwards
                                  LEA  SI, DIVISION_REMAINDERS
                                  MOV  AL, CL                           ; Number of remainders
                                  DEC  AL                               ; Last index
                                  MOV  BL, 1                            ; Each remainder is 1 byte
                                  MUL  BL                               ; AX = offset to last remainder
                                  ADD  SI, AX                           ; SI points to last remainder
                           
                                  MOV  BL, 0                            ; Counter for spacing every 4 bits
                               
    ; Print remainders from last to first to form binary number
    _PrintRemainderLoop:          
                                  CMP  CL, 0
                                  JE   _EndPrintBinary
                           
    ; Add space every 4 bits for readability
                                  CMP  BL, 4
                                  JNE  _NoSpace
                                  MOV  DL, ' '
                                  MOV  AH, 02h
                                  INT  21h
                                  MOV  BL, 0                            ; Reset counter
                           
    _NoSpace:                     
                                  MOV  AL, [SI]                         ; Get remainder (0 or 1)
                                  ADD  AL, '0'                          ; Convert to ASCII
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                           
                                  INC  BL                               ; Increment spacing counter
                                  DEC  SI                               ; Move to previous remainder
                                  DEC  CL
                                  JMP  _PrintRemainderLoop
                               
                                  JMP  _EndPrintBinary
                       
    _PrintZero:                   
                                  MOV  DL, '0'
                                  MOV  AH, 02h
                                  INT  21h
                       
    _EndPrintBinary:              
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
PrintFinalBinaryResult ENDP

    ; Print a single digit number (0-9)
PrintSingleDigit PROC
                                  PUSH DX
                                  CMP  AL, 9
                                  JLE  _SingleDigit
    ; Handle numbers > 9 by converting to string
                                  CALL Print16BitNumber
                                  JMP  _EndSingle
                           
    _SingleDigit:                 
                                  ADD  AL, '0'                          ; Convert to ASCII
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                           
    _EndSingle:                   
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

END SUBMAIN_HB