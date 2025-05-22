.MODEL SMALL
.STACK 100h
.DATA
    ; Mensajes principales
    msg_titulo      DB "CALCULADORA DE CONVERSION DE BASES", 0Dh, 0Ah, "$"
    msg_linea       DB "----------------------------------------", 0Dh, 0Ah, "$"
    msg_seleccion   DB "Seleccione la base inicial:", 0Dh, 0Ah, "$"
    msg_opciones    DB "1. Decimal", 0Dh, 0Ah
                    DB "2. Binario", 0Dh, 0Ah
                    DB "3. Octal", 0Dh, 0Ah
                    DB "4. Hexadecimal", 0Dh, 0Ah, "$"
    msg_ingreso     DB "Ingrese el numero a convertir: $"
    msg_resultado   DB 0Dh, 0Ah, "Resultados de la conversion:", 0Dh, 0Ah, "$"
    msg_decimal     DB "Decimal:   $"
    msg_binario     DB "Binario:   $"
    msg_octal       DB "Octal:     $"
    msg_hexa        DB "Hexadecimal: $"
    msg_proceso     DB 0Dh, 0Ah, "Proceso de conversion:", 0Dh, 0Ah, "$"
    msg_continuar   DB 0Dh, 0Ah, "¿Desea realizar otra conversion? (S/N): $"
    msg_error       DB 0Dh, 0Ah, "Error: Entrada invalida, intente de nuevo.$"
    msg_paso        DB "Paso $"
    msg_division    DB "Division: $"
    msg_residuo     DB " Residuo: $"
    msg_cociente    DB " Cociente: $"
    
    ; Variables para almacenar datos
    base_inicial    DB 0
    numero_decimal  DW 0
    numero_binario  DB 50 DUP(0)
    numero_octal    DB 20 DUP(0)
    numero_hexa     DB 10 DUP(0)
    buffer          DB 50 DUP(0)
    longitud_buffer DB 0
    paso_actual     DB 0

