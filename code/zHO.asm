.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; Hexadecimal to Octal explanation messages
    var_HtoO_step1        DB "-> step 1: Take your hexadecimal number", 13, 10, "$"
    var_HtoO_step2        DB "-> step 2: Convert the number in decimal format", 13, 10, "$"
    var_HtoO_why          DB "-> Why? Because doesn't exist a manual direct method", 13, 10, "$"
    var_HtoO_step3        DB "-> step 3: Group in groups of 3 digits", 13, 10, "$"
    var_HtoO_step4        DB "-> step 3: Multiply each number by 8^(0 : 4)", 13, 10, "$"
    var_HtoO_step5        DB "-> step 4: Just put together your numbers", 13, 10, "$"
    var_HtoO_step6        DB "-> step 5: Your result is your number in octal format!", 13, 10, "$"
    var_HtoO_arrow        DB "-> $"
    var_HtoO_space        DB " $"
    var_HtoO_final        DB "-> final number: $"
    var_HtoO_equals       DB " = $"
    var_HtoO_plus         DB "+$"
    var_HtoO_times        DB "*$"
    var_HtoO_power        DB "^$"
    var_HtoO_openParen    DB "($"
    var_HtoO_closeParen   DB ")$"
    var_HtoO_openSquare   DB "[$"
    var_HtoO_closeSquare  DB "]$"
    
    ; Storage for binary representation (up to 36 bits for 9 hex digits)
    BINARY_DIGITS         DB 36 DUP(0)                                  ; Binary representation
    BINARY_LENGTH         DB 0                                          ; Length of binary string
    OCTAL_RESULT          DB 12 DUP(0)                                  ; Octal result (up to 12 digits)
    OCTAL_LENGTH          DB 0                                          ; Length of octal result

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_HO PROC NEAR PUBLIC
                                  CALL ClearScreen
                                  CALL PrintNewLine
                                  CALL PrintNewLine
                       
    ; Step 1: Show the input hexadecimal number
                                  LEA  DX, var_HtoO_step1
                                  CALL PrintString
                                  LEA  DX, var_HtoO_arrow
                                  CALL PrintString
                                  CALL PrintInputNumber
                                  CALL PrintNewLine
                       
    ; Step 2: Convert to binary and show why
                                  LEA  DX, var_HtoO_step2
                                  CALL PrintString
                                  LEA  DX, var_HtoO_why
                                  CALL PrintString
                                  LEA  DX, var_HtoO_arrow
                                  CALL PrintString
                                  CALL ConvertHexToBinary
                                  CALL PrintBinaryWithSpaces
                                  CALL PrintNewLine
                       
    ; Step 3: Group in groups of 3 bits
                                  LEA  DX, var_HtoO_step3
                                  CALL PrintString
                                  LEA  DX, var_HtoO_arrow
                                  CALL PrintString
                                  CALL PrintBinaryGrouped
                                  CALL PrintNewLine
                       
    ; Step 4: Show conversion of each group
                                  LEA  DX, var_HtoO_step4
                                  CALL PrintString
                                  CALL ShowGroupConversions
                                  
    ; Reverse the octal result (since we processed right to left)
                                  CALL ReverseOctalResult
                       
    ; Step 5: Show final message
                                  LEA  DX, var_HtoO_step5
                                  CALL PrintString
                       
    ; Step 6: Show result
                                  LEA  DX, var_HtoO_step6
                                  CALL PrintString
                                  LEA  DX, var_HtoO_final
                                  CALL PrintString
                                  CALL PrintOctalResult
                               
                                  CALL PrintNewLine
                                  CALL PrintString_wait
                                  RET
SUBMAIN_HO ENDP

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
                       
    ; Print each digit of the input number with spaces
    _PrintInputLoop:              
                                  CMP  CX, 0
                                  JE   _EndPrintInput
                               
                                  MOV  DL, [SI]                         ; Get current digit
                                  MOV  AH, 02h
                                  INT  21h                              ; Print digit
                                  
                                  ; Add space if not last digit
                                  CMP  CX, 1
                                  JE   _NoSpaceInput
                                  LEA  DX, var_HtoO_space
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

    ; Convert hexadecimal to binary
