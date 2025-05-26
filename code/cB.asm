.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN MAIN_XPLN_B:NEAR

.DATA

    ; Util printing
    var_newLine             DB 13, 10, "$"
    ; Messages
    var_BmessageInit        DB "Initialized conversion: BINARY", 13, 10, "$"
    var_BmessageSeeNum      DB "In Binary your number is: ", "$"
    var_BmessageSeeDec      DB "In decimal your number is: ", "$"
    var_BmessageSeeOct      DB "In Octal your number is: ", "$"
    var_BmessageSeeHex      DB "In Hexadecimal your number is: ", "$"
    var_BmessageFint        DB "Finalized conversion", 13, 10, "$"
    var_Bexplanation        DB "Wanna see the explanation?(Y\N)", 13, 10, "$"
    var_messageInputErrorB1 DB "Input error, please try again", 13, 10, "$"
    ; Buffers
    BUFFER_IntputNum        DD 11 DUP(0)
    BUFFER_TemporalTinnyB   DB 2, ?, 2 DUP(?)
    ; Debugging vars
    var_TestB1              DB "BBB Break point 1 BBBB", 13, 10, "$"
    var_TestB2              DB "BBB Break point 2 BBBB", 13, 10, "$"
    var_TestB3              DB "BBB Break point 3 BBBB", 13, 10, "$"
    var_TestB4              DB "BBB Break point 4 BBBB", 13, 10, "$"
    var_TestB5              DB "BBB Break point 5 BBBB", 13, 10, "$"
.CODE

MAIN_FROMB PROC NEAR PUBLIC
                          CALL InitializeConvertionB
                          RET
MAIN_FROMB ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionB PROC
                          CALL InputToNumB

                          LEA  DX, var_BmessageInit
                          CALL PrintString                               ; Print initialization message

                          CALL BPrintNumBinary
                          CALL BPrintNumDecimal
                          CALL BPrintNumOctal
                          CALL BPrintNumHex
                            
                          CALL PrintNewLine
                          CALL PrintNewLine
                          LEA  DX, var_BmessageFint
                          CALL PrintString
                          CALL PrintNewLine

                          LEA  DX, var_Bexplanation
                          CALL PrintString
                          CALL BExplanationProceed
                          RET
InitializeConvertionB ENDP

    ; Convert the ASCII string to a number in binary way
InputToNumB PROC

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
                          
    ; Desplazar DX:AX una posición a la izquierda (multiplicar por 2)
                          SHL  AX, 1                                     ; Desplazar parte baja
                          RCL  DX, 1                                     ; Rotar parte alta con carry

                          CMP  BL, '1'
                          JNE  _SkipAdd
                          INC  AX                                        ; Si el bit era 1, sumamos 1 a parte baja
                          JNC  _SkipAdd                                  ; Si no hay overflow, continuar
                          INC  DX                                        ; Si hay overflow, incrementar parte alta

    _SkipAdd:             
                          INC  SI                                        ; siguiente carácter
                          DEC  CL
                          JMP  _ConvertLoop

    _StoreResult:         
    ; Guardamos el resultado de 32 bits en BUFFER_IntputNum
                          LEA  DI, BUFFER_IntputNum
                          MOV  [DI], AX                                  ; Guardar parte baja
                          MOV  [DI+2], DX                                ; Guardar parte alta

                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
InputToNumB ENDP

    ; ======= CONV PROCEDURES =======
    ; Here the procedures that will be used to convert the num to a base-n

BExplanationProceed PROC

    _Initialization:      
                          CALL ReceiveConfirmB
                          CMP  AL, 'Y'
                          JE   _Proceed
                          CMP  AL, 'y'
                          JE   _Proceed
                          CMP  AL, 'N'
                          JE   _Finish
                          CMP  AL, 'n'
                          JE   _Finish

                          LEA  DX, var_messageInputErrorB1
                          CALL PrintString_wait                          ; Any input was valid to proceed, retry
                          JMP  _Initialization

    _Proceed:             
                          CALL MAIN_XPLN_B
                          RET

    _Finish:              
                          RET
