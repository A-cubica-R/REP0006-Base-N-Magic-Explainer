.MODEL SMALL
.STACK 100h

.DATA
    ; Mensajes para la interfaz interactiva
    titulo      DB "CONVERSOR DE DECIMAL A BINARIO", 0Dh, 0Ah, "$"
    msg_input   DB 0Dh, 0Ah, "Ingrese un numero decimal (0-65535): $"
    msg_result  DB 0Dh, 0Ah, "El numero en binario es: $"
    msg_process DB 0Dh, 0Ah, "Proceso de conversion:", 0Dh, 0Ah, "$"
    msg_step    DB "Paso $"
    msg_divide  DB ": Dividir $"
    msg_by_two  DB " entre 2, cociente = $"
    msg_rem     DB ", residuo = $"
    msg_continue DB 0Dh, 0Ah, 0Dh, 0Ah, "Presione cualquier tecla para continuar...$"
    msg_exit    DB 0Dh, 0Ah, "Gracias por usar el conversor!", 0Dh, 0Ah, "$"
    
    ; Variables para la conversión
    numero      DW 0       ; Número decimal ingresado
    binario     DB 16 DUP(0) ; Arreglo para almacenar los dígitos binarios
    contador    DB 0       ; Contador para los bits
    paso        DB 0       ; Contador para mostrar pasos
    buffer      DB 6 DUP(0) ; Buffer para entrada

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Limpiar pantalla
    MOV AX, 0600h    ; Función 06h para desplazar pantalla + AL=00h para limpiar
    MOV BH, 1Fh      ; Atributo: fondo azul, texto blanco brillante
    MOV CX, 0000h    ; Desde esquina superior izquierda (fila 0, columna 0)
    MOV DX, 184Fh    ; Hasta esquina inferior derecha (fila 24, columna 79)
    INT 10h
    
    ; Posicionar cursor al inicio
    MOV AH, 02h
    MOV BH, 00h
    MOV DX, 0000h
    INT 10h
    
    ; Mostrar título
    MOV AH, 09h
    LEA DX, titulo
    INT 21h
    
    ; Solicitar número
    MOV AH, 09h
    LEA DX, msg_input
    INT 21h
    
    ; Leer entrada como cadena
    MOV AH, 0Ah
    LEA DX, buffer
    MOV buffer, 5     ; Máximo 5 caracteres (65535 tiene 5 dígitos)
    INT 21h
    
    ; Convertir string a número
    XOR AX, AX        ; Limpiar AX
    MOV CL, buffer+1  ; Longitud real leída
    XOR CH, CH        ; CH = 0 para contador
    LEA SI, buffer+2  ; Dirección del primer caracter
    
CONVERT_LOOP:
    XOR BX, BX
    MOV BL, [SI]      ; Obtener dígito ASCII
    SUB BL, '0'       ; Convertir ASCII a valor numérico
    
    ; Multiplicar AX por 10 y sumar BL
    PUSH BX
    MOV BX, 10
    MUL BX           ; AX = AX * 10
    POP BX
    ADD AX, BX       ; AX = AX + BL
    
    INC SI           ; Siguiente caracter
    LOOP CONVERT_LOOP
    
    ; Guardar número en variable
    MOV numero, AX
    
    ; Mostrar mensaje de proceso
    MOV AH, 09h
    LEA DX, msg_process
    INT 21h
    
    ; Proceso de conversión
    XOR CX, CX        ; Limpiar contador
    MOV AX, numero    ; Cargar número en AX
    
CONVERSION:
    XOR DX, DX        ; Limpiar DX para la división
    MOV BX, 2         ; Divisor = 2
    DIV BX            ; AX = DX:AX / BX, DX = DX:AX % BX
    
    ; Incrementar contador de pasos
    INC paso
    
    ; Mostrar paso actual
    MOV AH, 09h
    LEA DX, msg_step
    INT 21h
    
    MOV BL, paso
    XOR BH, BH
    CALL PRINT_NUM   ; Mostrar número de paso
    
    ; Mostrar división
    MOV AH, 09h
    LEA DX, msg_divide
    INT 21h
    
    PUSH AX          ; Guardar cociente
    MOV AX, numero   ; Cargar número original o el cociente anterior
    CALL PRINT_NUM   ; Imprimir número a dividir
    POP AX           ; Recuperar cociente
    
    ; Mostrar cociente
    MOV AH, 09h
    LEA DX, msg_by_two
    INT 21h
    
    PUSH AX          ; Guardar cociente
    MOV AX, AX       ; Mover cociente a AX para imprimirlo
    CALL PRINT_NUM   ; Imprimir cociente
    POP AX           ; Recuperar cociente
    
    ; Mostrar residuo
    PUSH AX          ; Guardar cociente
    MOV AH, 09h
    LEA DX, msg_rem
    INT 21h
    
    MOV AX, DX       ; Mover residuo a AX para imprimirlo
    CALL PRINT_NUM   ; Imprimir residuo
    POP AX           ; Recuperar cociente
    
    ; Guardar residuo en arreglo de binario
    PUSH AX          ; Guardar cociente
    MOV BX, CX       ; Índice = contador
    MOV binario[BX], DL ; Guardar residuo
    INC CX           ; Incrementar contador
    POP AX           ; Recuperar cociente
    
    ; Actualizar número para siguiente iteración
    MOV numero, AX
    
    ; Si el cociente no es cero, continuar convirtiendo
    CMP AX, 0
    JNE CONVERSION
    
    ; Mostrar resultado
    MOV AH, 09h
    LEA DX, msg_result
    INT 21h
    
    ; Imprimir binario (en orden inverso)
    MOV contador, CL  ; Guardar cantidad de bits
    
PRINT_BINARY:
    DEC CX
    MOV SI, CX
    MOV DL, binario[SI]  ; Obtener bit
    ADD DL, '0'          ; Convertir a ASCII
    MOV AH, 02h
    INT 21h
    
    CMP CX, 0
    JNE PRINT_BINARY
    
    ; Mensaje para continuar
    MOV AH, 09h
    LEA DX, msg_continue
    INT 21h
    
    ; Esperar tecla
    MOV AH, 01h
    INT 21h
    
    ; Mensaje de salida
    MOV AH, 09h
    LEA DX, msg_exit
    INT 21h
    
    ; Salir al DOS
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; Procedimiento para imprimir un número en decimal
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR CX, CX      ; Contador de dígitos = 0
    MOV BX, 10      ; Divisor = 10
    
DIGIT_LOOP:
    XOR DX, DX      ; Limpiar DX
    DIV BX          ; AX = DX:AX / 10, DX = DX:AX % 10
    
    ; Convertir residuo a ASCII y apilar
    ADD DL, '0'
    PUSH DX
    INC CX
    
    ; Si cociente != 0, seguir
    CMP AX, 0
    JNE DIGIT_LOOP
    
PRINT_LOOP:
    ; Desapilar y mostrar dígitos
    POP DX
    MOV AH, 02h
    INT 21h
    LOOP PRINT_LOOP
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN