.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA
    ; Util printing
    var_newLine          DB 13, 10, "$"
    ; Octal to Hexadecimal explanation messages
    var_OtoH_step1       DB "-> step 1: Take your octal number", 13, 10, "$"
    var_OtoH_step2       DB "-> step 2: Convert your number to binary first", 13, 10, "$"
    var_OtoH_careful1    DB "-> BE CAREFUL: Octal uses 3-bit groups, hexadecimal uses 4-bit groups", 13, 10, "$"
    var_OtoH_why         DB "-> Why? Because doesn't exist a manual direct method", 13, 10, "$"
    var_OtoH_step3       DB "-> step 3: Group the binary digits into sets of 4, starting from the right", 13, 10, "$"
    var_OtoH_careful2    DB "-> BE CAREFUL: If leftmost group has fewer than 4 digits, keep apart", 13, 10, "$"
    var_OtoH_step4       DB "-> step 4: Multiply each group by 2^(position)", 13, 10, "$"
    var_OtoH_step5       DB "-> step 5: Put together your hexadecimal digits", 13, 10, "$"
    var_OtoH_arrow       DB "-> $"
    var_OtoH_example     DB "-> Example: $"
    var_OtoH_space       DB " $"
    var_OtoH_final       DB "-> Final hexadecimal number: $"
    var_OtoH_binary      DB "-> Binary equivalent: $"
    var_OtoH_equals      DB " = $"
    var_OtoH_plus        DB " + $"
    var_OtoH_times       DB "*$"
    var_OtoH_power       DB "^$"
    var_OtoH_openParen   DB "($"
    var_OtoH_closeParen  DB ")$"
    var_OtoH_openSquare  DB "[$"
    var_OtoH_closeSquare DB "]$"
    var_OtoH_rarrow      DB " -> $"
    
    ; Storage for binary representation (up to 27 bits for 9 octal digits)
    BINARY_DIGITS        DB 27 DUP(0)                                                                                    ; Binary representation
    BINARY_LENGTH        DB 0                                                                                            ; Length of binary string
    HEX_RESULT           DB 10 DUP(0)                                                                                    ; Hex result (up to 9 digits + null)
    HEX_LENGTH           DB 0                                                                                            ; Length of hex result

.CODE

    ; ======= MAIN PROCEDURE =======
SUBMAIN_OH PROC NEAR PUBLIC
                                CALL ClearScreen
                                CALL PrintNewLine
                                CALL PrintNewLine
                       
    ; Step 1: Show the input octal number
                                LEA  DX, var_OtoH_step1
                                CALL PrintString
                                LEA  DX, var_OtoH_example
                                CALL PrintString
                                CALL PrintInputNumber
                                CALL PrintNewLine
                       
    ; Step 2: Convert to binary with explanation
                                LEA  DX, var_OtoH_step2
                                CALL PrintString
                                LEA  DX, var_OtoH_careful1
                                CALL PrintString
                                LEA  DX, var_OtoH_why
                                CALL PrintString
                                CALL ShowOctalToBinaryConversion
                                LEA  DX, var_OtoH_binary
                                CALL PrintString
                                CALL PrintBinaryResult
                                CALL PrintNewLine
                       
    ; Step 3: Group binary into 4-bit groups
                                LEA  DX, var_OtoH_step3
                                CALL PrintString
                                LEA  DX, var_OtoH_careful2
                                CALL PrintString
                                LEA  DX, var_OtoH_arrow
                                CALL PrintString
                                CALL PrintBinaryGrouped
                                CALL PrintNewLine
                       
    ; Step 4: Convert each group to hex
                                LEA  DX, var_OtoH_step4
                                CALL PrintString
                                CALL ShowGroupConversions
                       
    ; Step 5: Show final result
                                LEA  DX, var_OtoH_step5
                                CALL PrintString
                                LEA  DX, var_OtoH_final
                                CALL PrintString
                                CALL PrintHexResult
                               
                                CALL PrintNewLine
                                CALL PrintString_wait
                                RET
SUBMAIN_OH ENDP

    ; ======= EXPLANATION PROCEDURES =======
    
    ; Print the input octal number separated by spaces