.CODE
MAIN PROC
                                      MOV  AX, @DATA
                                      MOV  DS, AX
    
    MENU:                             
    ; Limpiar pantalla
                                      MOV  AX, 0600h
                                      MOV  BH, 1Fh                              ; Fondo azul, texto blanco brillante
                                      MOV  CX, 0000h                            ; Esquina superior izquierda (0,0)
                                      MOV  DX, 184Fh                            ; Esquina inferior derecha (24,79)
                                      INT  10h
    
    ; Establecer cursor en la posición 0,0
                                      MOV  AH, 02h
                                      MOV  BH, 0
                                      MOV  DX, 0000h
                                      INT  10h
    
    ; Mostrar título con color
                                      MOV  AH, 09h
                                      LEA  DX, msg_titulo
                                      INT  21h
    
                                      LEA  DX, msg_linea
                                      INT  21h
    
                                      LEA  DX, msg_seleccion
                                      INT  21h
    
                                      LEA  DX, msg_opciones
                                      INT  21h
    
    ; Leer opción del usuario
                                      MOV  AH, 01h
                                      INT  21h
                                      SUB  AL, '0'
    
    ; Verificar si es una opción válida (1-4)
                                      CMP  AL, 1
                                      JB   OPCION_INVALIDA
                                      CMP  AL, 4
                                      JA   OPCION_INVALIDA
    
    ; Guardar base inicial
                                      MOV  base_inicial, AL
    
    ; Solicitar entrada de número
                                      MOV  AH, 09h
                                      LEA  DX, msg_ingreso
                                      INT  21h
    
    ; Leer la entrada del usuario según la base seleccionada
                                      CMP  base_inicial, 1
                                      JE   LEER_DECIMAL
                                      CMP  base_inicial, 2
                                      JE   LEER_BINARIO
                                      CMP  base_inicial, 3
                                      JE   LEER_OCTAL
                                      CMP  base_inicial, 4
                                      JE   LEER_HEXADECIMAL
    
    LEER_DECIMAL:                     
                                      CALL LEER_NUMERO_DECIMAL
                                      JMP  REALIZAR_CONVERSIONES
    
    LEER_BINARIO:                     
                                      CALL LEER_NUMERO_BINARIO
                                      JMP  REALIZAR_CONVERSIONES
    
    LEER_OCTAL:                       
                                      CALL LEER_NUMERO_OCTAL
                                      JMP  REALIZAR_CONVERSIONES
    
    LEER_HEXADECIMAL:                 
                                      CALL LEER_NUMERO_HEXADECIMAL
                                      JMP  REALIZAR_CONVERSIONES

    OPCION_INVALIDA:                  
                                      MOV  AH, 09h
                                      LEA  DX, msg_error
                                      INT  21h
    
    ; Esperar tecla
                                      MOV  AH, 01h
                                      INT  21h
    
                                      JMP  MENU

    REALIZAR_CONVERSIONES:            
    ; Mostrar resultados
                                      MOV  AH, 09h
                                      LEA  DX, msg_resultado
                                      INT  21h
    
    ; Mostrar en decimal
                                      MOV  AH, 09h
                                      LEA  DX, msg_decimal
                                      INT  21h
    
                                      MOV  AX, numero_decimal
                                      CALL MOSTRAR_DECIMAL
    
    ; Mostrar en binario
                                      MOV  AH, 09h
                                      LEA  DX, msg_binario
                                      INT  21h
    
                                      MOV  AX, numero_decimal
                                      CALL CONVERTIR_A_BINARIO
                                      CALL MOSTRAR_BINARIO
    
    ; Mostrar en octal
                                      MOV  AH, 09h
                                      LEA  DX, msg_octal
                                      INT  21h
    
                                      MOV  AX, numero_decimal
                                      CALL CONVERTIR_A_OCTAL
                                      CALL MOSTRAR_OCTAL
    
    ; Mostrar en hexadecimal
                                      MOV  AH, 09h
                                      LEA  DX, msg_hexa
                                      INT  21h
    
                                      MOV  AX, numero_decimal
                                      CALL CONVERTIR_A_HEXA
                                      CALL MOSTRAR_HEXA
    
    ; Mostrar proceso de conversión según la base de destino
                                      MOV  AH, 09h
                                      LEA  DX, msg_proceso
                                      INT  21h
    
    ; Mostrar proceso de conversión a las otras bases
                                      MOV  CL, base_inicial
                                      CMP  CL, 1
                                      JE   MOSTRAR_PROCESO_DESDE_DECIMAL
    
                                      CMP  CL, 2
                                      JE   MOSTRAR_PROCESO_DESDE_BINARIO
    
                                      CMP  CL, 3
                                      JE   MOSTRAR_PROCESO_DESDE_OCTAL
    
                                      CMP  CL, 4
                                      JE   MOSTRAR_PROCESO_DESDE_HEXADECIMAL
    
    MOSTRAR_PROCESO_DESDE_DECIMAL:    
    ; Mostrar proceso de conversión a binario
                                      MOV  AX, numero_decimal
                                      MOV  BX, 2
                                      CALL MOSTRAR_PROCESO_CONVERSION
    
    ; Mostrar proceso de conversión a octal
                                      MOV  AX, numero_decimal
                                      MOV  BX, 8
                                      CALL MOSTRAR_PROCESO_CONVERSION
    
    ; Mostrar proceso de conversión a hexadecimal
                                      MOV  AX, numero_decimal
                                      MOV  BX, 16
                                      CALL MOSTRAR_PROCESO_CONVERSION
                                      JMP  PREGUNTAR_CONTINUAR
    
    MOSTRAR_PROCESO_DESDE_BINARIO:    
    ; Ya hemos convertido a decimal, ahora mostrar las otras conversiones
                                      MOV  AX, numero_decimal
                                      MOV  BX, 8
                                      CALL MOSTRAR_PROCESO_CONVERSION
    
                                      MOV  AX, numero_decimal
                                      MOV  BX, 16
                                      CALL MOSTRAR_PROCESO_CONVERSION
                                      JMP  PREGUNTAR_CONTINUAR
    
    MOSTRAR_PROCESO_DESDE_OCTAL:      
    ; Ya hemos convertido a decimal, ahora mostrar las otras conversiones
                                      MOV  AX, numero_decimal
                                      MOV  BX, 2
                                      CALL MOSTRAR_PROCESO_CONVERSION
    
                                      MOV  AX, numero_decimal
                                      MOV  BX, 16
                                      CALL MOSTRAR_PROCESO_CONVERSION
                                      JMP  PREGUNTAR_CONTINUAR
    
    MOSTRAR_PROCESO_DESDE_HEXADECIMAL:
    ; Ya hemos convertido a decimal, ahora mostrar las otras conversiones
                                      MOV  AX, numero_decimal
                                      MOV  BX, 2
                                      CALL MOSTRAR_PROCESO_CONVERSION
    
                                      MOV  AX, numero_decimal
                                      MOV  BX, 8
                                      CALL MOSTRAR_PROCESO_CONVERSION
                                      JMP  PREGUNTAR_CONTINUAR
    
    PREGUNTAR_CONTINUAR:              
                                      MOV  AH, 09h
                                      LEA  DX, msg_continuar
                                      INT  21h
    
                                      MOV  AH, 01h
                                      INT  21h
    
                                      CMP  AL, 'S'
                                      JE   MENU
                                      CMP  AL, 's'
                                      JE   MENU
    
    ; Salir
                                      MOV  AH, 4Ch
                                      INT  21h
