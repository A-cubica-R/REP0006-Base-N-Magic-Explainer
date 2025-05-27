.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; Hexadecimal to Decimal explanation messages
    var_HtoD_step1        DB "-> step 1: Take your hexadecimal number", 13, 10, "$"
    var_HtoD_step2        DB "-> step 2: Separate each digit of your number", 13, 10, "$"
    var_HtoD_step3        DB "-> step 3: Each digit must be multiplied by 16 raised to its positional power", 13, 10, "$"
    var_HtoD_step4        DB "-> step 4: Convert letters to numbers", 13, 10, "$"
    var_HtoD_step5        DB "-> step 5: Your result is your number in decimal format!", 13, 10, "$"
    var_HtoD_arrow        DB "-> $"
    var_HtoD_space        DB " $"
    var_HtoD_final        DB "-> final number: $"
    var_HtoD_equals       DB "=$"
    var_HtoD_plus         DB "+$"
    var_HtoD_times        DB "*$"
    var_HtoD_power        DB "^$"
    var_HtoD_openParen    DB "($"
    var_HtoD_closeParen   DB ")$"
    var_HtoD_openSquare   DB "[$"
    var_HtoD_closeSquare  DB "]$"
    
    ; 32-bit number storage
    NUMBER_LOW            DW 0                                            ; Low 16 bits of number
    NUMBER_HIGH           DW 0                                            ; High 16 bits of number

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_HD PROC NEAR PUBLIC
                                  CALL ClearScreen
                                  CALL PrintNewLine
                                  CALL PrintNewLine
                       
    ; Step 1: Show the input hexadecimal number
                                  LEA  DX, var_HtoD_step1
                                  CALL PrintString
                                  LEA  DX, var_HtoD_arrow
                                  CALL PrintString
                                  CALL PrintInputNumber
                                  CALL PrintNewLine
                       
    ; Step 2: Separate each digit
                                  LEA  DX, var_HtoD_step2
                                  CALL PrintString
                                  LEA  DX, var_HtoD_arrow
                                  CALL PrintString
                                  CALL ShowSeparatedDigits
                                  CALL PrintNewLine
                       
    ; Step 3: Show each digit with power
                                  LEA  DX, var_HtoD_step3
                                  CALL PrintString
                                  CALL ShowDigitsWithPowers
                       
    ; Step 4: Convert letters to numbers and show formula
                                  LEA  DX, var_HtoD_step4
                                  CALL PrintString
                                  CALL ShowConversionFormula
                       
    ; Step 5: Show final message and result
                                  LEA  DX, var_HtoD_step5
                                  CALL PrintString
                                  LEA  DX, var_HtoD_final
                                  CALL PrintString
                                  CALL Print32BitNumber
                               
                                  CALL PrintNewLine
                                  CALL PrintString_wait
                                  RET
SUBMAIN_HD ENDP

    ; ======= EXPLANATION PROCEDURES =======
    
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

    ; Show separated digits (3 F 9 A format)
ShowSeparatedDigits PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  LEA  SI, BUFFER_IntputStr
                                  MOV  CL, [SI + 1]                     ; Get actual length
                                  MOV  CH, 0
                                  ADD  SI, 2                            ; Point to first digit
                       
    ; Print each digit separated by space
    _PrintSeparatedLoop:          
                                  CMP  CX, 0
                                  JE   _EndSeparated
                               
                                  MOV  DL, [SI]                         ; Get current digit
                                  MOV  AH, 02h
                                  INT  21h                              ; Print digit
                                  
                                  ; Add space if not last digit
                                  CMP  CX, 1
                                  JE   _NoSpace
                                  LEA  DX, var_HtoD_space
                                  CALL PrintString
                               
    _NoSpace:
                                  INC  SI
                                  DEC  CX
                                  JMP  _PrintSeparatedLoop
                       
    _EndSeparated:                
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ShowSeparatedDigits ENDP

    ; Show digits with their powers
ShowDigitsWithPowers PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
                                  LEA  SI, BUFFER_IntputStr
                                  MOV  CL, [SI + 1]                     ; Get actual length
                                  MOV  CH, 0
                                  ADD  SI, 2                            ; Point to first digit
                                  MOV  DI, CX                           ; Save length
                                  DEC  DI                               ; Position counter (0-based from right)
                       
    _PowerLoop:                   
                                  CMP  CX, 0
                                  JE   _EndPowerLoop
                               
                                  LEA  DX, var_HtoD_arrow
                                  CALL PrintString
                                  LEA  DX, var_HtoD_openParen
                                  CALL PrintString
                               
    ; Print the hex digit
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  LEA  DX, var_HtoD_times
                                  CALL PrintString
                               
    ; Print 16
                                  MOV  DL, '1'
                                  MOV  AH, 02h
                                  INT  21h
                                  MOV  DL, '6'
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  LEA  DX, var_HtoD_power
                                  CALL PrintString
                               
    ; Print position
                                  MOV  AX, DI
                                  CALL PrintSingleDigit
                               
                                  LEA  DX, var_HtoD_closeParen
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

    ; Show conversion formula with numbers