PrintInputNumber PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                       
                                LEA  SI, BUFFER_IntputStr
                                MOV  CL, [SI + 1]                   ; Get actual length
                                MOV  CH, 0
                                ADD  SI, 2                          ; Point to first digit
                       
    ; Print each digit of the input number with spaces
    _PrintInputLoop:            
                                CMP  CX, 0
                                JE   _EndPrintInput
                               
                                MOV  DL, [SI]                       ; Get current digit
                                MOV  AH, 02h
                                INT  21h                            ; Print digit
                                  
    ; Add space if not last digit
                                CMP  CX, 1
                                JE   _NoSpaceInput
                                LEA  DX, var_OtoH_space
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

    ; Show octal to binary conversion step by step
ShowOctalToBinaryConversion PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                                PUSH DI
                       
                                LEA  SI, BUFFER_IntputStr
                                MOV  CL, [SI + 1]                   ; Get actual length
                                MOV  CH, 0
                                ADD  SI, 2                          ; Point to first digit
                                  
                                LEA  DI, BINARY_DIGITS              ; Point to binary storage
                                MOV  BINARY_LENGTH, 0               ; Initialize length
                       
    _ConvertToBinaryLoop:       
                                CMP  CX, 0
                                JE   _EndConvertToBinary
                               
    ; Show conversion: digit -> 3-bit binary
                                LEA  DX, var_OtoH_arrow
                                CALL PrintString
                                MOV  DL, [SI]                       ; Print octal digit
                                MOV  AH, 02h
                                INT  21h
                                LEA  DX, var_OtoH_rarrow
                                CALL PrintString
                               
    ; Convert octal digit to 3 binary digits
                                MOV  AL, [SI]
                                SUB  AL, '0'                        ; Convert to numeric value (0-7)
                                  
    ; Convert to 3 binary digits (MSB first)
                                MOV  BL, AL                         ; Save original value
                                  
    ; Check bit 2 (MSB)
                                TEST BL, 4                          ; Test bit 2
                                JZ   _Bit2Zero
                                MOV  BYTE PTR [DI], '1'
                                MOV  DL, '1'
                                JMP  _Bit2Done
    _Bit2Zero:                  
                                MOV  BYTE PTR [DI], '0'
                                MOV  DL, '0'
    _Bit2Done:                  
                                MOV  AH, 02h
                                INT  21h                            ; Print bit
                                INC  DI
                                INC  BINARY_LENGTH
                                  
    ; Check bit 1
                                TEST BL, 2                          ; Test bit 1
                                JZ   _Bit1Zero
                                MOV  BYTE PTR [DI], '1'
                                MOV  DL, '1'
                                JMP  _Bit1Done
    _Bit1Zero:                  
                                MOV  BYTE PTR [DI], '0'
                                MOV  DL, '0'
    _Bit1Done:                  
                                MOV  AH, 02h
                                INT  21h                            ; Print bit
                                INC  DI
                                INC  BINARY_LENGTH
                                  
    ; Check bit 0 (LSB)
                                TEST BL, 1                          ; Test bit 0
                                JZ   _Bit0Zero
                                MOV  BYTE PTR [DI], '1'
                                MOV  DL, '1'
                                JMP  _Bit0Done
    _Bit0Zero:                  
                                MOV  BYTE PTR [DI], '0'
                                MOV  DL, '0'
    _Bit0Done:                  
                                MOV  AH, 02h
                                INT  21h                            ; Print bit
                                INC  DI
                                INC  BINARY_LENGTH
                                CALL PrintNewLine
                               
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
ShowOctalToBinaryConversion ENDP

    ; Print the complete binary result
PrintBinaryResult PROC
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
                               
                                INC  SI
                                DEC  CX
                                JMP  _PrintBinaryLoop
                       
    _EndPrintBinary:            
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  AX
                                RET
PrintBinaryResult ENDP

    ; Print binary grouped in sets of 4 from right
