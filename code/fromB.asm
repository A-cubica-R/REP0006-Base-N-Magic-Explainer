; Updated fromB.asm to work with cselect.asm
.MODEL SMALL
.STACK 100h

PUBLIC BToOct
PUBLIC BToDec
PUBLIC BToHex
PUBLIC BToBin

EXTERN bufResult:BYTE   ; 'cselect.asm' result buffer

.DATA
    msgInit         db 'Conversion initialized', 13,10,'$'
    msgBeginValue   db 'Beginning with value of: $'                               ; Nuevo mensaje
    msgNotAvailable db 'Conversion not available', 13,10,'$'
    msgEnd          db 'Conversion finished, press any key to exit', 13,10,'$'
    tempBuffer      db 17 dup(0),'$'
    valueBuffer     db 17 dup(0),'$'                                              ; Buffer para mostrar el valor inicial
    debugValue      db 'AX value: $'                                              ; Para depuración

.CODE

    ; This procedure is not being used as an entry point since cselect.asm is now the main file
Start PROC
                    mov  ax, @data
                    mov  ds, ax
                    call ClearScreen
                    call PrintInit
                    call PrintEndg
                    mov  ah, 4Ch                       ; Terminate program (DOS interrupt)
                    int  21h
Start ENDP

    ; Convert binary in AX to binary (essentially passing through the value)
BToBin PROC
                    push ax
                    call PrintInit
                    pop  ax
                    push ax                            ; Guardar AX para imprimirlo
                    call PrintBeginValue
                    pop  ax                            ; Restaurar AX para la conversión
                    mov  bx, 2                         ; Base 2 (binary)
                    call ConvertToBase
    
                    ret                                ; Return to caller
BToBin ENDP

    ; Convert binary in AX to octal
BToOct PROC
                    push ax
                    call PrintInit
                    pop  ax
                    push ax                            ; Guardar AX para imprimirlo
                    call PrintBeginValue
                    pop  ax                            ; Restaurar AX para la conversión
                    mov  bx, 8
                    call ConvertToBase
    
                    ret                                ; Return to caller
BToOct ENDP

    ; Convert binary in AX to decimal
BToDec PROC
                    push ax                            ; Save input value
                    call PrintInit
                    pop  ax                            ; Restore input value
                   
                    push ax                            ; Guardar AX para imprimirlo
                    call PrintBeginValue
                    pop  ax                            ; Restaurar AX para la conversión
    
    ; Convert the binary value in AX to decimal
                    mov  bx, 10                        ; Base 10 (decimal)
                    call ConvertToBase
    
                    ret                                ; Return to caller
BToDec ENDP

    ; Convert binary in AX to hexadecimal
BToHex PROC
                    push ax                            ; Save input value
                    call PrintInit
                    pop  ax                            ; Restore input value
                   
                    push ax                            ; Guardar AX para imprimirlo
                    call PrintBeginValue
                    pop  ax                            ; Restaurar AX para la conversión
    
    ; Convert the binary value in AX to hexadecimal
                    mov  bx, 16                        ; Base 16 (hexadecimal)
                    call ConvertToBase
    
                    ret                                ; Return to caller
BToHex ENDP

    ; ===================== CONVERSION PROCEDURES =====================

    ; Convert number in AX to specified base (in BX) and store it in bufResult
ConvertToBase PROC
                    push ax
                    push bx
                    push cx
                    push dx
                    push si
                    push di
                
                    mov  di, OFFSET bufResult          ; Point to result buffer
                    mov  byte ptr [di], '$'            ; Inicializar con terminador de cadena
                    mov  cx, 0                         ; Initialize digit counter
                
    ; Special case for zero
                    cmp  ax, 0
                    jne  convert_loop
                    mov  byte ptr [di], '0'            ; Store '0'
                    mov  byte ptr [di+1], '$'          ; Terminate string
                    jmp  done_convert                  ; Skip conversion
                
    ; Convert number to string (digits stored in reverse order)
    convert_loop:   
                    cmp  ax, 0                         ; Check if number is zero
                    je   reverse_digits                ; If yes, finish conversion
                
                    xor  dx, dx                        ; Clear DX for division
                    div  bx                            ; Divide AX by base, result in AX, remainder in DX
                
    ; Convert remainder to ASCII
                    cmp  dx, 10                        ; Check if digit >= 10 (for hex)
                    jb   digit_0_9
                
    ; Handle A-F for hex
                    add  dl, 'A' - 10                  ; Convert to A-F
                    jmp  store_digit
                
    digit_0_9:      
                    add  dl, '0'                       ; Convert to 0-9
                
    store_digit:    
                    mov  [tempBuffer + cx], dl         ; Store digit in temporary buffer
                    inc  cx                            ; Increment digit count
                    jmp  convert_loop                  ; Continue conversion
                
    ; Reverse the digits into the result buffer
    reverse_digits: 
                    mov  si, 0                         ; Initialize index for result buffer
                
    ; Handle zero digits case
                    cmp  cx, 0
                    jne  rev_loop
                    mov  byte ptr [di], '0'            ; Store '0'
                    mov  byte ptr [di+1], '$'          ; Terminate string
                    jmp  done_convert
                
    rev_loop:       
                    dec  cx                            ; Point to last digit
                    mov  al, [tempBuffer + cx]         ; Get digit from end of temp buffer
                    mov  bx, di                        ; Use BX as a temporary register for address calculation
                    add  bx, si                        ; para no usar [di + si], al
                    mov  [bx], al
                    inc  si                            ; Move to next position in result
                    cmp  cx, 0                         ; Check if we've processed all digits
                    jne  rev_loop                      ; If not, continue
                
    ; Add string terminator
                    mov  bx, di
                    add  bx, si
                    mov  byte ptr [bx], '$'
                
    done_convert:   
                    pop  di
                    pop  si
                    pop  dx
                    pop  cx
                    pop  bx
                    pop  ax
                    call PrintEndg
                    ret