BExplanationProceed ENDP

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

ReceiveConfirmB PROC
                          LEA  DX, BUFFER_TemporalTinnyB
                          mov  AH, 0Ah
                          int  21h

                          MOV  AL, BYTE PTR [BUFFER_TemporalTinnyB+2]    ; Read the first character of the confirmation input
                          RET
ReceiveConfirmB ENDP

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

    ; Print the number bit by bit in binary using the BUFFER_IntputNum
BPrintNumBinary PROC

                          CALL PrintNewLine
                          LEA  DX, var_BmessageSeeNum
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_IntputNum
                          LEA  SI, BUFFER_IntputNum
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
BPrintNumBinary ENDP

    ; Print the number bit by bit in Decimal using the BUFFER_IntputNum
BPrintNumDecimal PROC

                          CALL PrintNewLine
                          LEA  DX, var_BmessageSeeDec
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI
                          PUSH DI

    ; Cargar el número de 32 bits desde BUFFER_IntputNum
                          LEA  SI, BUFFER_IntputNum
                          MOV  AX, [SI]                                  ; AX = parte baja
                          MOV  DX, [SI+2]                                ; DX = parte alta

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  DX, 0
                          JNE  _ConvertLoop1
                          CMP  AX, 0
                          JNE  _ConvertLoop1
                          MOV  DL, '0'
                          CALL _PrintChar
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
                          CALL _PrintChar
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
    _PrintChar:           
                          PUSH AX
                          MOV  AH, 02h
                          INT  21h
                          POP  AX
                          RET
BPrintNumDecimal ENDP

    ; Print the number bit by bit in Octal using the BUFFER_IntputNum
BPrintNumOctal PROC
                          CALL PrintNewLine
                          LEA  DX, var_BmessageSeeOct
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI

                          LEA  SI, BUFFER_IntputNum
                          MOV  AX, [SI]                                  ; AX = number
                          XOR  CX, CX
                          MOV  BX, 8                                     ; base octal

                          CMP  AX, 0
                          JNE  _OctConvertLoop
                          MOV  DL, '0'
                          CALL _PrintChar
                          JMP  _OctEnd

    _OctConvertLoop:      
                          XOR  DX, DX
                          DIV  BX                                        ; AX / 8, rest in DL
                          ADD  DL, '0'
                          PUSH DX
                          INC  CX
                          CMP  AX, 0
                          JNE  _OctConvertLoop

    _OctPrintDigits:      
                          POP  DX
                          CALL _PrintChar
                          LOOP _OctPrintDigits

    _OctEnd:              
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
BPrintNumOctal ENDP

    ; Print the number bit by bit in Hexadecimal using the BUFFER_IntputNum
BPrintNumHex PROC
                          CALL PrintNewLine
                          LEA  DX, var_BmessageSeeHex
                          CALL PrintString

                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX
                          PUSH SI

                          LEA  SI, BUFFER_IntputNum
                          MOV  AX, [SI]                                  ; AX = número
                          XOR  CX, CX
                          MOV  BX, 16                                    ; base hexadecimal

                          CMP  AX, 0
                          JNE  _HexConvertLoop
                          MOV  DL, '0'
                          CALL _PrintChar
                          JMP  _HexEnd

    _HexConvertLoop:      
                          XOR  DX, DX
                          DIV  BX                                        ; AX / 16
    ; convertir resto en DL a carácter ASCII
                          CMP  DL, 9
                          JG   _HexLetter
                          ADD  DL, '0'
                          JMP  _HexPush
    _HexLetter:           
                          ADD  DL, 'A' - 10                              ; DL = 10 → 'A', ..., 15 → 'F'
    _HexPush:             
                          PUSH DX
                          INC  CX
                          CMP  AX, 0
                          JNE  _HexConvertLoop

    _HexPrintDigits:      
                          POP  DX
                          CALL _PrintChar
                          LOOP _HexPrintDigits

    _HexEnd:              
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
BPrintNumHex ENDP


END MAIN_FROMB