PrintBinaryGrouped PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                       
                                LEA  SI, BINARY_DIGITS
                                MOV  CL, BINARY_LENGTH
                                MOV  CH, 0
                       
    ; Calculate how many bits in the leftmost group
                                MOV  AL, CL
                                MOV  BL, 4
                                MOV  AH, 0
                                DIV  BL                             ; AL = full groups, AH = remainder
                                  
                                CMP  AH, 0                          ; Check if there's a partial group
                                JE   _NoPartialGroup
                                  
    ; Print partial group first
                                MOV  BL, AH                         ; Bits in partial group
                                MOV  BH, 0
                                  
    _PrintPartialLoop:          
                                CMP  BL, 0
                                JE   _PartialDone
                                  
                                MOV  DL, [SI]
                                MOV  AH, 02h
                                INT  21h
                                  
                                INC  SI
                                DEC  BL
                                DEC  CL
                                JMP  _PrintPartialLoop
                                  
    _PartialDone:               
                                CMP  CL, 0
                                JE   _EndGrouped
                                LEA  DX, var_OtoH_space
                                CALL PrintString
                                  
    _NoPartialGroup:            
    ; Print remaining full groups of 4
                                MOV  BL, 0                          ; Group counter
                                  
    _PrintGroupedLoop:          
                                CMP  CX, 0
                                JE   _EndGrouped
                               
                                MOV  DL, [SI]
                                MOV  AH, 02h
                                INT  21h
                               
                                INC  BL
                                INC  SI
                                DEC  CX
                                  
                                CMP  BL, 4                          ; Every 4 digits
                                JNE  _NoGroupSpace
                                  
    ; Add space after group if not last
                                CMP  CX, 0
                                JE   _NoGroupSpace
                                LEA  DX, var_OtoH_space
                                CALL PrintString
                                MOV  BL, 0                          ; Reset counter
                               
    _NoGroupSpace:              
                                JMP  _PrintGroupedLoop
                       
    _EndGrouped:                
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  BX
                                POP  AX
                                RET
PrintBinaryGrouped ENDP

    ; Show conversion of each 4-bit group to hexadecimal
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
                                MOV  HEX_LENGTH, 0                  ; Reset hex length
                       
                                ; Calculate if there's a partial group at the start
                                MOV  AL, CL
                                MOV  BL, 4
                                MOV  AH, 0
                                DIV  BL                             ; AL = full groups, AH = remainder
                                
                                ; Store full groups count and remainder
                                MOV  DH, AL                         ; Store full groups count
                                MOV  DL, AH                         ; Store remainder (partial group size)
                                
                                ; Process partial group first if it exists
                                CMP  DL, 0
                                JE   _NoPartialGroupConv
                                
                                LEA  DX, var_OtoH_arrow
                                CALL PrintString
                                LEA  DX, var_OtoH_openSquare
                                CALL PrintString
                                
                                MOV  BH, DL                         ; Partial group size
                                CALL ProcessBinaryGroupDisplay
                                
                                LEA  DX, var_OtoH_closeSquare
                                CALL PrintString
                                LEA  DX, var_OtoH_equals
                                CALL PrintString
                                
                                MOV  BH, DL                         ; Group size for calculation
                                CALL CalculateAndStoreHexDigit
                                CALL PrintNewLine
                                
                                ; Move SI past the partial group
                                MOV  AL, DL                         ; Get partial group size
                                MOV  AH, 0
                                ADD  SI, AX
                                SUB  CL, AL                         ; Reduce remaining bits
                                DEC  DH                             ; One less full group to process
                                
    _NoPartialGroupConv:            
                                ; Process remaining full groups of 4 bits each
                                MOV  AL, DH                         ; Get full groups count
                                MOV  AH, 0
                                
    _GroupLoop:                 
                                CMP  AX, 0                          ; Check if more groups to process
                                JE   _EndGroupLoop
                                CMP  CL, 4                          ; Make sure we have at least 4 bits
                                JL   _EndGroupLoop
                                
                                LEA  DX, var_OtoH_arrow
                                CALL PrintString
                                LEA  DX, var_OtoH_openSquare
                                CALL PrintString
                                
                                MOV  BH, 4                          ; Full group size
                                CALL ProcessBinaryGroupDisplay
                                
                                LEA  DX, var_OtoH_closeSquare
                                CALL PrintString
                                LEA  DX, var_OtoH_equals
                                CALL PrintString
                                
                                MOV  BH, 4                          ; Group size for calculation
                                CALL CalculateAndStoreHexDigit
                                CALL PrintNewLine
                                
                                ADD  SI, 4                          ; Move to next group
                                SUB  CL, 4                          ; Reduce remaining bits
                                DEC  AX                             ; One less group to process
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

    ; Process a binary group for formula display
