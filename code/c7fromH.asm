.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA

    ; Util printing
    var_newLine        DB 13, 10, "$"
    ; Messages
    var_HmessageInit   DB "Initialized conversion: HEXADECIMAL", 13, 10, "$"
    var_HmessageSeeNum DB "In Binary your number is: ", "$"
    var_HmessageSeeDec DB "In decimal your number is: ", "$"
    var_HmessageSeeOct DB "In Octal your number is: ", "$"
    var_HmessageSeeHex DB "In Hexadecimal your number is: ", "$"
    var_HmessageFint   DB "Finalized conversion", 13, 10, "$"
    ; Buffers
    BUFFER_HIntputNum  DD 11 DUP(0)
    ; Debugging vars
    var_TestH1         DB "HHH Break point 1 HHHH", 13, 10, "$"
    var_TestH2         DB "HHH Break point 2 HHHH", 13, 10, "$"
    var_TestH3         DB "HHH Break point 3 HHHH", 13, 10, "$"
    var_TestH4         DB "HHH Break point 4 HHHH", 13, 10, "$"
    var_TestH5         DB "HHH Break point 5 HHHH", 13, 10, "$"
.CODE

MAIN_FROMH PROC NEAR PUBLIC
                          CALL InitializeConvertionH
                          RET
MAIN_FROMH ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionH PROC
                          CALL InputToNumH

                          LEA  DX, var_HmessageInit
                          CALL PrintString               ; Print initialization message

                          CALL HPrintNumBinary
                          CALL HPrintNumDecimal
                          CALL HPrintNumOctal
                          CALL HPrintNumHex
                            
                          CALL PrintNewLine
                          CALL PrintNewLine
                          LEA  DX, var_HmessageFint
                          CALL PrintString_wait
                          RET
InitializeConvertionH ENDP

    ; Convert the ASCII string to a number from hexadecimal format
InputToNumH PROC

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Inicializar
                          XOR  AX, AX                    ; AX = 0 → acumulador parcial
                          LEA  SI, BUFFER_IntputStr
                          MOV  CL, [SI + 1]              ; CL = número de caracteres introducidos
                          ADD  SI, 2                     ; SI apunta al primer carácter

    _ConvertLoop:         
                          CMP  CL, 0
                          JE   _StoreResult              ; Si ya no quedan caracteres, terminar

                          MOV  BL, [SI]                  ; BL = siguiente carácter
                          
    ; Multiplicar resultado actual por 16 (base hexadecimal)
                          MOV  DX, 16
                          MUL  DX                        ; AX = AX * 16
                          
    ; Convertir carácter ASCII a valor numérico
    ; Primero verificar si es dígito (0-9) o letra (A-F)
                          CMP  BL, '9'
                          JLE  _IsDigit                  ; Si <= '9', es dígito
                          
    ; Es letra, convertir A-F a 10-15
                          CMP  BL, 'F'
                          JLE  _IsUpperCase              ; Si <= 'F', es A-F
                          
    ; Verificar si es minúscula a-f
                          CMP  BL, 'f'
                          JLE  _IsLowerCase              ; Si <= 'f', podría ser a-f
                          JMP  _SkipAdd                  ; Si no, saltar
                          
    _IsLowerCase:         
                          CMP  BL, 'a'
                          JL   _SkipAdd                  ; Si < 'a', no es válido
                          SUB  BL, 'a' - 10              ; Convertir a-f a 10-15
                          JMP  _AddDigit
                          
    _IsUpperCase:         
                          CMP  BL, 'A'
                          JL   _SkipAdd                  ; Si < 'A', no es válido
                          SUB  BL, 'A' - 10              ; Convertir A-F a 10-15
                          JMP  _AddDigit
                          
    _IsDigit:             
                          CMP  BL, '0'
                          JL   _SkipAdd                  ; Si < '0', no es válido
                          SUB  BL, '0'                   ; Convertir 0-9 a 0-9
                          
    _AddDigit:            
    ; Validar que el valor esté en rango hexadecimal (0-15)
                          CMP  BL, 15
                          JA   _SkipAdd                  ; Si > 15, saltar
                          
    ; Agregar el dígito al resultado
                          XOR  BH, BH                    ; BH = 0
                          ADD  AX, BX                    ; AX += dígito

    _SkipAdd:             
                          INC  SI                        ; siguiente carácter
                          DEC  CL
                          JMP  _ConvertLoop

    _StoreResult:         
    ; Guardamos el resultado en BUFFER_HIntputNum[0..3] (solo el primer DWORD)
                          LEA  DI, BUFFER_HIntputNum
                          MOV  [DI], AX

                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
InputToNumH ENDP

    ; ======= CONV PROCEDURES =======
    ; Here the procedures that will be used to convert the num to a base-n

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

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

    ; Print the number bit by bit in binary using the BUFFER_HIntputNum
