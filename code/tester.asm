.MODEL SMALL
.STACK 100h
.DATA
    mensaje_input     DB 'Ingrese un numero binario (max 16 bits): $'
    mensaje_opcion    DB 0Dh, 0Ah, 'Elija base de conversion:', 0Dh, 0Ah
                      DB '1. Decimal', 0Dh, 0Ah
                      DB '2. Octal', 0Dh, 0Ah
                      DB '3. Hexadecimal', 0Dh, 0Ah
                      DB 'Opcion: $'
    mensaje_decimal   DB 0Dh, 0Ah, 'El valor decimal es: $'
    mensaje_octal     DB 0Dh, 0Ah, 'El valor octal es: $'
    mensaje_hexa      DB 0Dh, 0Ah, 'El valor hexadecimal es: $'
    mensaje_error     DB 0Dh, 0Ah, 'Opcion invalida. Usando decimal por defecto.$'
    buffer            DB 17 DUP(0)   ; Buffer para entrada (16 bits + terminator)
    resultado         DW 0           ; Para almacenar el resultado
    opcion_conversion DB 0           ; Opción elegida por el usuario

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Mostrar mensaje para entrada
    LEA DX, mensaje_input
    MOV AH, 9
    INT 21h
    
    ; Leer cadena binaria
    LEA DX, buffer
    MOV AH, 0Ah
    MOV buffer, 16        ; Máximo 16 caracteres (16 bits)
    INT 21h
    
    ; Llamar a la rutina de conversión 
    CALL BinarioADecimal
    
    ; Mostrar opciones de conversión
    LEA DX, mensaje_opcion
    MOV AH, 9
    INT 21h
    
    ; Leer opción del usuario
    MOV AH, 1
    INT 21h
    SUB AL, '0'           ; Convertir de ASCII a valor numérico
    MOV opcion_conversion, AL
    
    ; Validar opción y mostrar resultado
    CMP AL, 1
    JE MostrarEnDecimal
    CMP AL, 2
    JE MostrarEnOctal
    CMP AL, 3
    JE MostrarEnHexa
    
    ; Si llega aquí, la opción es inválida
    LEA DX, mensaje_error
    MOV AH, 9
    INT 21h
    
MostrarEnDecimal:
    ; Mostrar mensaje del resultado decimal
    LEA DX, mensaje_decimal
    MOV AH, 9
    INT 21h
    
    ; Mostrar el resultado en decimal
    MOV AX, resultado
    MOV BX, 10            ; Base decimal
    CALL MostrarNumero
    JMP Salir
    
MostrarEnOctal:
    ; Mostrar mensaje del resultado octal
    LEA DX, mensaje_octal
    MOV AH, 9
    INT 21h
    
    ; Mostrar el resultado en octal
    MOV AX, resultado
    MOV BX, 8             ; Base octal
    CALL MostrarNumero
    JMP Salir
    
MostrarEnHexa:
    ; Mostrar mensaje del resultado hexadecimal
    LEA DX, mensaje_hexa
    MOV AH, 9
    INT 21h
    
    ; Mostrar el resultado en hexadecimal
    MOV AX, resultado
    MOV BX, 16            ; Base hexadecimal
    CALL MostrarNumero
    
Salir:
    ; Salir al DOS
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; Procedimiento para convertir binario a decimal
BinarioADecimal PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    MOV SI, 2             ; SI apunta al primer carácter después del tamaño en el buffer
    MOV CL, buffer[1]     ; CL = cantidad de caracteres leídos
    MOV CH, 0             ; CH = 0 para usar CX como contador
    MOV BX, 0             ; BX = resultado acumulado inicializado en 0
    
ConversionLoop:
    CMP CX, 0             ; Verificar si quedan caracteres
    JE FinConversion      ; Terminar si no quedan caracteres
    
    MOV AX, BX            ; Mover resultado actual a AX
    SHL BX, 1             ; Multiplicar resultado por 2 (desplazar a la izquierda)
    
    MOV AL, buffer[SI]    ; Cargar carácter actual
    INC SI                ; Avanzar al siguiente carácter
    DEC CX                ; Decrementar contador
    
    CMP AL, '0'           ; Verificar si es '0'
    JE ConversionLoop     ; Si es '0', no sumar nada
    
    CMP AL, '1'           ; Verificar si es '1'
    JNE ErrorEntrada      ; Si no es ni '0' ni '1', es un error
    
    INC BX                ; Si es '1', incrementar el resultado
    JMP ConversionLoop    ; Continuar con siguiente dígito

ErrorEntrada:
    ; En caso de error, simplemente establecer resultado a 0
    MOV BX, 0
    
FinConversion:
    MOV resultado, BX     ; Guardar resultado
    
    POP SI
    POP CX
    POP BX
    POP AX
    RET
BinarioADecimal ENDP

; Procedimiento para mostrar un número en cualquier base (decimal, octal o hexadecimal)
MostrarNumero PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; BX ya contiene la base (10, 8 o 16)
    MOV CX, 0             ; Contador de dígitos
    
    ; Verificar si el número es cero
    CMP AX, 0
    JNE DescomponerDigitos
    
    ; Si es cero, mostrar '0' directamente
    MOV DL, '0'
    MOV AH, 2
    INT 21h
    JMP FinMostrarNumero
    
DescomponerDigitos:
    ; Dividir AX por la base (en BX)
    MOV DX, 0             ; Limpiar DX para división
    DIV BX                ; AX = AX / BX, DX = AX % BX
    
    ; Apilar el resto (dígito)
    PUSH DX
    INC CX                ; Incrementar contador de dígitos
    
    ; Si el cociente no es cero, continuar
    CMP AX, 0
    JNE DescomponerDigitos
    
MostrarDigitos:
    ; Desapilar y mostrar dígitos
    POP DX
    CMP DL, 10            ; Comprobar si es dígito > 9 (para hex)
    JB DigitoNumerico
    
    ; Es una letra A-F
    ADD DL, 'A' - 10      ; Convertir a ASCII (A-F)
    JMP MostrarCaracter
    
DigitoNumerico:
    ADD DL, '0'           ; Convertir a ASCII (0-9)
    
MostrarCaracter:
    MOV AH, 2
    INT 21h
    LOOP MostrarDigitos
    
FinMostrarNumero:
    ; Salto de línea
    MOV DL, 0Dh
    MOV AH, 2
    INT 21h
    MOV DL, 0Ah
    INT 21h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
MostrarNumero ENDP

END MAIN