ProcessBinaryGroup PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI                             ; Save SI
                                  
                                MOV  BL, BH                         ; Number of bits
                                DEC  BL                             ; Start from highest power
                                  
    _ProcessLoop:               
                                CMP  BH, 0
                                JE   _EndProcess
                                  
                                LEA  DX, var_OtoH_openParen
                                CALL PrintString
                                  
                                MOV  DL, [SI]                       ; Print bit
                                MOV  AH, 02h
                                INT  21h
                                  
                                LEA  DX, var_OtoH_times
                                CALL PrintString
                                  
                                MOV  DL, '2'                        ; Print 2
                                MOV  AH, 02h
                                INT  21h
                                  
                                LEA  DX, var_OtoH_power
                                CALL PrintString
                                  
                                MOV  AL, BL                         ; Print power
                                MOV  AH, 0
                                CALL PrintSingleDigit
                                  
                                LEA  DX, var_OtoH_closeParen
                                CALL PrintString
                                  
                                CMP  BH, 1
                                JE   _NoPlus
                                LEA  DX, var_OtoH_plus
                                CALL PrintString
                                  
    _NoPlus:                    
                                INC  SI
                                DEC  BH
                                DEC  BL
                                JMP  _ProcessLoop
                                  
    _EndProcess:                
                                POP  SI                             ; Restore SI
                                POP  DX
                                POP  CX
                                POP  BX
                                POP  AX
                                RET
ProcessBinaryGroup ENDP

    ; Calculate hex digit from current group
CalculateHexFromGroup PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                                  
    ; SI already points to the start of the current group
                                MOV  AL, 0                          ; Accumulator
                                MOV  BL, 1                          ; Power of 2
                                MOV  CH, BH                         ; Save group size
                                  
    ; Calculate power base for this group
                                MOV  DH, CH                         ; Save bit count
                                DEC  DH                             ; Convert to max power
                                  
    _PowerCalc:                 
                                CMP  DH, 0
                                JE   _StartCalc
                                SHL  BL, 1                          ; Multiply by 2
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
                                SHR  BL, 1                          ; Divide by 2 (next power)
                                INC  SI
                                DEC  CH
                                JMP  _CalcLoop
                                  
    _EndCalc:                   
    ; Print the hex digit
                                CMP  AL, 9
                                JLE  _IsDigit
                                ADD  AL, 'A' - 10                   ; Convert to A-F
                                JMP  _PrintHex
    _IsDigit:                   
                                ADD  AL, '0'                        ; Convert to 0-9
    _PrintHex:                  
                                MOV  DL, AL
                                MOV  AH, 02h
                                INT  21h
                                  
    ; Store in hex result
                                PUSH SI                             ; Save current SI
                                LEA  SI, HEX_RESULT
                                MOV  BL, HEX_LENGTH
                                MOV  BH, 0
                                ADD  SI, BX
                                MOV  [SI], AL
                                INC  HEX_LENGTH
                                POP  SI                             ; Restore SI
                                  
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  BX
                                POP  AX
                                RET
CalculateHexFromGroup ENDP

    ; Print the final hex result
PrintHexResult PROC
                                PUSH AX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                       
                                LEA  SI, HEX_RESULT
                                MOV  CL, HEX_LENGTH
                                MOV  CH, 0
                       
    _PrintHexLoop:              
                                CMP  CX, 0
                                JE   _EndPrintHex
                               
                                MOV  DL, [SI]
                                MOV  AH, 02h
                                INT  21h
                               
                                INC  SI
                                DEC  CX
                                JMP  _PrintHexLoop
                       
    _EndPrintHex:               
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  AX
                                RET