ConvertToBase ENDP

    ; ===================== AUX METHODS =====================

ClearScreen PROC
                    mov  ah, 0                         ; Set video mode
                    mov  al, 3                         ; 80x25 text mode
                    int  10h
                    ret
ClearScreen ENDP

PrintInit PROC
                    mov  dx, OFFSET msgInit
                    mov  ah, 09h
                    int  21h
                    ret
PrintInit ENDP

    ; Procedimiento para imprimir el valor con el que se inicia la conversión
PrintBeginValue PROC
                    push ax
                    push bx
                    push cx
                    push dx
                    push si
                    push di
                   
    ; Imprimir el mensaje
                    mov  dx, OFFSET msgBeginValue
                    mov  ah, 09h
                    int  21h
                   
    ; Convertir el valor de AX a decimal para mostrarlo
                    mov  bx, 10                        ; Base 10 para mostrarlo en decimal
                    mov  cx, 0                         ; Contador de dígitos
                    mov  si, OFFSET valueBuffer
                   
    ; Manejo especial para cero
                    cmp  ax, 0
                    jne  begin_convert
                    mov  byte ptr [si], '0'
                    mov  byte ptr [si+1], 13           ; CR
                    mov  byte ptr [si+2], 10           ; LF
                    mov  byte ptr [si+3], '$'
                    jmp  print_value
                   
    begin_convert:  
    ; Convertir AX a string
                    push ax                            ; Guardar AX original
    convert_digit:  
                    xor  dx, dx                        ; DX:AX / BX, DX = remainder
                    div  bx                            ; AX = cociente, DX = resto
                    add  dl, '0'                       ; Convertir a ASCII
                    push dx                            ; Guardar dígito en la pila
                    inc  cx                            ; Incrementar contador
                    test ax, ax                        ; ¿Hemos terminado?
                    jnz  convert_digit                 ; No, continuar
                   
    ; Sacar los dígitos de la pila en orden inverso
                    mov  di, 0
    extract_digit:  
                    pop  dx                            ; Recuperar dígito de la pila
                    mov  bx, si
                    add  bx, di
                    mov  [bx], dl                      ; Colocarlo en el buffer
                    inc  di
                    loop extract_digit                 ; Repetir hasta que CX = 0
                   
    ; Agregar final de línea y terminador de cadena
                    mov  bx, si
                    add  bx, di
                    mov  byte ptr [bx], 13             ; CR
                    inc  bx
                    mov  byte ptr [bx], 10             ; LF
                    inc  bx
                    mov  byte ptr [bx], '$'
                   
                    pop  ax                            ; Restaurar AX original
                   
    print_value:    
    ; Imprimir el valor
                    mov  dx, si
                    mov  ah, 09h
                    int  21h
                   
                    pop  di
                    pop  si
                    pop  dx
                    pop  cx
                    pop  bx
                    pop  ax
                    ret
PrintBeginValue ENDP

PrintNot PROC
                    mov  dx, OFFSET msgNotAvailable
                    mov  ah, 09h
                    int  21h
                    ret
PrintNot ENDP

PrintEndg PROC
                    mov  dx, OFFSET msgEnd
                    mov  ah, 09h
                    int  21h
                    mov  ah, 08h                       ; Wait for keypress
                    int  21h
                    ret
PrintEndg ENDP

END Start  ; Note: cselect.asm is the actual entry point