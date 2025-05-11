.MODEL small
.STACK 100h
PUBLIC SelectBase
.DATA
    functionInput   db "Bienvenido, seleccione la base desde la que va a trabajar:", 13, 10, "$"
    functionOutput  db "Seleccione la base de destino:", 13, 10, "$"
    basesN          db "1 - Binario", 13, 10, "2 - Octal", 13, 10, "3 - Decimal", 13, 10, "4 - Decimal", 13, 10, "$"
    promptOutput    db 'El numero ingresado es: $'
    inputBuffer     db 10, ?, 10 DUP('$')                                                                               ;Base de entrada
    outputBuffer    db 10, ?, 10 DUP('$')                                                                               ;Base de salida
    numberToConvert db 10, ?, 10 DUP('$')                                                                               ;Numero a convertir
    newLine         db 0Dh, 0Ah, '$'

.CODE
Main PROC NEAR
                 call SelectBase
Main ENDP

SelectBase PROC
    ; Inicializar segmento de datos
                 mov  ax, @data
                 mov  ds, ax

    ; Mostrar mensaje para ingresar un número
                 lea  dx, functionInput
                 call print_string
                 lea  dx, basesN
                 call print_string
                 lea  dx, inputBuffer
                 mov  ah, 0Ah                ; Función de DOS para entrada de cadena
                 int  21h                    ; Leer entrada desde teclado

    ; Pasar a nueva línea
                 lea  dx, functionOutput
                 call print_string
                 lea  dx, basesN
                 call print_string
                 lea  dx, outputBuffer
                 mov  ah, 0Ah                ; Función de DOS para entrada de cadena
                 int  21h                    ; Leer entrada desde teclado

    ; Mostrar mensaje con el resultado
                 lea  dx, promptOutput
                 call print_string

    ; Imprimir la cadena ingresada
                 lea  dx, inputBuffer + 2    ; La entrada comienza después de los primeros 2 bytes
                 call print_string

    ; Esperar a que el usuario presione una tecla para finalizar
                 mov  ah, 07h
                 int  21h

                 ret
SelectBase ENDP

    ; ==============================
    ; Subrutina - Imprimir Cadena
print_string PROC
                 mov  ah, 09h                ; Función de DOS para imprimir cadena
                 int  21h
                 ret
print_string ENDP

END Main