ConvertHexToBinary PROC
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
                                  
                                  LEA  DI, BINARY_DIGITS                ; Point to binary storage
                                  MOV  BINARY_LENGTH, 0                 ; Initialize length
                       
    _ConvertToBinaryLoop:         
                                  CMP  CX, 0
                                  JE   _EndConvertToBinary
                               
    ; Get hex digit and convert to 4 binary digits
                                  MOV  AL, [SI]
                                  CALL ConvertHexCharToDecimal          ; AL = 0-15
                                  
    ; Convert decimal to 4 binary digits (MSB first)
                                  MOV  BL, AL                           ; Save original value
                                  
    ; Check bit 3 (MSB)
                                  TEST BL, 8                            ; Test bit 3
                                  JZ   _Bit3Zero
                                  MOV  BYTE PTR [DI], '1'
                                  JMP  _Bit3Done
    _Bit3Zero:
                                  MOV  BYTE PTR [DI], '0'
    _Bit3Done:
                                  INC  DI
                                  INC  BINARY_LENGTH
                                  
    ; Check bit 2
                                  TEST BL, 4                            ; Test bit 2
                                  JZ   _Bit2Zero
                                  MOV  BYTE PTR [DI], '1'
                                  JMP  _Bit2Done
    _Bit2Zero:
                                  MOV  BYTE PTR [DI], '0'
    _Bit2Done:
                                  INC  DI
                                  INC  BINARY_LENGTH
                                  
    ; Check bit 1
                                  TEST BL, 2                            ; Test bit 1
                                  JZ   _Bit1Zero
                                  MOV  BYTE PTR [DI], '1'
                                  JMP  _Bit1Done
    _Bit1Zero:
                                  MOV  BYTE PTR [DI], '0'
    _Bit1Done:
                                  INC  DI
                                  INC  BINARY_LENGTH
                                  
    ; Check bit 0 (LSB)
                                  TEST BL, 1                            ; Test bit 0
                                  JZ   _Bit0Zero
                                  MOV  BYTE PTR [DI], '1'
                                  JMP  _Bit0Done
    _Bit0Zero:
                                  MOV  BYTE PTR [DI], '0'
    _Bit0Done:
                                  INC  DI
                                  INC  BINARY_LENGTH
                               
                                  INC  SI
                                  DEC  CX
                                  JMP  _ConvertToBinaryLoop
                       
    _EndConvertToBinary:          
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ConvertHexToBinary ENDP

    ; Print binary with spaces between each digit
PrintBinaryWithSpaces PROC
                                  PUSH AX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  LEA  SI, BINARY_DIGITS
                                  MOV  CL, BINARY_LENGTH
                                  MOV  CH, 0
                       
    _PrintBinaryLoop:             
                                  CMP  CX, 0
                                  JE   _EndPrintBinary
                               
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                                  
                                  ; Add space if not last digit
                                  CMP  CX, 1
                                  JE   _NoSpaceBinary
                                  LEA  DX, var_HtoO_space
                                  CALL PrintString
                               
    _NoSpaceBinary:
                                  INC  SI
                                  DEC  CX
                                  JMP  _PrintBinaryLoop
                       
    _EndPrintBinary:              
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  AX
                                  RET
PrintBinaryWithSpaces ENDP

    ; Print binary grouped in sets of 3
PrintBinaryGrouped PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  LEA  SI, BINARY_DIGITS
                                  MOV  CL, BINARY_LENGTH
                                  MOV  CH, 0
                                  MOV  BL, 0                            ; Group counter
                       
    _PrintGroupedLoop:            
                                  CMP  CX, 0
                                  JE   _EndPrintGrouped
                               
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  INC  BL
                                  CMP  BL, 3                            ; Every 3 digits
                                  JNE  _NoGroupSpace
                                  
                                  ; Add space after group if not last
                                  CMP  CX, 1
                                  JE   _NoGroupSpace
                                  LEA  DX, var_HtoO_space
                                  CALL PrintString
                                  MOV  BL, 0                            ; Reset counter
                               
    _NoGroupSpace:
                                  INC  SI
                                  DEC  CX
                                  JMP  _PrintGroupedLoop
                       
    _EndPrintGrouped:             
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
PrintBinaryGrouped ENDP

    ; Show conversion of each 3-bit group to octal