MAIN ENDP

    ; Procedimiento para leer un número decimal
LEER_NUMERO_DECIMAL PROC
                                      MOV  SI, 0
                                      MOV  numero_decimal, 0
    
    LEER_DEC_LOOP:                    
                                      MOV  AH, 01h
                                      INT  21h
    
                                      CMP  AL, 0Dh                              ; Enter
                                      JE   FIN_LEER_DEC
    
                                      CMP  AL, '0'
                                      JB   LEER_DEC_ERROR
                                      CMP  AL, '9'
                                      JA   LEER_DEC_ERROR
    
                                      SUB  AL, '0'
                                      MOV  BL, AL
    
    ; numero_decimal = numero_decimal * 10 + BL
                                      MOV  AX, numero_decimal
                                      MOV  CX, 10
                                      MUL  CX
                                      ADD  AL, BL
                                      MOV  numero_decimal, AX
    
                                      JMP  LEER_DEC_LOOP
    
    LEER_DEC_ERROR:                   
                                      MOV  AH, 09h
                                      LEA  DX, msg_error
                                      INT  21h
                                      JMP  LEER_DEC_LOOP
    
    FIN_LEER_DEC:                     
                                      RET
LEER_NUMERO_DECIMAL ENDP

    ; Procedimiento para leer un número binario
LEER_NUMERO_BINARIO PROC
                                      MOV  SI, 0
                                      MOV  numero_decimal, 0
    
    LEER_BIN_LOOP:                    
                                      MOV  AH, 01h
                                      INT  21h
    
                                      CMP  AL, 0Dh                              ; Enter
                                      JE   FIN_LEER_BIN
    
                                      CMP  AL, '0'
                                      JB   LEER_BIN_ERROR
                                      CMP  AL, '1'
                                      JA   LEER_BIN_ERROR
    
                                      SUB  AL, '0'
                                      MOV  BL, AL
    
    ; numero_decimal = numero_decimal * 2 + BL
                                      MOV  AX, numero_decimal
                                      MOV  CX, 2
                                      MUL  CX
                                      ADD  AL, BL
                                      MOV  numero_decimal, AX
    
                                      JMP  LEER_BIN_LOOP
    
    LEER_BIN_ERROR:                   
                                      MOV  AH, 09h
                                      LEA  DX, msg_error
                                      INT  21h
                                      JMP  LEER_BIN_LOOP
    
    FIN_LEER_BIN:                     
                                      RET