HPrintNumBinary PROC

                          CALL PrintNewLine
                          LEA  DX, var_HmessageSeeNum
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX

                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]

                          MOV  CX, 16                    ; 16 bits in AX
                          MOV  BX, AX                    ; Work with BX
                          XOR  SI, SI                    ; Flag: first '1' already printed

    _NextBit:             
                          SHL  BX, 1                     ; Shift left, MSB goes to carry
                          JC   _Print1                   ; If carry set, print '1'
                          
    ; Check if we should print leading zeros
                          CMP  SI, 1
                          JE   _Print0                   ; If we've printed a '1', print '0'
                          JMP  _Continue                 ; Skip leading zeros
                          
    _Print1:              
                          MOV  DL, '1'
                          MOV  AH, 02h
                          INT  21h
                          MOV  SI, 1                     ; Set flag: first '1' printed
                          JMP  _Continue

    _Print0:              
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h

    _Continue:            
                          LOOP _NextBit
                          
    ; If no '1' was printed, the number is 0
                          CMP  SI, 0
                          JNE  _Done
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h

    _Done:                
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
HPrintNumBinary ENDP

    ; Print the number in Decimal using the BUFFER_HIntputNum
HPrintNumDecimal PROC

                          CALL PrintNewLine
                          LEA  DX, var_HmessageSeeDec
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI

    ; Cargar el número desde BUFFER_HIntputNum
                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                  ; AX = número

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  AX, 0
                          JNE  _ConvertLoop1
                          MOV  DL, '0'
                          CALL _PrintCharD
                          JMP  _End

    _ConvertLoop1:        
    ; Convertir número a ASCII decimal (reversa)
    ; Guardamos los dígitos en la pila (usamos CX como contador)
                          XOR  CX, CX                    ; Contador de dígitos
    _ConvertLoopContinue: 
                          CMP  AX, 0
                          JE   _PrintDigits
                          XOR  DX, DX                    ; Clear DX for division
                          MOV  BX, 10                    ; Divisor
                          DIV  BX                        ; AX = AX/10, DX = remainder
                          ADD  DL, '0'                   ; Convert to ASCII
                          PUSH DX                        ; Store digit on stack
                          INC  CX                        ; Increment digit count
                          JMP  _ConvertLoopContinue

    _PrintDigits:         
    ; Imprimir los dígitos en orden correcto
                          CMP  CX, 0
                          JE   _End
                          POP  DX
                          CALL _PrintCharD
                          DEC  CX
                          JMP  _PrintDigits

    _End:                 
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
    _PrintCharD:          
                          MOV  AH, 02h
                          INT  21h
                          RET
HPrintNumDecimal ENDP

    ; Print the number in Octal using the BUFFER_HIntputNum
HPrintNumOctal PROC
                          CALL PrintNewLine
                          LEA  DX, var_HmessageSeeOct
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI

                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                  ; AX = number
                          XOR  CX, CX
                          MOV  BX, 8                     ; base octal

                          CMP  AX, 0
                          JNE  _OctConvertLoop
                          MOV  DL, '0'
                          CALL _PrintCharO
                          JMP  _OctEnd

    _OctConvertLoop:      
                          CMP  AX, 0
                          JE   _OctPrintDigits
                          XOR  DX, DX
                          DIV  BX                        ; AX = AX/8, DX = remainder
                          ADD  DL, '0'                   ; Convert to ASCII
                          PUSH DX
                          INC  CX
                          JMP  _OctConvertLoop

    _OctPrintDigits:      
                          CMP  CX, 0
                          JE   _OctEnd
                          POP  DX
                          CALL _PrintCharO
                          DEC  CX
                          JMP  _OctPrintDigits

    _OctEnd:              
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
    _PrintCharO:          
                          MOV  AH, 02h
                          INT  21h
                          RET
HPrintNumOctal ENDP

    ; Print the number in Hexadecimal using the BUFFER_HIntputNum
HPrintNumHex PROC
                          CALL PrintNewLine
                          LEA  DX, var_HmessageSeeHex
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI

                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                  ; AX = número
                          XOR  CX, CX
                          MOV  BX, 16                    ; base hexadecimal

                          CMP  AX, 0
                          JNE  _HexConvertLoop
                          MOV  DL, '0'
                          CALL _PrintCharH
                          JMP  _HexEnd

    _HexConvertLoop:      
                          CMP  AX, 0
                          JE   _HexPrintDigits
                          XOR  DX, DX
                          DIV  BX                        ; AX = AX/16, DX = remainder
                          CMP  DL, 9
                          JLE  _HexDigit
                          ADD  DL, 'A' - 10              ; Convert 10-15 to A-F
                          JMP  _HexStore
    _HexDigit:            
                          ADD  DL, '0'                   ; Convert 0-9 to ASCII
    _HexStore:            
                          PUSH DX
                          INC  CX
                          JMP  _HexConvertLoop

    _HexPrintDigits:      
                          CMP  CX, 0
                          JE   _HexEnd
                          POP  DX
                          CALL _PrintCharH
                          DEC  CX
                          JMP  _HexPrintDigits

    _HexEnd:              
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
    _PrintCharH:          
                          MOV  AH, 02h
                          INT  21h
                          RET
HPrintNumHex ENDP


END MAIN_FROMH