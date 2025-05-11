.MODEL small
.STACK 100h
.DATA
    inputBuffer  db 10, ?, 10 DUP('$')             ; Buffer para almacenar el número ingresado (máximo 10 caracteres)
    newLine      db 0Dh, 0Ah, '$'                  ; Secuencia para nueva línea (carruaje + salto de línea)
    promptInput  db 'Ingrese un numero: $'
    promptOutput db 'El numero ingresado es: $'

    PUBLIC SelectBase

.CODE
Main PROC NEAR
                 call SelectBase
Main ENDP

SelectBase PROC
    ; Inicializar segmento de datos
                 mov  ax, @data
                 mov  ds, ax

    ; Mostrar mensaje para ingresar un número
                 lea  dx, promptInput
                 call print_string

    ; Capturar número ingresado
                 lea  dx, inputBuffer
                 mov  ah, 0Ah                ; Función de DOS para entrada de cadena
                 int  21h                    ; Leer entrada desde teclado

    ; Pasar a nueva línea
                 lea  dx, newLine
                 call print_string

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