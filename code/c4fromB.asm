.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN BUFFER_OutputStr:NEAR

.DATA

    ; Util printing
    var_newLine        DB 13, 10, "$"
    ; Messages
    var_BmessageInit   DB "Initialized conversion", 13, 10, "$"
    var_BmessageSeeNum DB "In Binary your number is: ", "$"
    var_BmessageSeeDec DB "In decimal your number is: ", "$"
    var_BmessageSeeOct DB "In Octal your number is: ", "$"
    var_BmessageSeeHex DB "In Hexadecimal your number is: ", "$"
    var_BmessageFint   DB "Finalized conversion", 13, 10, "$"
    ; Buffers
    BUFFER_IntputNum   DD 11 DUP(0)
    ; Debugging vars
    var_TestB1         DB "BBB Break point 1 BBBB", 13, 10, "$"
    var_TestB2         DB "BBB Break point 2 BBBB", 13, 10, "$"
    var_TestB3         DB "BBB Break point 3 BBBB", 13, 10, "$"
    var_TestB4         DB "BBB Break point 4 BBBB", 13, 10, "$"
    var_TestB5         DB "BBB Break point 5 BBBB", 13, 10, "$"
.CODE

MAIN_FROMB PROC NEAR PUBLIC
                          CALL InitializeConvertionB
                          RET
MAIN_FROMB ENDP

    ; ======= PRNC PROCEDURES =======
    ; Here the procedures that will be called from the MAIN procedure

    ; Initialize the conversion
InitializeConvertionB PROC
                          CALL InputToBinary

                          LEA  DX, var_BmessageInit
                          CALL PrintString               ; Print initialization message

                          CALL BPrintNumBinary
                          CALL BPrintNumDecimal
                          CALL BPrintNumOctal
                          CALL BPrintNumHex
                            
                          CALL PrintNewLine
                          CALL PrintNewLine
                          LEA  DX, var_BmessageFint
                          CALL PrintString_wait
                          RET
InitializeConvertionB ENDP

    ; Convert the ASCII string to a number in binary way
InputToBinary PROC

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

                          XOR  DI, DI                    ; DI = 0 → índice para BUFFER_IntputNum[DI]

    _ConvertLoop:         
                          CMP  CL, 0
                          JE   _StoreResult              ; Si ya no quedan caracteres, terminar

                          MOV  BL, [SI]                  ; BL = siguiente carácter
                          SHL  AX, 1                     ; AX = AX * 2 (desplazar a la izquierda)

                          CMP  BL, '1'
                          JNE  _SkipAdd
                          INC  AX                        ; Si el bit era 1, sumamos 1

    _SkipAdd:             
                          INC  SI                        ; siguiente carácter
                          DEC  CL
                          JMP  _ConvertLoop

    _StoreResult:         
    ; Guardamos el resultado en BUFFER_IntputNum[0..3] (solo el primer DWORD)
                          LEA  DI, BUFFER_IntputNum
                          MOV  [DI], AX

                          POP  DI
                          POP  SI
                          POP  DX
                          POP  CX
                          POP  BX
                          POP  AX
                          RET
InputToBinary ENDP

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

    ; Print the number bit by bit in binary using the BUFFER_IntputNum
BPrintNumBinary PROC

                          CALL PrintNewLine
                          LEA  DX, var_BmessageSeeNum
                          CALL PrintString
                          
                          PUSH AX
                          PUSH BX
                          PUSH CX
                          PUSH DX

                          LEA  SI, BUFFER_IntputNum
                          MOV  AX, [SI]

                          MOV  CX, 16                    ; 16 bits in AX
                          MOV  BX, AX                    ; Work with BX
                          MOV  SI, 0                     ; Flag: first '1' already printed

    _NextBit:             
                          SHL  BX, 1                     ; Move most significant bit to CF
                          JC   _Print1
                          CMP  SI, 1
                          JE   _Print0                   ; If printing started, show 0
                          LOOP _NextBit                  ; Otherwise, skip leading zeros
                          JMP  _Finish

    _Print1:              
                          MOV  DL, '1'
                          MOV  AH, 02h
                          INT  21h
                          MOV  SI, 1
                          LOOP _NextBit
                          JMP  _Finish

    _Print0:              
                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h
                          LOOP _NextBit

    _Finish:              
                          CMP  SI, 0
                          JNE  _Done                     ; If no bit was 1 (AX was 0), print a single '0'

                          MOV  DL, '0'
                          MOV  AH, 02h
                          INT  21h
    _Done:                
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

    ; Cargar el número desde BUFFER_IntputNum (DWORD pero usamos solo los primeros 16 bits)
                          LEA  SI, BUFFER_IntputNum
                          MOV  AX, [SI]                  ; AX = número a imprimir
                          XOR  CX, CX                    ; CX = contador de dígitos
                          MOV  BX, 10                    ; base decimal

    ; Si el número es 0, imprimimos '0' directamente
                          CMP  AX, 0
                          JNE  _ConvertLoop1
                          MOV  DL, '0'
                          CALL _PrintChar
                          JMP  _End

    _ConvertLoop1:        
    ; Convertir número a ASCII decimal (reversa)
    ; Guardamos los dígitos en la pila (usamos CX como contador)
                          XOR  CX, CX
    _ConvertLoopContinue: 
                          XOR  DX, DX                    ; limpiar DX para DIV
                          DIV  BX                        ; AX / 10, resto en DL
                          ADD  DL, '0'                   ; convertir a ASCII
                          PUSH DX                        ; guardar el dígito
                          INC  CX                        ; contar cuántos dígitos
                          CMP  AX, 0
                          JNE  _ConvertLoopContinue

    _PrintDigits:         
    ; Imprimir los dígitos en orden correcto
                          POP  DX
                          CALL _PrintChar
                          LOOP _PrintDigits

    _End:                 
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
                          MOV  AX, [SI]                  ; AX = number
                          XOR  CX, CX
                          MOV  BX, 8                     ; base octal

                          CMP  AX, 0
                          JNE  _OctConvertLoop
                          MOV  DL, '0'
                          CALL _PrintChar
                          JMP  _OctEnd

    _OctConvertLoop:      
                          XOR  DX, DX
                          DIV  BX                        ; AX / 8, rest in DL
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
                          MOV  AX, [SI]                  ; AX = número
                          XOR  CX, CX
                          MOV  BX, 16                    ; base hexadecimal

                          CMP  AX, 0
                          JNE  _HexConvertLoop
                          MOV  DL, '0'
                          CALL _PrintChar
                          JMP  _HexEnd

    _HexConvertLoop:      
                          XOR  DX, DX
                          DIV  BX                        ; AX / 16
    ; convertir resto en DL a carácter ASCII
                          CMP  DL, 9
                          JG   _HexLetter
                          ADD  DL, '0'
                          JMP  _HexPush
    _HexLetter:           
                          ADD  DL, 'A' - 10              ; DL = 10 → 'A', ..., 15 → 'F'
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