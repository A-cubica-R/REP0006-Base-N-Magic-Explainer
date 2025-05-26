.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN MAIN_XPLN_D:NEAR

.DATA

    ; Util printing
    var_newLine             DB 13, 10, "$"
    ; Messages
    var_DmessageInit        DB "Initialized conversion: DECIMAL", 13, 10, "$"
    var_DmessageSeeNum      DB "In Binary your number is: ", "$"
    var_DmessageSeeDec      DB "In decimal your number is: ", "$"
    var_DmessageSeeOct      DB "In Octal your number is: ", "$"
    var_DmessageSeeHex      DB "In Hexadecimal your number is: ", "$"
    var_DmessageFint        DB "Finalized conversion", 13, 10, "$"
    var_Dexplanation        DB "Wanna see the explanation?(Y\N)", 13, 10, "$"
    var_messageInputErrorD1 DB "Input error, please try again", 13, 10, "$"
    ; Buffers
    BUFFER_DIntputNum       DD 11 DUP(0)
    BUFFER_TemporalTinnyD   DB 2, ?, 2 DUP(?)
    ; Debugging vars
    var_TestD1              DB "DDD Break point 1 DDDD", 13, 10, "$"
    var_TestD2              DB "DDD Break point 2 DDDD", 13, 10, "$"
    var_TestD3              DB "DDD Break point 3 DDDD", 13, 10, "$"
    var_TestD4              DB "DDD Break point 4 DDDD", 13, 10, "$"
    var_TestD5              DB "DDD Break point 5 DDDD", 13, 10, "$"
.CODE

MAIN_FROMD PROC NEAR PUBLIC
                          CALL InitializeConvertionD
                          RET
MAIN_FROMD ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionD PROC
                          CALL InputToNumD

                          LEA  DX, var_DmessageInit
                          CALL PrintString                               ; Print initialization message

                          CALL DPrintNumBinary
                          CALL DPrintNumDecimal
                          CALL DPrintNumOctal
                          CALL DPrintNumHex
                            
                          CALL PrintNewLine
                          CALL PrintNewLine
                          LEA  DX, var_DmessageFint
                          CALL PrintString
                          CALL PrintNewLine

                          LEA  DX, var_Dexplanation
                          CALL PrintString
                          CALL DExplanationProceed
                          RET
InitializeConvertionD ENDP

    ; Convert the ASCII string to a number from decimal format
InputToNumD PROC

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
                          
    ; Multiplicar resultado actual por 10 (base decimal)
    ; Usar aritmética de 32 bits: DX:AX *= 10
                          PUSH BX                                        ; Guardar BX
                          MOV  BX, 10                                    ; BX = 10
                          
    ; Multiplicar parte baja (AX * 10)
                          PUSH DX                                        ; Guardar parte alta
                          MUL  BX                                        ; AX = AX * 10, DX = overflow
                          MOV  DI, AX                                    ; DI = nueva parte baja
                          MOV  AX, DX                                    ; AX = overflow de la multiplicación
                          
    ; Multiplicar parte alta original y sumar overflow
                          POP  DX                                        ; Recuperar parte alta original
                          PUSH AX                                        ; Guardar overflow
                          MOV  AX, DX                                    ; AX = parte alta original
                          MUL  BX                                        ; DX:AX = parte alta * 10
                          POP  BX                                        ; BX = overflow de parte baja
                          ADD  AX, BX                                    ; Sumar overflow a parte alta
                          MOV  DX, AX                                    ; DX = nueva parte alta
                          MOV  AX, DI                                    ; AX = nueva parte baja
                          POP  BX                                        ; Restaurar BX
                          
    ; Convertir carácter ASCII a valor numérico
                          SUB  BL, '0'                                   ; BL = valor numérico del dígito
                          
    ; Validar que es un dígito decimal válido (0-9)
                          CMP  BL, 9
                          JA   _SkipAdd                                  ; Si > 9, saltar
                          
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
    ; Guardamos el resultado de 32 bits en BUFFER_DIntputNum
                          LEA  DI, BUFFER_DIntputNum
                          MOV  [DI], AX                                  ; Guardar parte baja
                          MOV  [DI+2], DX                                ; Guardar parte alta

                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
InputToNumD ENDP

    ; ======= CONV PROCEDURES =======
    ; Here the procedures that will be used to convert the num to a base-n
DExplanationProceed PROC

    _Initialization:      
                          CALL ReceiveConfirmD
                          CMP  AL, 'Y'
                          JE   _Proceed
                          CMP  AL, 'y'
                          JE   _Proceed
                          CMP  AL, 'N'
                          JE   _Finish
                          CMP  AL, 'n'
                          JE   _Finish

                          LEA  DX, var_messageInputErrorD1
                          CALL PrintString_wait                          ; Any input was valid to proceed, retry
                          JMP  _Initialization

    _Proceed:             
                          CALL MAIN_XPLN_D
                          RET

    _Finish:              
                          RET
DExplanationProceed ENDP

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

ReceiveConfirmD PROC
                          LEA  DX, BUFFER_TemporalTinnyD
                          mov  AH, 0Ah
                          int  21h

                          MOV  AL, BYTE PTR [BUFFER_TemporalTinnyD+2]    ; Read the first character of the confirmation input
                          RET
ReceiveConfirmD ENDP

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

    ; Print the number bit by bit in binary using the BUFFER_DIntputNum