PrintHexResult ENDP

    ; Display a binary group for formula display
ProcessBinaryGroupDisplay PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                                
                                MOV  CL, BH                         ; Number of bits to display
                                MOV  CH, 0
                                
    _DisplayLoop:               
                                CMP  CX, 0
                                JE   _EndDisplay
                                
                                MOV  DL, [SI]
                                MOV  AH, 02h
                                INT  21h
                                
                                INC  SI
                                DEC  CX
                                JMP  _DisplayLoop
                                
    _EndDisplay:                
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  BX
                                POP  AX
                                RET
ProcessBinaryGroupDisplay ENDP

    ; Calculate and store hex digit from binary group
CalculateAndStoreHexDigit PROC
                                PUSH AX
                                PUSH BX
                                PUSH CX
                                PUSH DX
                                PUSH SI
                                PUSH DI
                                
                                MOV  AL, 0                          ; Accumulator
                                MOV  BL, 1                          ; Power of 2
                                MOV  CL, BH                         ; Group size
                                MOV  CH, 0
                                
                                ; Calculate starting power
                                MOV  DH, BH                         ; Save group size
                                DEC  DH                             ; Convert to max power
                                
    _PowerLoopStore:            
                                CMP  DH, 0
                                JE   _StartCalcStore
                                SHL  BL, 1                          ; Multiply by 2
                                DEC  DH
                                JMP  _PowerLoopStore
                                
    _StartCalcStore:            
                                ; Process bits from left to right
    _CalcLoopStore:             
                                CMP  CX, 0
                                JE   _EndCalcStore
                                
                                CMP  BYTE PTR [SI], '1'
                                JNE  _SkipAddStore
                                ADD  AL, BL
                                
    _SkipAddStore:              
                                SHR  BL, 1                          ; Divide by 2 (next power)
                                INC  SI
                                DEC  CX
                                JMP  _CalcLoopStore
                                
    _EndCalcStore:              
                                ; Convert to hex character
                                CMP  AL, 9
                                JLE  _IsDigitStore
                                ADD  AL, 'A' - 10                   ; Convert to A-F
                                JMP  _PrintHexStore
    _IsDigitStore:              
                                ADD  AL, '0'                        ; Convert to 0-9
    _PrintHexStore:             
                                MOV  DL, AL
                                MOV  AH, 02h
                                INT  21h
                                
                                ; Store in hex result
                                PUSH SI                             ; Save current SI
                                LEA  DI, HEX_RESULT
                                MOV  BL, HEX_LENGTH
                                MOV  BH, 0
                                ADD  DI, BX
                                MOV  [DI], AL
                                INC  HEX_LENGTH
                                POP  SI                             ; Restore SI
                                
                                POP  DI
                                POP  SI
                                POP  DX
                                POP  CX
                                POP  BX
                                POP  AX
                                RET
CalculateAndStoreHexDigit ENDP

    ; ======= UTILITY PROCEDURES =======
    
    ; Print a single digit number (0-15)
PrintSingleDigit PROC
                                PUSH AX
                                PUSH BX
                                PUSH DX
                                  
                                CMP  AX, 9
                                JLE  _SingleDigitOnly
                                  
    ; Handle numbers 10-15 (print as two digits)
                                MOV  DX, 0
                                MOV  BX, 10
                                DIV  BX                             ; AX = quotient, DX = remainder
                                  
                                ADD  AL, '0'
                                PUSH DX                             ; Save remainder
                                MOV  DL, AL
                                MOV  AH, 02h
                                INT  21h                            ; Print tens digit
                                  
                                POP  DX                             ; Restore remainder
                                ADD  DL, '0'
                                MOV  AH, 02h
                                INT  21h                            ; Print units digit
                                JMP  _EndSingleDigit
                                  
    _SingleDigitOnly:           
                                ADD  AL, '0'
                                MOV  DL, AL
                                MOV  AH, 02h
                                INT  21h
                                  
    _EndSingleDigit:            
                                POP  DX
                                POP  BX
                                POP  AX
                                RET
PrintSingleDigit ENDP

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

END SUBMAIN_OH