LEER_NUMERO_BINARIO ENDP

    ; Procedimiento para leer un número octal
LEER_NUMERO_OCTAL PROC
                                      MOV  SI, 0
                                      MOV  numero_decimal, 0
    
    LEER_OCT_LOOP:                    
                                      MOV  AH, 01h
                                      INT  21h
    
                                      CMP  AL, 0Dh                              ; Enter
                                      JE   FIN_LEER_OCT
    
                                      CMP  AL, '0'
                                      JB   LEER_OCT_ERROR
                                      CMP  AL, '7'
                                      JA   LEER_OCT_ERROR
    
                                      SUB  AL, '0'
                                      MOV  BL, AL
    
    ; numero_decimal = numero_decimal * 8 + BL
                                      MOV  AX, numero_decimal
                                      MOV  CX, 8
                                      MUL  CX
                                      ADD  AL, BL
                                      MOV  numero_decimal, AX
    
                                      JMP  LEER_OCT_LOOP
    
    LEER_OCT_ERROR:                   
                                      MOV  AH, 09h
                                      LEA  DX, msg_error
                                      INT  21h
                                      JMP  LEER_OCT_LOOP
    
    FIN_LEER_OCT:                     
                                      RET
LEER_NUMERO_OCTAL ENDP

    ; Procedimiento para leer un número hexadecimal
LEER_NUMERO_HEXADECIMAL PROC
                                      MOV  SI, 0
                                      MOV  numero_decimal, 0
    
    LEER_HEX_LOOP:                    
                                      MOV  AH, 01h
                                      INT  21h
    
                                      CMP  AL, 0Dh                              ; Enter
                                      JE   FIN_LEER_HEX
    
                                      CMP  AL, '0'
                                      JB   LEER_HEX_ERROR
                                      CMP  AL, '9'
                                      JBE  LEER_HEX_DIGITO
    
                                      CMP  AL, 'A'
                                      JB   LEER_HEX_ERROR
                                      CMP  AL, 'F'
                                      JBE  LEER_HEX_LETRA_MAYUS
    
                                      CMP  AL, 'a'
                                      JB   LEER_HEX_ERROR
                                      CMP  AL, 'f'
                                      JBE  LEER_HEX_LETRA_MINUS
    
                                      JMP  LEER_HEX_ERROR
    
    LEER_HEX_DIGITO:                  
                                      SUB  AL, '0'
                                      JMP  LEER_HEX_CONVERTIR
    
    LEER_HEX_LETRA_MAYUS:             
                                      SUB  AL, 'A'
                                      ADD  AL, 10
                                      JMP  LEER_HEX_CONVERTIR
    
    LEER_HEX_LETRA_MINUS:             
                                      SUB  AL, 'a'
                                      ADD  AL, 10
    
    LEER_HEX_CONVERTIR:               
                                      MOV  BL, AL
    
    ; numero_decimal = numero_decimal * 16 + BL
                                      MOV  AX, numero_decimal
                                      MOV  CX, 16
                                      MUL  CX
                                      ADD  AL, BL
                                      MOV  numero_decimal, AX
    
                                      JMP  LEER_HEX_LOOP
    
    LEER_HEX_ERROR:                   
                                      MOV  AH, 09h
                                      LEA  DX, msg_error
                                      INT  21h
                                      JMP  LEER_HEX_LOOP
    
    FIN_LEER_HEX:                     
                                      RET
LEER_NUMERO_HEXADECIMAL ENDP

    ; Procedimiento para mostrar un número decimal
MOSTRAR_DECIMAL PROC
                                      MOV  CX, 10000                            ; Divisor inicial (asumimos números menores a 10000)
                                      MOV  BX, 0                                ; Flag para indicar si ya hemos empezado a mostrar dígitos
    
    MOSTRAR_DEC_LOOP:                 
                                      MOV  DX, 0
                                      DIV  CX
    
                                      CMP  AL, 0
                                      JNE  MOSTRAR_DEC_DIGITO
                                      CMP  BX, 1
                                      JE   MOSTRAR_DEC_DIGITO
                                      CMP  CX, 1
                                      JE   MOSTRAR_DEC_DIGITO
                                      JMP  MOSTRAR_DEC_SIGUIENTE
    
    MOSTRAR_DEC_DIGITO:               
                                      MOV  BX, 1                                ; Indicar que hemos empezado a mostrar dígitos
                                      ADD  AL, '0'
    
                                      PUSH DX
                                      MOV  DL, AL
                                      MOV  AH, 02h
                                      INT  21h
                                      POP  DX
    
    MOSTRAR_DEC_SIGUIENTE:            
                                      MOV  AX, DX
    
                                      PUSH DX
                                      MOV  DX, 0
                                      MOV  BX, 10
                                      DIV  BX
                                      MOV  CX, AX
                                      POP  DX
    
                                      CMP  CX, 0
                                      JNE  MOSTRAR_DEC_LOOP
    
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
                                      RET
MOSTRAR_DECIMAL ENDP

    ; Procedimiento para convertir a binario
CONVERTIR_A_BINARIO PROC
                                      MOV  CX, 0                                ; Contador para los dígitos
                                      MOV  BX, 2                                ; Base (binario)
    
    CONV_BIN_LOOP:                    
                                      MOV  DX, 0
                                      DIV  BX
    
                                      ADD  DL, '0'
                                      PUSH DX
                                      INC  CX
    
                                      CMP  AX, 0
                                      JNE  CONV_BIN_LOOP
    
                                      MOV  SI, 0
    
    CONV_BIN_GUARDAR:                 
                                      POP  DX
                                      MOV  numero_binario[SI], DL
                                      INC  SI
                                      LOOP CONV_BIN_GUARDAR
    
                                      MOV  numero_binario[SI], '$'
    
                                      RET
CONVERTIR_A_BINARIO ENDP

    ; Procedimiento para mostrar un número binario
MOSTRAR_BINARIO PROC
                                      MOV  AH, 09h
                                      LEA  DX, numero_binario
                                      INT  21h
    
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
                                      RET
MOSTRAR_BINARIO ENDP

    ; Procedimiento para convertir a octal
CONVERTIR_A_OCTAL PROC
                                      MOV  CX, 0                                ; Contador para los dígitos
                                      MOV  BX, 8                                ; Base (octal)
    
    CONV_OCT_LOOP:                    
                                      MOV  DX, 0
                                      DIV  BX
    
                                      ADD  DL, '0'
                                      PUSH DX
                                      INC  CX
    
                                      CMP  AX, 0
                                      JNE  CONV_OCT_LOOP
    
                                      MOV  SI, 0
    
    CONV_OCT_GUARDAR:                 
                                      POP  DX
                                      MOV  numero_octal[SI], DL
                                      INC  SI
                                      LOOP CONV_OCT_GUARDAR
    
                                      MOV  numero_octal[SI], '$'
    
                                      RET
CONVERTIR_A_OCTAL ENDP

    ; Procedimiento para mostrar un número octal
MOSTRAR_OCTAL PROC
                                      MOV  AH, 09h
                                      LEA  DX, numero_octal
                                      INT  21h
    
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
                                      RET
MOSTRAR_OCTAL ENDP

    ; Procedimiento para convertir a hexadecimal
CONVERTIR_A_HEXA PROC
                                      MOV  CX, 0                                ; Contador para los dígitos
                                      MOV  BX, 16                               ; Base (hexadecimal)
    
    CONV_HEX_LOOP:                    
                                      MOV  DX, 0
                                      DIV  BX
    
                                      CMP  DL, 10
                                      JB   CONV_HEX_DIGITO
    
                                      ADD  DL, 'A' - 10
                                      JMP  CONV_HEX_GUARDAR_TEMP
    
    CONV_HEX_DIGITO:                  
                                      ADD  DL, '0'
    
    CONV_HEX_GUARDAR_TEMP:            
                                      PUSH DX
                                      INC  CX
    
                                      CMP  AX, 0
                                      JNE  CONV_HEX_LOOP
    
                                      MOV  SI, 0
    
    CONV_HEX_GUARDAR:                 
                                      POP  DX
                                      MOV  numero_hexa[SI], DL
                                      INC  SI
                                      LOOP CONV_HEX_GUARDAR
    
                                      MOV  numero_hexa[SI], '$'
    
                                      RET