DPrintNumBinary PROC

                          CALL PrintNewLine
                          LEA  DX, var_DmessageSeeNum
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_DIntputNum
                          LEA  SI, BUFFER_DIntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta
                          XOR  DI, DI                                    ; Flag: primer '1' ya impreso

    ; Verificar si el número es 0
                          CMP  DX, 0
                          JNE  _StartWithHigh
                          CMP  AX, 0
                          JNE  _StartWithLow
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h
                          JMP  _DoneBinary

    _StartWithHigh:       
    ; Imprimir parte alta (DX) primero
                          MOV  CX, 16                                    ; 16 bits en DX
                          MOV  BX, DX                                    ; Trabajar con BX
    _NextBitHigh:         
                          SHL  BX, 1                                     ; Shift left, MSB va a carry
                          JC   _Print1High                               ; Si carry está activo, imprimir '1'
                          
    ; Verificar si debemos imprimir ceros a la izquierda
                          CMP  DI, 1
                          JE   _Print0High                               ; Si ya imprimimos un '1', imprimir '0'
                          JMP  _ContinueHigh                             ; Saltar ceros iniciales
                          
    _Print1High:          
                          MOV  DL, '1'
                          MOV  AH, 02h
                          INT  21h
                          MOV  DI, 1                                     ; Activar flag: primer '1' impreso
                          JMP  _ContinueHigh

    _Print0High:          
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h

    _ContinueHigh:        
                          LOOP _NextBitHigh
                          
    _StartWithLow:        
    ; Imprimir parte baja (AX)
                          MOV  CX, 16                                    ; 16 bits en AX
                          MOV  BX, AX                                    ; Trabajar con BX
    _NextBitLow:          
                          SHL  BX, 1                                     ; Shift left, MSB va a carry
                          JC   _Print1Low                                ; Si carry está activo, imprimir '1'
                          
    ; Si ya imprimimos algún bit de la parte alta, siempre imprimir
                          CMP  DI, 1
                          JE   _Print0Low                                ; Imprimir '0'
                          JMP  _ContinueLow                              ; Saltar ceros iniciales
                          
    _Print1Low:           
                          MOV  DL, '1'
                          MOV  AH, 02h
                          INT  21h
                          MOV  DI, 1                                     ; Activar flag: primer '1' impreso
                          JMP  _ContinueLow

    _Print0Low:           
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h

    _ContinueLow:         
                          LOOP _NextBitLow

    _DoneBinary:          
                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
DPrintNumBinary ENDP

    ; Print the number in Decimal using the BUFFER_DIntputNum
DPrintNumDecimal PROC

                          CALL PrintNewLine
                          LEA  DX, var_DmessageSeeDec
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_DIntputNum
                          LEA  SI, BUFFER_DIntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  DX, 0
                          JNE  _ConvertLoop1
                          CMP  AX, 0
                          JNE  _ConvertLoop1
                          MOV  DL, '0'
                          CALL _PrintCharD
                          JMP  _EndDecimal

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
                          PUSH AX                                        ; Guardar parte baja original
                          MOV  AX, DX                                    ; Mover parte alta a AX
                          XOR  DX, DX                                    ; Limpiar DX para división
                          MOV  BX, 10                                    ; Divisor
                          DIV  BX                                        ; AX = parte_alta/10, DX = remainder
                          MOV  DI, AX                                    ; DI = nueva parte alta
                          MOV  AX, DX                                    ; AX = remainder de división anterior
                          MOV  DX, AX                                    ; DX = remainder
                          POP  AX                                        ; Recuperar parte baja original
                          DIV  BX                                        ; DX:AX / 10, AX = resultado, DX = remainder final
                          PUSH DI                                        ; Guardar nueva parte alta
                          MOV  BX, DX                                    ; BX = remainder (dígito)
                          POP  DX                                        ; DX = nueva parte alta
                          
                          ADD  BL, '0'                                   ; Convertir dígito a ASCII
                          PUSH BX                                        ; Guardar dígito en pila
                          INC  CX                                        ; Incrementar contador de dígitos
                          JMP  _ConvertLoopContinue

    _PrintDigits:         
    ; Imprimir los dígitos en orden correcto
                          CMP  CX, 0
                          JE   _EndDecimal
                          POP  DX
                          CALL _PrintCharD
                          DEC  CX
                          JMP  _PrintDigits

    _EndDecimal:          
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
DPrintNumDecimal ENDP

    ; Print the number in Octal using the BUFFER_DIntputNum
DPrintNumOctal PROC
                          CALL PrintNewLine
                          LEA  DX, var_DmessageSeeOct
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_DIntputNum
                          LEA  SI, BUFFER_DIntputNum
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
                          JNE  _DivideBy8
                          CMP  AX, 0
                          JE   _OctPrintDigits
                          
    _DivideBy8:           
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
    ; Imprimir los dígitos en orden correcto
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
DPrintNumOctal ENDP

    ; Print the number in Hexadecimal using the BUFFER_DIntputNum
DPrintNumHex PROC
                          CALL PrintNewLine
                          LEA  DX, var_DmessageSeeHex
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_DIntputNum
                          LEA  SI, BUFFER_DIntputNum
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
                          JNE  _DivideBy16
                          CMP  AX, 0
                          JE   _HexPrintDigits
                          
    _DivideBy16:          
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
                          
    ; Convertir resto a carácter ASCII hexadecimal
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
    ; Imprimir los dígitos en orden correcto
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
DPrintNumHex ENDP


END MAIN_FROMD