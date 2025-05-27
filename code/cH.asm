.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN MAIN_XPLN_H:NEAR

.DATA

    ; Util printing
    var_newLine             DB 13, 10, "$"
    ; Messages
    var_HmessageInit        DB "Initialized conversion: HEXADECIMAL", 13, 10, "$"
    var_HmessageSeeNum      DB "In Binary your number is: ", "$"
    var_HmessageSeeDec      DB "In decimal your number is: ", "$"
    var_HmessageSeeOct      DB "In Octal your number is: ", "$"
    var_HmessageSeeHex      DB "In Hexadecimal your number is: ", "$"
    var_HmessageFint        DB "Finalized conversion", 13, 10, "$"
    var_Hexplanation        DB "Wanna see the explanation?(Y\N)", 13, 10, "$"
    var_messageInputErrorH1 DB "Input error, please try again", 13, 10, "$"
    ; Buffers
    BUFFER_HIntputNum       DD 11 DUP(0)
    BUFFER_TemporalTinnyH   DB 2, ?, 2 DUP(?)
    ; Debugging vars
    var_TestH1              DB "HHH Break point 1 HHHH", 13, 10, "$"
    var_TestH2              DB "HHH Break point 2 HHHH", 13, 10, "$"
    var_TestH3              DB "HHH Break point 3 HHHH", 13, 10, "$"
    var_TestH4              DB "HHH Break point 4 HHHH", 13, 10, "$"
    var_TestH5              DB "HHH Break point 5 HHHH", 13, 10, "$"
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
                          CALL PrintString                               ; Print initialization message

                          CALL HPrintNumBinary
                          CALL HPrintNumDecimal
                          CALL HPrintNumOctal
                          CALL HPrintNumHex
                            
                          CALL PrintNewLine
                          CALL PrintNewLine
                          LEA  DX, var_HmessageFint
                          CALL PrintString

                          LEA  DX, var_Hexplanation
                          CALL PrintString
                          CALL HExplanationProceed
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

    ; Inicializar usando DX:AX como registro de 32 bits
                          XOR  AX, AX                                    ; AX = 0 → parte baja del acumulador
                          XOR  DX, DX                                    ; DX = 0 → parte alta del acumulador
                          LEA  SI, BUFFER_IntputStr
                          MOV  CL, [SI + 1]                              ; CL = número de caracteres introducidos
                          ADD  SI, 2                                     ; SI apunta al primer carácter

    _ConvertLoop:         
                          CMP  CL, 0
                          JE   _StoreResult                              ; Si ya no quedan caracteres, terminar

                          MOV  BL, [SI]                                  ; BL = siguiente carácter
                          
    ; Multiplicar resultado actual por 16 (base hexadecimal)
    ; Usar aritmética de 32 bits: DX:AX *= 16
                          PUSH BX                                        ; Guardar BX
                          MOV  BX, 16                                    ; BX = 16
                          
    ; Multiplicar parte baja (AX * 16)
                          PUSH DX                                        ; Guardar parte alta
                          MUL  BX                                        ; AX = AX * 16, DX = overflow
                          MOV  DI, AX                                    ; DI = nueva parte baja
                          MOV  AX, DX                                    ; AX = overflow de la multiplicación
                          
    ; Multiplicar parte alta original y sumar overflow
                          POP  DX                                        ; Recuperar parte alta original
                          PUSH AX                                        ; Guardar overflow
                          MOV  AX, DX                                    ; AX = parte alta original
                          MUL  BX                                        ; DX:AX = parte alta * 16
                          POP  BX                                        ; BX = overflow de parte baja
                          ADD  AX, BX                                    ; Sumar overflow a parte alta
                          MOV  DX, AX                                    ; DX = nueva parte alta
                          MOV  AX, DI                                    ; AX = nueva parte baja
                          POP  BX                                        ; Restaurar BX
                          
    ; Convertir carácter ASCII a valor numérico
    ; Primero verificar si es dígito (0-9) o letra (A-F)
                          CMP  BL, '9'
                          JLE  _IsDigit                                  ; Si <= '9', es dígito
                          
    ; Es letra, convertir A-F a 10-15
                          CMP  BL, 'F'
                          JLE  _IsUpperCase                              ; Si <= 'F', es A-F
                          
    ; Verificar si es minúscula a-f
                          CMP  BL, 'f'
                          JLE  _IsLowerCase                              ; Si <= 'f', podría ser a-f
                          JMP  _SkipAdd                                  ; Si no, saltar
                          
    _IsLowerCase:         
                          CMP  BL, 'a'
                          JL   _SkipAdd                                  ; Si < 'a', no es válido
                          SUB  BL, 'a' - 10                              ; Convertir a-f a 10-15
                          JMP  _AddDigit
                          
    _IsUpperCase:         
                          CMP  BL, 'A'
                          JL   _SkipAdd                                  ; Si < 'A', no es válido
                          SUB  BL, 'A' - 10                              ; Convertir A-F a 10-15
                          JMP  _AddDigit
                          
    _IsDigit:             
                          CMP  BL, '0'
                          JL   _SkipAdd                                  ; Si < '0', no es válido
                          SUB  BL, '0'                                   ; Convertir 0-9 a 0-9
                          
    _AddDigit:            
    ; Validar que el valor esté en rango hexadecimal (0-15)
                          CMP  BL, 15
                          JA   _SkipAdd                                  ; Si > 15, saltar
                          
    ; Agregar el dígito al resultado usando aritmética de 32 bits
                          XOR  BH, BH                                    ; BH = 0
                          ADD  AX, BX                                    ; Sumar a parte baja
                          JNC  _SkipAdd                                  ; Si no hay carry, continuar
                          INC  DX                                        ; Si hay carry, incrementar parte alta

    _SkipAdd:             
                          INC  SI                                        ; siguiente carácter
                          DEC  CL
                          JMP  _ConvertLoop

    _StoreResult:         
    ; Guardamos el resultado de 32 bits en BUFFER_HIntputNum
                          LEA  DI, BUFFER_HIntputNum
                          MOV  [DI], AX                                  ; Guardar parte baja
                          MOV  [DI+2], DX                                ; Guardar parte alta

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
HExplanationProceed PROC

    _Initialization:      
                          CALL ReceiveConfirmH
                          CMP  AL, 'Y'
                          JE   _Proceed
                          CMP  AL, 'y'
                          JE   _Proceed
                          CMP  AL, 'N'
                          JE   _Finish
                          CMP  AL, 'n'
                          JE   _Finish

                          LEA  DX, var_messageInputErrorH1
                          CALL PrintString_wait
                          JMP  _Initialization

    _Proceed:             
                          CALL MAIN_XPLN_H
                          RET

    _Finish:              
                          RET
HExplanationProceed ENDP

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

ReceiveConfirmH PROC
                          LEA  DX, BUFFER_TemporalTinnyH
                          mov  AH, 0Ah
                          int  21h

    ; Read the first character of the confirmation input
                          MOV  AL, BYTE PTR [BUFFER_TemporalTinnyH+2]
                          RET
ReceiveConfirmH ENDP

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
                          MOV  DX, [SI+2]                                ; DX = parte alta (16 bits superiores)
                          MOV  AX, [SI]                                  ; AX = parte baja (16 bits inferiores)

    ; Primero imprimir la parte alta (DX) si no es cero
                          CMP  DX, 0
                          JE   _PrintLowPart                             ; Si parte alta es 0, solo imprimir parte baja
                          
                          MOV  CX, 16                                    ; 16 bits en DX
                          MOV  BX, DX                                    ; Work with BX
                          XOR  SI, SI                                    ; Flag: first '1' already printed

    _NextBitHigh:         
                          SHL  BX, 1                                     ; Shift left, MSB goes to carry
                          JC   _Print1High                               ; If carry set, print '1'
                          
    ; Check if we should print leading zeros
                          CMP  SI, 1
                          JE   _Print0High                               ; If we've printed a '1', print '0'
                          JMP  _ContinueHigh                             ; Skip leading zeros
                          
    _Print1High:          
                          MOV  DL, '1'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          MOV  SI, 1                                     ; Set flag: first '1' printed
                          JMP  _ContinueHigh
                          
    _Print0High:          
                          PUSH DX
                          MOV  DL, '0'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          POP  DX

    _ContinueHigh:        
                          LOOP _NextBitHigh
                          
    ; Ahora imprimir la parte baja, pero todas las cifras (no saltar ceros iniciales)
                          MOV  CX, 16                                    ; 16 bits en AX
                          MOV  BX, AX                                    ; Work with BX

    _NextBitLow:          
                          SHL  BX, 1                                     ; Shift left, MSB goes to carry
                          JC   _Print1Low                                ; If carry set, print '1'
                          
                          PUSH DX
                          MOV  DL, '0'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          POP  DX
                          JMP  _ContinueLow
                          
    _Print1Low:           
                          PUSH DX
                          MOV  DL, '1'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          POP  DX

    _ContinueLow:         
                          LOOP _NextBitLow
                          JMP  _Done

    _PrintLowPart:        
    ; Solo la parte baja tiene bits, imprimir normalmente (saltando ceros iniciales)
                          MOV  CX, 16                                    ; 16 bits en AX
                          MOV  BX, AX                                    ; Work with BX
                          XOR  SI, SI                                    ; Flag: first '1' already printed

    _NextBit:             
                          SHL  BX, 1                                     ; Shift left, MSB goes to carry
                          JC   _Print1                                   ; If carry set, print '1'
                          
    ; Check if we should print leading zeros
                          CMP  SI, 1
                          JE   _Print0                                   ; If we've printed a '1', print '0'
                          JMP  _Continue                                 ; Skip leading zeros
                          
    _Print1:              
                          MOV  DL, '1'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          MOV  SI, 1                                     ; Set flag: first '1' printed
                          JMP  _Continue
                          
    _Print0:              
                          MOV  DL, '0'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX

    _Continue:            
                          LOOP _NextBit
                          
    ; If no '1' was printed, the number is 0
                          CMP  SI, 0
                          JNE  _Done
                          MOV  DL, '0'
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX

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
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_HIntputNum
                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  DX, 0
                          JNE  _ConvertLoop1
                          CMP  AX, 0
                          JNE  _ConvertLoop1
                          MOV  DL, '0'
                          CALL _PrintCharD
                          JMP  _End

    _ConvertLoop1:        
    ; Convertir número de 32 bits a ASCII decimal (reversa)
    ; Guardamos los dígitos en la pila (usamos CX como contador)
                          XOR  CX, CX                                    ; Contador de dígitos
                          
    _ConvertLoopContinue: 
    ; Verificar si DX:AX es 0
                          CMP  DX, 0
                          JNE  _DivideBy10
                          CMP  AX, 0
                          JE   _PrintDigits
                          
    _DivideBy10:          
    ; División de 32 bits por 10: DX:AX / 10
    ; Método: dividir parte alta primero, luego combinar con parte baja
                          PUSH AX                                        ; Guardar parte baja original
                          MOV  AX, DX                                    ; Mover parte alta a AX
                          XOR  DX, DX                                    ; Limpiar DX para división
                          MOV  BX, 10                                    ; Divisor
                          DIV  BX                                        ; AX = parte_alta/10, DX = remainder
                          MOV  DI, AX                                    ; DI = nueva parte alta
                          MOV  AX, DX                                    ; AX = remainder de división anterior
                          MOV  DX, AX                                    ; DX = remainder
                          POP  AX                                        ; Recuperar parte baja original
    ; Ahora DX contiene el remainder de parte alta * 65536
                          DIV  BX                                        ; DX:AX / 10, AX = resultado, DX = remainder final
    ; AX = nueva parte baja, DX = remainder (dígito)
                          PUSH DI                                        ; Guardar nueva parte alta
                          MOV  BX, DX                                    ; BX = remainder (dígito)
                          POP  DX                                        ; DX = nueva parte alta
    ; Ahora: DX = nueva parte alta, AX = nueva parte baja, BX = dígito
                          
                          ADD  BL, '0'                                   ; Convertir dígito a ASCII
                          PUSH BX                                        ; Guardar dígito en pila
                          INC  CX                                        ; Incrementar contador de dígitos
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
                          POP  DI
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
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_HIntputNum
                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta
                          XOR  CX, CX                                    ; Contador de dígitos

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  DX, 0
                          JNE  _OctConvertLoop
                          CMP  AX, 0
                          JNE  _OctConvertLoop
                          MOV  DL, '0'
                          CALL _PrintCharO
                          JMP  _OctEnd

    _OctConvertLoop:      
    ; Verificar si DX:AX es 0
                          CMP  DX, 0
                          JNE  _OctDivideBy8
                          CMP  AX, 0
                          JE   _OctPrintDigits
                          
    _OctDivideBy8:        
    ; División de 32 bits por 8: DX:AX / 8
                          PUSH AX                                        ; Guardar parte baja original
                          MOV  AX, DX                                    ; Mover parte alta a AX
                          XOR  DX, DX                                    ; Limpiar DX para división
                          MOV  BX, 8                                     ; Divisor
                          DIV  BX                                        ; AX = parte_alta/8, DX = remainder
                          MOV  DI, AX                                    ; DI = nueva parte alta
                          MOV  AX, DX                                    ; AX = remainder de división anterior
                          MOV  DX, AX                                    ; DX = remainder
                          POP  AX                                        ; Recuperar parte baja original
                          DIV  BX                                        ; DX:AX / 8, AX = resultado, DX = remainder final
                          PUSH DI                                        ; Guardar nueva parte alta
                          MOV  BX, DX                                    ; BX = remainder (dígito)
                          POP  DX                                        ; DX = nueva parte alta
                          
                          ADD  BL, '0'                                   ; Convertir dígito a ASCII
                          PUSH BX                                        ; Guardar dígito en pila
                          INC  CX                                        ; Incrementar contador de dígitos
                          JMP  _OctConvertLoop

    _OctPrintDigits:      
                          CMP  CX, 0
                          JE   _OctEnd
                          POP  DX
                          CALL _PrintCharO
                          DEC  CX
                          JMP  _OctPrintDigits

    _OctEnd:              
                          POP  DI
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
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_HIntputNum
                          LEA  SI, BUFFER_HIntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta
                          XOR  CX, CX                                    ; Contador de dígitos

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  DX, 0
                          JNE  _HexConvertLoop
                          CMP  AX, 0
                          JNE  _HexConvertLoop
                          MOV  DL, '0'
                          CALL _PrintCharH
                          JMP  _HexEnd

    _HexConvertLoop:      
    ; Verificar si DX:AX es 0
                          CMP  DX, 0
                          JNE  _HexDivideBy16
                          CMP  AX, 0
                          JE   _HexPrintDigits
                          
    _HexDivideBy16:       
    ; División de 32 bits por 16: DX:AX / 16
                          PUSH AX                                        ; Guardar parte baja original
                          MOV  AX, DX                                    ; Mover parte alta a AX
                          XOR  DX, DX                                    ; Limpiar DX para división
                          MOV  BX, 16                                    ; Divisor
                          DIV  BX                                        ; AX = parte_alta/16, DX = remainder
                          MOV  DI, AX                                    ; DI = nueva parte alta
                          MOV  AX, DX                                    ; AX = remainder de división anterior
                          MOV  DX, AX                                    ; DX = remainder
                          POP  AX                                        ; Recuperar parte baja original
                          DIV  BX                                        ; DX:AX / 16, AX = resultado, DX = remainder final
                          PUSH DI                                        ; Guardar nueva parte alta
                          MOV  BX, DX                                    ; BX = remainder (dígito)
                          POP  DX                                        ; DX = nueva parte alta
                          
    ; Convertir dígito a ASCII hexadecimal
                          CMP  BL, 9
                          JLE  _HexDigit
                          ADD  BL, 'A' - 10                              ; Convert 10-15 to A-F
                          JMP  _HexStore
    _HexDigit:            
                          ADD  BL, '0'                                   ; Convert 0-9 to ASCII
    _HexStore:            
                          PUSH BX                                        ; Guardar dígito en pila
                          INC  CX                                        ; Incrementar contador de dígitos
                          JMP  _HexConvertLoop

    _HexPrintDigits:      
                          CMP  CX, 0
                          JE   _HexEnd
                          POP  DX
                          CALL _PrintCharH
                          DEC  CX
                          JMP  _HexPrintDigits

    _HexEnd:              
                          POP  DI
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