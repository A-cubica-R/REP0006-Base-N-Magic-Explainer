.MODEL small

EXTERN BUFFER_IntputStr:NEAR

.DATA

    ; Util printing
    var_newLine        DB 13, 10, "$"
    ; Messages
    var_OmessageInit   DB "Initialized conversion: OCTAL", 13, 10, "$"
    var_OmessageSeeNum DB "In Binary your number is: ", "$"
    var_OmessageSeeDec DB "In decimal your number is: ", "$"
    var_OmessageSeeOct DB "In Octal your number is: ", "$"
    var_OmessageSeeHex DB "In Hexadecimal your number is: ", "$"
    var_OmessageFint   DB "Finalized conversion", 13, 10, "$"
    ; Buffers
    BUFFER_OIntputNum   DD 11 DUP(0)
    ; Debugging vars
    var_TestO1         DB "OOO Break point 1 OOOO", 13, 10, "$"
    var_TestO2         DB "OOO Break point 2 OOOO", 13, 10, "$"
    var_TestO3         DB "OOO Break point 3 OOOO", 13, 10, "$"
    var_TestO4         DB "OOO Break point 4 OOOO", 13, 10, "$"
    var_TestO5         DB "OOO Break point 5 OOOO", 13, 10, "$"
.CODE

MAIN_FROMO PROC NEAR PUBLIC
                          CALL  InitializeConvertionO
                          RET
MAIN_FROMO ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionO PROC
                          CALL  InputToNumO

                          LEA   DX, var_OmessageInit
                          CALL  PrintString                 ; Print initialization message

                          CALL  OPrintNumBinary
                          CALL  OPrintNumDecimal
                          CALL  OPrintNumOctal
                          CALL  OPrintNumHex
                            
                          CALL  PrintNewLine
                          CALL  PrintNewLine
                          LEA   DX, var_OmessageFint
                          CALL  PrintString_wait
                          RET
InitializeConvertionO ENDP

    ; Convert the ASCII string to a number from octal format
InputToNumO PROC

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
                          
                          ; Multiplicar resultado actual por 8 (base octal)
                          MOV  DX, 8
                          MUL  DX                        ; AX = AX * 8
                          
                          ; Convertir carácter ASCII a valor numérico
                          SUB  BL, '0'                   ; BL = valor numérico del dígito
                          
                          ; Validar que es un dígito octal válido (0-7)
                          CMP  BL, 7
                          JA   _SkipAdd                  ; Si > 7, saltar
                          
                          ; Agregar el dígito al resultado
                          XOR  BH, BH                    ; BH = 0
                          ADD  AX, BX                    ; AX += dígito

    _SkipAdd:             
                          INC  SI                        ; siguiente carácter
                          DEC  CL
                          JMP  _ConvertLoop

    _StoreResult:         
    ; Guardamos el resultado en BUFFER_OIntputNum[0..3] (solo el primer DWORD)
                          LEA  DI, BUFFER_OIntputNum
                          MOV  [DI], AX

                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
InputToNumO ENDP

    ; ======= CONV PROCEDURES =======
    ; Here the procedures that will be used to convert the num to a base-n

    ; ======= AUXX PROCEDURES =======
    ; Here the procedures that will work like a auxiliar process

    ; Print a string to the screen from DX register
PrintString PROC
                          MOV   AH,09h
                          INT   21h
                          RET
PrintString ENDP

    ; Print a string to the screen from DX register and wait for a key press
PrintString_wait PROC
                          MOV   ah, 09h
                          INT   21h
                          MOV   ah, 0
                          INT   16h
                          RET
PrintString_wait ENDP

    ; Print a string to the screen from DX register and add a new line
PrintNewLine PROC
                          MOV   AH, 09h
                          LEA   DX, var_newLine
                          INT   21h
                          RET
PrintNewLine ENDP

    ; Erase the content of the screen
ClearScreen PROC
                          MOV   AH,0
                          MOV   AL,3
                          INT   10h
                          RET
ClearScreen ENDP

    ; Print the number bit by bit in binary using the BUFFER_OIntputNum
OPrintNumBinary PROC

                          CALL  PrintNewLine
                          LEA   DX, var_OmessageSeeNum
                          CALL  PrintString
                          
                          PUSH  AX
                          PUSH  BX
                          PUSH  CX
                          PUSH  DX

                          LEA   SI, BUFFER_OIntputNum
                          MOV   AX, [SI]

                          MOV   CX, 16                      ; 16 bits in AX
                          MOV   BX, AX                      ; Work with BX
                          XOR   SI, SI                      ; Flag: first '1' already printed

    _NextBit:             
                          SHL   BX, 1                       ; Shift left, MSB goes to carry
                          JC    _Print1                     ; If carry set, print '1'
                          
    ; Check if we should print leading zeros
                          CMP   SI, 1
                          JE    _Print0                     ; If we've printed a '1', print '0'
                          JMP   _Continue                   ; Skip leading zeros
                          
    _Print1:              
                          MOV   DL, '1'
                          MOV   AH, 02h
                          INT   21h
                          MOV   SI, 1                       ; Set flag: first '1' printed
                          JMP   _Continue

    _Print0:              
                          MOV   DL, '0'
                          MOV   AH, 02h
                          INT   21h

    _Continue:            
                          LOOP  _NextBit
                          
    ; If no '1' was printed, the number is 0
                          CMP   SI, 0
                          JNE   _Done
                          MOV   DL, '0'
                          MOV   AH, 02h
                          INT   21h

    _Done:                
                          POP   DX
                          POP   CX
                          POP   BX
                          POP   AX
                          RET