ShowConversionFormula PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
    ; Convert hex to decimal first (but silently, without printing steps)
                                  CALL ConvertHexStringTo32BitNumber
                       
                                  LEA  DX, var_HtoD_arrow
                                  CALL PrintString
                                  LEA  DX, var_HtoD_openSquare
                                  CALL PrintString
                       
    ; Show formula with decimal values
                                  LEA  SI, BUFFER_IntputStr
                                  MOV  CL, [SI + 1]                     ; Get actual length
                                  MOV  CH, 0
                                  ADD  SI, 2                            ; Point to first digit
                                  MOV  DI, CX                           ; Save length
                                  DEC  DI                               ; Position counter (0-based from right)
                       
    _FormulaLoop:                 
                                  CMP  CX, 0
                                  JE   _EndFormulaLoop
                               
                                  LEA  DX, var_HtoD_openParen
                                  CALL PrintString
                               
    ; Convert hex digit to decimal and print
                                  MOV  AL, [SI]
                                  CALL ConvertHexCharToDecimal
                                  MOV  AH, 0
                                  CALL PrintSingleDigit
                               
                                  LEA  DX, var_HtoD_times
                                  CALL PrintString
                               
    ; Print 16
                                  MOV  DL, '1'
                                  MOV  AH, 02h
                                  INT  21h
                                  MOV  DL, '6'
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  LEA  DX, var_HtoD_power
                                  CALL PrintString
                               
    ; Print position
                                  MOV  AX, DI
                                  CALL PrintSingleDigit
                               
                                  LEA  DX, var_HtoD_closeParen
                                  CALL PrintString
                               
                                  CMP  CX, 1
                                  JE   _NoPlus2
                                  LEA  DX, var_HtoD_plus
                                  CALL PrintString
                               
    _NoPlus2:                     
                                  INC  SI
                                  DEC  CX
                                  DEC  DI
                                  JMP  _FormulaLoop
                       
    _EndFormulaLoop:              
                                  LEA  DX, var_HtoD_closeSquare
                                  CALL PrintString
                                  LEA  DX, var_HtoD_equals
                                  CALL PrintString
                                  CALL Print32BitNumber
                                  CALL PrintNewLine
                       
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ShowConversionFormula ENDP

    ; Convert hexadecimal string to 32-bit number silently
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

    ; Print single digit (0-9) or multi-digit number
PrintSingleDigit PROC
                                  CMP  AX, 9
                                  JLE  _SingleDigitOnly
                           
    ; Multi-digit number, use Print16BitNumber
                                  CALL Print16BitNumber
                                  RET
                           
    _SingleDigitOnly:             
    ; Single digit (0-9)
                                  ADD  AL, '0'                          ; Convert to ASCII
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                                  RET
PrintSingleDigit ENDP

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

    ; Divide 32-bit number (NUMBER_HIGH:NUMBER_LOW) by 10
    ; Quotient stored back in NUMBER_HIGH:NUMBER_LOW, remainder in DL
Divide32BitBy10 PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                           
    ; Divide high word first
                                  MOV  AX, NUMBER_HIGH
                                  MOV  DX, 0                            ; Clear remainder
                                  MOV  BX, 10
                                  DIV  BX                               ; AX = quotient, DX = remainder
                                  MOV  NUMBER_HIGH, AX                  ; Store high quotient
                           
    ; Divide low word with remainder from high word
                                  MOV  AX, NUMBER_LOW                   ; DX already has remainder from high division
                                  DIV  BX                               ; AX = quotient, DX = remainder
                                  MOV  NUMBER_LOW, AX                   ; Store low quotient
                           
    ; DX contains the final remainder (0-9)
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
Divide32BitBy10 ENDP

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
                                  MOV  CX, 0                            ; Digit counter
                           
    _Convert32Loop:               
    ; Check if number is 0
                                  MOV  AX, NUMBER_HIGH
                                  OR   AX, NUMBER_LOW
                                  JZ   _Print32Digits
                           
    ; Divide by 10
                                  CALL Divide32BitBy10                  ; Quotient in NUMBER_HIGH:NUMBER_LOW, remainder in DL
                                  PUSH DX                               ; Store digit on stack
                                  INC  CX
                                  JMP  _Convert32Loop
                           
    _Print32Digits:               
    ; Print digits in reverse order from stack
    _Print32Loop:                 
                                  CMP  CX, 0
                                  JE   _Restore32Number
                           
                                  POP  DX                               ; Get digit from stack
                                  ADD  DL, '0'                          ; Convert to ASCII
                                  MOV  AH, 02h
                                  INT  21h
                           
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

END SUBMAIN_HD