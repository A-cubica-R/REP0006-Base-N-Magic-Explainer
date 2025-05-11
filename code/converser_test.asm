.MODEL SMALL
.STACK 100h

.DATA
    msg1    DB 13,10,'Ingrese un numero (0-255): $'
    msg2    DB 13,10,'Binario: $'
    msg3    DB 13,10,'Paso: Dividir entre 2, residuo es: $'
    salto   DB 13,10,'$'
    binario DB 8 DUP('0'),'$'
    buffer  DB 3 DUP(0), '$' ; Buffer para entrada de hasta 3 dígitos
    paso    DB 'Residuo: ', '0', 13,10,'$'

.CODE
MAIN:
    MOV AX, @DATA
    MOV DS, AX

    ; Mostrar mensaje
    MOV AH, 09h
    LEA DX, msg1
    INT 21h

    ; Leer número decimal (hasta 3 caracteres)
    MOV AH, 0Ah ; Función de DOS para leer cadena
    LEA DX, buffer
    INT 21h

    ; Asegurar que el buffer esté correctamente configurado
    MOV SI, OFFSET buffer+2 ; Saltar el primer byte (longitud) y el segundo byte (carácter nulo)

    ; Convertir cadena a número
    LEA SI, buffer+1 ; Saltar el primer byte (longitud)
    XOR CX, CX       ; Inicializar CX a 0
    MOV CL, [buffer] ; Longitud de la cadena
    XOR AX, AX       ; Inicializar AX a 0

CONVERT_LOOP:
    MOV BL, [SI]     ; Leer carácter actual
    SUB BL, '0'      ; Convertir ASCII a número
    MOV CL, 10       ; Usar CL para multiplicar por 10
    MUL CL           ; AX = AX * 10
    ADD AL, BL       ; Sumar el dígito actual
    INC SI           ; Avanzar al siguiente carácter
    LOOP CONVERT_LOOP ; Usar LOOP para decrementar CX y saltar si no es cero

    ; Mostrar mensaje de binario
    MOV DX, OFFSET msg2 ; Cargar la dirección del mensaje en DX
    MOV AH, 09h         ; Función de DOS para mostrar cadena
    INT 21h             ; Llamada a la interrupción

    ; Convertir a binario y mostrar pasos
    LEA SI, binario
    MOV CL, 8        ; Número de bits
    MOV DI, 0        ; Índice

BIN_LOOP:
    SHL AL, 1        ; Mueve el bit más alto a CF
    JC SET_UNO
    MOV SI, OFFSET binario ; Cargar la dirección base de binario en SI
    ADD SI, DI       ; Calcular la dirección efectiva
    MOV BYTE PTR [SI], '0' ; Escribir '0' en la dirección calculada
    JMP SHOW_STEP

SET_UNO:
    MOV SI, OFFSET binario ; Cargar la dirección base de binario en SI
    ADD SI, DI       ; Calcular la dirección efectiva
    MOV BYTE PTR [SI], '1' ; Escribir '1' en la dirección calculada

SHOW_STEP:
    ; Mostrar paso
    MOV AH, 09h
    LEA DX, paso
    INT 21h

SIGUE:
    INC DI
    LOOP BIN_LOOP

    ; Mostrar resultado
    MOV AH, 09h
    LEA DX, binario
    INT 21h

    ; Salto de línea y salir
    MOV AH, 09h
    LEA DX, salto
    INT 21h

    MOV AH, 4Ch
    INT 21h

END MAIN