OPrintNumBinary ENDP

    ; Print the number in Decimal using the BUFFER_OIntputNum
OPrintNumDecimal PROC

                          CALL  PrintNewLine
                          LEA   DX, var_OmessageSeeDec
                          CALL  PrintString
                          
                          PUSH  AX
                          PUSH  BX
                          PUSH  CX
                          PUSH  DX
                          PUSH  SI

    ; Cargar el número desde BUFFER_OIntputNum
                          LEA   SI, BUFFER_OIntputNum
                          MOV   AX, [SI]                    ; AX = número

    ; Si el número es 0, imprimimos '0' directamente
                          CMP   AX, 0
                          JNE   _ConvertLoop1
                          MOV   DL, '0'
                          CALL  _PrintCharD
                          JMP   _End

    _ConvertLoop1:        
    ; Convertir número a ASCII decimal (reversa)
    ; Guardamos los dígitos en la pila (usamos CX como contador)
                          XOR   CX, CX                      ; Contador de dígitos
    _ConvertLoopContinue: 
                          CMP   AX, 0
                          JE    _PrintDigits
                          XOR   DX, DX                      ; Clear DX for division
                          MOV   BX, 10                      ; Divisor
                          DIV   BX                          ; AX = AX/10, DX = remainder
                          ADD   DL, '0'                     ; Convert to ASCII
                          PUSH  DX                          ; Store digit on stack
                          INC   CX                          ; Increment digit count
                          JMP   _ConvertLoopContinue

    _PrintDigits:         
    ; Imprimir los dígitos en orden correcto
                          CMP   CX, 0
                          JE    _End
                          POP   DX
                          CALL  _PrintCharD
                          DEC   CX
                          JMP   _PrintDigits

    _End:                 
                          POP   SI
                          POP   DX
                          POP   CX
                          POP   BX
                          POP   AX
                          RET
    _PrintCharD:           
                          MOV   AH, 02h
                          INT   21h
                          RET
OPrintNumDecimal ENDP

    ; Print the number in Octal using the BUFFER_OIntputNum
OPrintNumOctal PROC
                          CALL  PrintNewLine
                          LEA   DX, var_OmessageSeeOct
                          CALL  PrintString

                          PUSH  AX
                          PUSH  BX
                          PUSH  CX
                          PUSH  DX
                          PUSH  SI

                          LEA   SI, BUFFER_OIntputNum
                          MOV   AX, [SI]                    ; AX = number
                          XOR   CX, CX
                          MOV   BX, 8                       ; base octal

                          CMP   AX, 0
                          JNE   _OctConvertLoop
                          MOV   DL, '0'
                          CALL  _PrintCharO
                          JMP   _OctEnd

    _OctConvertLoop:      
                          CMP   AX, 0
                          JE    _OctPrintDigits
                          XOR   DX, DX
                          DIV   BX                          ; AX = AX/8, DX = remainder
                          ADD   DL, '0'                     ; Convert to ASCII
                          PUSH  DX
                          INC   CX
                          JMP   _OctConvertLoop

    _OctPrintDigits:      
                          CMP   CX, 0
                          JE    _OctEnd
                          POP   DX
                          CALL  _PrintCharO
                          DEC   CX
                          JMP   _OctPrintDigits

    _OctEnd:              
                          POP   SI
                          POP   DX
                          POP   CX
                          POP   BX
                          POP   AX
                          RET
    _PrintCharO:           
                          MOV   AH, 02h
                          INT   21h
                          RET
OPrintNumOctal ENDP

    ; Print the number in Hexadecimal using the BUFFER_OIntputNum
OPrintNumHex PROC
                          CALL  PrintNewLine
                          LEA   DX, var_OmessageSeeHex
                          CALL  PrintString

                          PUSH  AX
                          PUSH  BX
                          PUSH  CX
                          PUSH  DX
                          PUSH  SI

                          LEA   SI, BUFFER_OIntputNum
                          MOV   AX, [SI]                    ; AX = número
                          XOR   CX, CX
                          MOV   BX, 16                      ; base hexadecimal

                          CMP   AX, 0
                          JNE   _HexConvertLoop
                          MOV   DL, '0'
                          CALL  _PrintCharH
                          JMP   _HexEnd

    _HexConvertLoop:      
                          CMP   AX, 0
                          JE    _HexPrintDigits
                          XOR   DX, DX
                          DIV   BX                          ; AX = AX/16, DX = remainder
                          CMP   DL, 9
                          JLE   _HexDigit
                          ADD   DL, 'A' - 10                ; Convert 10-15 to A-F
                          JMP   _HexStore
    _HexDigit:            
                          ADD   DL, '0'                     ; Convert 0-9 to ASCII
    _HexStore:            
                          PUSH  DX
                          INC   CX
                          JMP   _HexConvertLoop

    _HexPrintDigits:      
                          CMP   CX, 0
                          JE    _HexEnd
                          POP   DX
                          CALL  _PrintCharH
                          DEC   CX
                          JMP   _HexPrintDigits

    _HexEnd:              
                          POP   SI
                          POP   DX
                          POP   CX
                          POP   BX
                          POP   AX
                          RET
    _PrintCharH:           
                          MOV   AH, 02h
                          INT   21h
                          RET
OPrintNumHex ENDP


END MAIN_FROMO