CONVERTIR_A_HEXA ENDP

    ; Procedimiento para mostrar un número hexadecimal
MOSTRAR_HEXA PROC
                                      MOV  AH, 09h
                                      LEA  DX, numero_hexa
                                      INT  21h
    
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
                                      RET
MOSTRAR_HEXA ENDP

    ; Procedimiento para mostrar el proceso de conversión
MOSTRAR_PROCESO_CONVERSION PROC
    ; AX: Número a convertir
    ; BX: Base de destino
    
                                      MOV  paso_actual, 1
                                      MOV  CX, 0                                ; Contador para los dígitos
    
    ; Mostrar el proceso de división sucesiva
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
    ; Mostrar mensaje de base de destino
                                      MOV  AH, 02h
                                      MOV  DL, 'A'
                                      INT  21h
                                      MOV  DL, ' '
                                      INT  21h
    
                                      CMP  BX, 2
                                      JE   MOSTRAR_PROC_BASE_BIN
                                      CMP  BX, 8
                                      JE   MOSTRAR_PROC_BASE_OCT
                                      CMP  BX, 16
                                      JE   MOSTRAR_PROC_BASE_HEX
    
    MOSTRAR_PROC_BASE_BIN:            
                                      MOV  AH, 02h
                                      MOV  DL, 'B'
                                      INT  21h
                                      MOV  DL, 'i'
                                      INT  21h
                                      MOV  DL, 'n'
                                      INT  21h
                                      MOV  DL, 'a'
                                      INT  21h
                                      MOV  DL, 'r'
                                      INT  21h
                                      MOV  DL, 'i'
                                      INT  21h
                                      MOV  DL, 'o'
                                      INT  21h
                                      JMP  MOSTRAR_PROC_DIVISIONES
    
    MOSTRAR_PROC_BASE_OCT:            
                                      MOV  AH, 02h
                                      MOV  DL, 'O'
                                      INT  21h
                                      MOV  DL, 'c'
                                      INT  21h
                                      MOV  DL, 't'
                                      INT  21h
                                      MOV  DL, 'a'
                                      INT  21h
                                      MOV  DL, 'l'
                                      INT  21h
                                      JMP  MOSTRAR_PROC_DIVISIONES
    
    MOSTRAR_PROC_BASE_HEX:            
                                      MOV  AH, 02h
                                      MOV  DL, 'H'
                                      INT  21h
                                      MOV  DL, 'e'
                                      INT  21h
                                      MOV  DL, 'x'
                                      INT  21h
                                      MOV  DL, 'a'
                                      INT  21h
                                      MOV  DL, 'd'
                                      INT  21h
                                      MOV  DL, 'e'
                                      INT  21h
                                      MOV  DL, 'c'
                                      INT  21h
                                      MOV  DL, 'i'
                                      INT  21h
                                      MOV  DL, 'm'
                                      INT  21h
                                      MOV  DL, 'a'
                                      INT  21h
                                      MOV  DL, 'l'
                                      INT  21h
    
    MOSTRAR_PROC_DIVISIONES:          
                                      MOV  AH, 02h
                                      MOV  DL, ':'
                                      INT  21h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
    ; Guardar el número original
                                      PUSH AX
    
    MOSTRAR_PROC_DIVISION_LOOP:       
                                      MOV  DX, 0
                                      DIV  BX
    
    ; Guardar el cociente
                                      PUSH AX
    
    ; Mostrar el paso actual
                                      MOV  AH, 09h
                                      LEA  DX, msg_paso
                                      INT  21h
    
                                      MOV  DL, paso_actual
                                      ADD  DL, '0'
                                      MOV  AH, 02h
                                      INT  21h
    
                                      MOV  DL, ':'
                                      INT  21h
                                      MOV  DL, ' '
                                      INT  21h
    
    ; Mostrar la división
                                      MOV  AH, 09h
                                      LEA  DX, msg_division
                                      INT  21h
    
    ; Recuperar y mostrar el número original
                                      POP  AX
                                      PUSH AX
    
                                      CALL MOSTRAR_DECIMAL_SIMPLE
    
                                      MOV  AH, 02h
                                      MOV  DL, ' '
                                      INT  21h
                                      MOV  DL, '/'
                                      INT  21h
                                      MOV  DL, ' '
                                      INT  21h
    
    ; Mostrar la base
                                      MOV  AX, BX
                                      CALL MOSTRAR_DECIMAL_SIMPLE
    
    ; Mostrar el cociente
                                      MOV  AH, 09h
                                      LEA  DX, msg_cociente
                                      INT  21h
    
                                      POP  AX
                                      PUSH AX
                                      CALL MOSTRAR_DECIMAL_SIMPLE
    
    ; Mostrar el residuo
                                      MOV  AH, 09h
                                      LEA  DX, msg_residuo
                                      INT  21h
    
                                      POP  AX
                                      MOV  AX, DX
                                      CALL MOSTRAR_DECIMAL_SIMPLE
    
    ; Salto de línea
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
    ; Incrementar contador de pasos
                                      INC  paso_actual
    
    ; Recuperar el cociente
                                      POP  AX
    
    ; Ver si hemos terminado
                                      CMP  AX, 0
                                      JNE  MOSTRAR_PROC_DIVISION_LOOP
    
    ; Salto de línea adicional
                                      MOV  AH, 02h
                                      MOV  DL, 0Dh
                                      INT  21h
                                      MOV  DL, 0Ah
                                      INT  21h
    
                                      RET