ShowGroupConversions PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
                                  LEA  SI, BINARY_DIGITS
                                  MOV  CL, BINARY_LENGTH
                                  MOV  CH, 0
                                  LEA  DI, OCTAL_RESULT
                                  MOV  OCTAL_LENGTH, 0
                       
    ; Start from the right (end) of binary string
                                  MOV  AL, CL                           ; Get binary length
                                  DEC  AL                               ; Convert to 0-based index
                                  MOV  AH, 0
                                  ADD  SI, AX                           ; Point to last bit
                       
    _GroupLoop:                   
                                  CMP  CL, 0
                                  JE   _EndGroupLoop
                               
    ; Process group of up to 3 bits (from right to left)
                                  LEA  DX, var_HtoO_arrow
                                  CALL PrintString
                                  LEA  DX, var_HtoO_openSquare
                                  CALL PrintString
                               
    ; Determine how many bits in this group
                                  MOV  BH, 3                            ; Max bits per group
                                  CMP  CL, 3
                                  JGE  _FullGroup
                                  MOV  BH, CL                           ; Use remaining bits
                                  
    _FullGroup:
                                  PUSH CX                               ; Save remaining bit count
                                  PUSH SI                               ; Save current position
                                  
    ; Calculate starting position for this group
                                  MOV  AL, BH
                                  DEC  AL
                                  MOV  AH, 0
                                  SUB  SI, AX                           ; Point to first bit of group
                                  
    ; Print the binary calculation for this group
                                  MOV  CH, BH                           ; Bits in current group
                                  MOV  BL, CH                           ; Power counter (starts from group size - 1)
                                  DEC  BL
                                  
    _BitLoop:                     
                                  CMP  CH, 0
                                  JE   _EndBitLoop
                                  
                                  LEA  DX, var_HtoO_openParen
                                  CALL PrintString
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                                  LEA  DX, var_HtoO_times
                                  CALL PrintString
                                  MOV  DL, '2'
                                  MOV  AH, 02h
                                  INT  21h
                                  LEA  DX, var_HtoO_power
                                  CALL PrintString
                                  MOV  AL, BL
                                  MOV  AH, 0
                                  CALL PrintSingleDigit
                                  LEA  DX, var_HtoO_closeParen
                                  CALL PrintString
                                  
                                  CMP  CH, 1
                                  JE   _NoPlus
                                  LEA  DX, var_HtoO_plus
                                  CALL PrintString
                                  
    _NoPlus:
                                  INC  SI
                                  DEC  BL
                                  DEC  CH
                                  JMP  _BitLoop
                                  
    _EndBitLoop:
                                  LEA  DX, var_HtoO_closeSquare
                                  CALL PrintString
                                  LEA  DX, var_HtoO_equals
                                  CALL PrintString
                                  
    ; Calculate and print octal digit for this group
                                  POP  SI                               ; Restore position
                                  PUSH SI
                                  MOV  AL, BH
                                  DEC  AL
                                  MOV  AH, 0
                                  SUB  SI, AX                           ; Point to first bit of group
                                  MOV  CH, BH                           ; Bits in group
                                  CALL CalculateOctalDigitFromGroup
                                  CALL PrintNewLine
                                  
                                  POP  SI                               ; Restore position
                                  POP  CX                               ; Restore bit count
                                  MOV  AX, 0
                                  MOV  AL, BH
                                  SUB  SI, AX                           ; Move to next group
                                  SUB  CL, BH                           ; Decrease remaining bits
                                  JMP  _GroupLoop
                                  
    _EndGroupLoop:                
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ShowGroupConversions ENDP

    ; Calculate octal digit from current 3-bit group
CalculateOctalDigitFromGroup PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                                  
                                  MOV  AL, 0                            ; Accumulator
                                  MOV  BL, 1                            ; Power of 2 (starts with 2^0)
                                  
    ; Calculate power base for this group
                                  MOV  DH, CH                           ; Save bit count
                                  DEC  DH                               ; Convert to max power
                                  
    _PowerCalc:
                                  CMP  DH, 0
                                  JE   _StartCalc
                                  SHL  BL, 1                            ; Multiply by 2
                                  DEC  DH
                                  JMP  _PowerCalc
                                  
    _StartCalc:
    ; Process bits from left to right
                                  
    _CalcLoop:
                                  CMP  CH, 0
                                  JE   _EndCalc
                                  
                                  CMP  BYTE PTR [SI], '1'
                                  JNE  _SkipAdd
                                  ADD  AL, BL
                                  
    _SkipAdd:
                                  SHR  BL, 1                            ; Divide by 2 (next power)
                                  INC  SI
                                  DEC  CH
                                  JMP  _CalcLoop
                                  
    _EndCalc:
    ; Print the octal digit
                                  ADD  AL, '0'
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                                  
    ; Store in octal result (append to end since we process right to left)
                                  LEA  DI, OCTAL_RESULT
                                  MOV  BL, OCTAL_LENGTH
                                  MOV  BH, 0
                                  ADD  DI, BX                           ; Point to end of current result
                                  MOV  [DI], AL                         ; Store at end
                                  INC  OCTAL_LENGTH
                                  
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
CalculateOctalDigitFromGroup ENDP

    ; Print the final octal result
PrintOctalResult PROC
                                  PUSH AX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                       
                                  LEA  SI, OCTAL_RESULT
                                  MOV  CL, OCTAL_LENGTH
                                  MOV  CH, 0
                       
    _PrintOctalLoop:              
                                  CMP  CX, 0
                                  JE   _EndPrintOctal
                               
                                  MOV  DL, [SI]
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  INC  SI
                                  DEC  CX
                                  JMP  _PrintOctalLoop
                       
    _EndPrintOctal:               
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  AX
                                  RET
PrintOctalResult ENDP

    ; Reverse the octal result array
ReverseOctalResult PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                                  PUSH SI
                                  PUSH DI
                       
                                  LEA  SI, OCTAL_RESULT                 ; Point to start
                                  LEA  DI, OCTAL_RESULT                 ; Point to start
                                  MOV  CL, OCTAL_LENGTH
                                  MOV  CH, 0
                                  DEC  CX                               ; Convert to 0-based index
                                  ADD  DI, CX                           ; Point to end
                       
    _ReverseLoop:                 
                                  CMP  SI, DI                           ; Check if pointers meet
                                  JGE  _EndReverse
                               
    ; Swap bytes
                                  MOV  AL, [SI]
                                  MOV  BL, [DI]
                                  MOV  [SI], BL
                                  MOV  [DI], AL
                               
                                  INC  SI
                                  DEC  DI
                                  JMP  _ReverseLoop
                       
    _EndReverse:                  
                                  POP  DI
                                  POP  SI
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ReverseOctalResult ENDP

    ; ======= UTILITY PROCEDURES =======
    
    ; Convert hexadecimal character to decimal value
ConvertHexCharToDecimal PROC
                                  CMP  AL, '9'
                                  JLE  _IsDigit
                                  CMP  AL, 'F'
                                  JLE  _IsUpperHex
                                  CMP  AL, 'f'
                                  JLE  _IsLowerHex
                                  RET
                               
    _IsDigit:                     
                                  SUB  AL, '0'
                                  RET
                               
    _IsUpperHex:                  
                                  SUB  AL, 'A'
                                  ADD  AL, 10
                                  RET
                               
    _IsLowerHex:                  
                                  SUB  AL, 'a'
                                  ADD  AL, 10
                                  RET
ConvertHexCharToDecimal ENDP

    ; Print a single digit number (0-9)
PrintSingleDigit PROC
                                  PUSH AX
                                  PUSH DX
                               
                                  CMP  AX, 9
                                  JLE  _SingleDigit
                               
    ; Handle multi-digit numbers
                                  PUSH AX
                                  MOV  DX, 0
                                  MOV  BX, 10
                                  DIV  BX                               ; AX = quotient, DX = remainder
                                  CMP  AX, 0
                                  JE   _PrintRemainder
                                  CALL PrintSingleDigit                ; Recursive call for quotient
    _PrintRemainder:              
                                  POP  AX
                                  MOV  AX, DX                           ; Get remainder
                               
    _SingleDigit:                 
                                  ADD  AL, '0'                          ; Convert to ASCII
                                  MOV  DL, AL
                                  MOV  AH, 02h
                                  INT  21h
                               
                                  POP  DX
                                  POP  AX
                                  RET
PrintSingleDigit ENDP

    ; Print string pointed by DX
PrintString PROC
                                  PUSH AX
                                  MOV  AH, 09h
                                  INT  21h
                                  POP  AX
                                  RET
PrintString ENDP

    ; Print string and wait for key
PrintString_wait PROC
                                  PUSH AX
                                  MOV  AH, 09h
                                  INT  21h
                                  MOV  AH, 08h                          ; Wait for key press
                                  INT  21h
                                  POP  AX
                                  RET
PrintString_wait ENDP

    ; Print new line
PrintNewLine PROC
                                  PUSH DX
                                  LEA  DX, var_newLine
                                  CALL PrintString
                                  POP  DX
                                  RET
PrintNewLine ENDP

    ; Clear screen
ClearScreen PROC
                                  PUSH AX
                                  PUSH BX
                                  PUSH CX
                                  PUSH DX
                               
                                  MOV  AH, 06h                          ; Scroll up function
                                  MOV  AL, 0                            ; Clear entire screen
                                  MOV  BH, 07h                          ; Normal attribute
                                  MOV  CX, 0                            ; Upper left corner (0,0)
                                  MOV  DX, 184Fh                        ; Lower right corner (24,79)
                                  INT  10h
                               
                                  MOV  AH, 02h                          ; Set cursor position
                                  MOV  BH, 0                            ; Page number
                                  MOV  DX, 0                            ; Row 0, Column 0
                                  INT  10h
                               
                                  POP  DX
                                  POP  CX
                                  POP  BX
                                  POP  AX
                                  RET
ClearScreen ENDP

END SUBMAIN_HO