MOSTRAR_PROCESO_CONVERSION ENDP

    ; Procedimiento auxiliar para mostrar un número decimal simple
MOSTRAR_DECIMAL_SIMPLE PROC
                                      PUSH BX
                                      PUSH CX
                                      PUSH DX
    
                                      MOV  CX, 10000                            ; Divisor inicial (asumimos números menores a 10000)
                                      MOV  BX, 0                                ; Flag para indicar si ya hemos empezado a mostrar dígitos
    
    MOSTRAR_DEC_SIMPLE_LOOP:          
                                      MOV  DX, 0
                                      DIV  CX
    
                                      CMP  AL, 0
                                      JNE  MOSTRAR_DEC_SIMPLE_DIGITO
                                      CMP  BX, 1
                                      JE   MOSTRAR_DEC_SIMPLE_DIGITO
                                      CMP  CX, 1
                                      JE   MOSTRAR_DEC_SIMPLE_DIGITO
                                      JMP  MOSTRAR_DEC_SIMPLE_SIGUIENTE
    
    MOSTRAR_DEC_SIMPLE_DIGITO:        
                                      MOV  BX, 1                                ; Indicar que hemos empezado a mostrar dígitos
                                      ADD  AL, '0'
    
                                      PUSH DX
                                      MOV  DL, AL
                                      MOV  AH, 02h
                                      INT  21h
                                      POP  DX
    
    MOSTRAR_DEC_SIMPLE_SIGUIENTE:     
                                      MOV  AX, DX
    
                                      PUSH DX
                                      MOV  DX, 0
                                      MOV  BX, 10
                                      DIV  BX
                                      MOV  CX, AX
                                      POP  DX
    
                                      CMP  CX, 0
                                      JNE  MOSTRAR_DEC_SIMPLE_LOOP
    
                                      POP  DX
                                      POP  CX
                                      POP  BX
    
                                      RET
MOSTRAR_DECIMAL_SIMPLE ENDP

END MAIN