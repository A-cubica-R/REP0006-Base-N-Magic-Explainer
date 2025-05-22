	.MODEL small
	.STACK 100h
	
EXTERN BToOCT:NEAR, BToDEC:NEAR, BToHEX:NEAR, BToBin:NEAR
	;EXTERN OToBIN:NEAR, OToDEC:NEAR, OToHEX:NEAR
	;EXTERN DToBIN:NEAR, DToOCT:NEAR, DToHEX:NEAR
	;EXTERN HToBIN:NEAR, HToOCT:NEAR, HToDEC:NEAR
	
.DATA
	
    ; Public buffer
    PUBLIC bufResult
    
    ; Messages
    msgWelcome     DB     0Dh, 0Ah, 'Welcome, select the source base:', '$'
    msgTarget      DB     0Dh, 0Ah, 'Select the target base:', '$'
    msgDigitPrompt DB     0Dh, 0Ah, 'Enter your number to convert:', '$'
    msgError       DB     0Dh, 0Ah, 'Error: invalid input.', '$'
    msgSelPart1    DB     "You have selected from $"
    msgSelPart2    DB     " to $"
    msgNumPart     DB     'Starting number: ', '$'
    msgProceed     DB     0Dh, 0Ah, 'Proceed? (Y / N):', '$'
    ; Parts of the selection summary
    msgBinary      DB     "Binary$"
    msgOctal       DB     "Octal$"
    msgDecimal     DB     "Decimal$"
    msgHex         DB     "Hexadecimal$"
    newline        DB     0Dh, 0Ah, "$"
	
    ; List of base options
    listBases      DB     0Dh, 0Ah, '1 - Binary', 0Dh, 0Ah, '2 - Octal', 0Dh, 0Ah,
'3 - Decimal', 0Dh, 0Ah, '4 - Hexadecimal', 0Dh, 0Ah, '$'                             ; Menu options for base selection
	
    ; DOS buffers for input
    bufBase        DB     2, ?, 2 DUP(?)                                              ; Buffer for reading a single digit + CR
    bufNumber      DB     32, ?, 32 DUP(?)                                            ; Buffer for reading up to 31 characters + CR
	
    bufResult      DB     33 DUP('$')                                                 ; espacio para hasta 32 dígitos + '$'
    msgResult      DB     0Dh, 0Ah, 'Result: $'                                       ; Message for displaying the result
	
    ; Para depuración
    msgDebugAX     DB     0Dh, 0Ah, 'AX value: $'
    debugBuffer    DB     6 DUP('$')
	
.CODE
	
                      PUBLIC SelectBase
SelectBase PROC NEAR
    ; Prepare DS (Data Segment)
                      mov    ax, SEG @DATA
                      mov    ds, ax
                      mov    es, ax
	
    ; Call procedures for each step of the process
                      call   ClearScreen
                      call   ReadBaseSource              ; Reads and stores the source base in BL (1..4)
                      call   ClearScreen
                      call   ReadBaseTarget              ; Reads and stores the target base in BH (1..4)
                      call   ClearScreen
                      call   ReadNumber                  ; Reads the number string into bufNumber
                      call   ValidateNumber              ; Validates bufNumber based on the source base in BL
                      call   ClearScreen
                      call   PrintSelection              ; Displays a summary of the selection (uses BL and BH)
                      call   PromptContinue              ; Prompts the user to confirm (Y / N)
                      cmp    al, 'Y'
                      je     callConversion              ; If 'Y', proceed to conversion
                      cmp    al, 'y'
                      je     callConversion              ; If 'y', proceed to conversion
                      ret                                ; Return without converting if not confirmed
	
    callConversion:   
                      call   DoConversion
                      ret
SelectBase ENDP
	
DoConversion PROC
                      call   ClearScreen
                      call   StrToNum                    ; Convert string to number in AX
	
    ; From BL stored base to BH stored base
	
    ; BL=1 (From Binary)
                      cmp    bl, 1                       ; The base is 1? Jump if not
                      jne    check_Oct
    ; The base was 1, so
                      cmp    bh, 1                       ; The target base is 1? Jump if yes
                      je     call_self_binary
                      cmp    bh, 2                       ; The target base is 2? Jump if yes
                      je     call_BToOCT
                      cmp    bh, 3                       ; The target base is 3? Jump if yes
                      je     call_BToDEC
                      cmp    bh, 4                       ; The target base is 4? Jump if yes
                      je     call_BToHEX
                      jmp    skip_conversion
	
    call_self_binary: 
                      call   BToBin                      ; Convertir a binario
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult
	
    ; BL=2 (From Octal)
    check_Oct:        
                      cmp    bl, 2                       ; The base is 2? Jump if not
                      jne    check_Dec
    ; The base was 2, so
                      cmp    bh, 1                       ; The target base is 1? Jump if yes
                      je     call_OToBIN
                      cmp    bh, 3                       ; The target base is 3? Jump if yes
                      je     call_OToDEC
                      cmp    bh, 4                       ; The target base is 4? Jump if yes
                      je     call_OToHEX
    ; The target base is 2, so no conversion needed
                      jmp    skip_conversion
	
    ; BL=3 (From Decimal)
    check_Dec:        
                      cmp    bl, 3                       ; The base is 3? Jump if not
                      jne    check_Hex
    ; The base was 3, so
                      cmp    bh, 1                       ; The target base is 1? Jump if yes
                      je     call_DToBIN
                      cmp    bh, 2                       ; The target base is 2? Jump if yes
                      je     call_DToOCT
                      cmp    bh, 4                       ; The target base is 4? Jump if yes
                      je     call_DToHEX
    ; The target base is 3, so no conversion needed
                      jmp    skip_conversion
	
    ; BL=4 (From Hexadecimal)
    check_Hex:        
                      cmp    bl, 4                       ; The base is 4? Jump if not
                      jne    skip_conversion
    ; The base was 4, so
                      cmp    bh, 1                       ; The target base is 1? Jump if yes
                      je     call_HToBIN
                      cmp    bh, 2                       ; The target base is 2? Jump if yes
                      je     call_HToOCT
                      cmp    bh, 3                       ; The target base is 3? Jump if yes
                      je     call_HToDEC
    ; The target base is 4, so no conversion needed
                      jmp    skip_conversion
	
    ; - - - - - - - - - - - - - - Calls to conversion procedures - - - - - - - - - - - - - -
    call_BToOCT:      
    ; AX already contains the converted number from StrToNum
                      call   BToOCT
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult
	
    call_BToDEC:      
    ; AX already contains the converted number from StrToNum
                      call   BToDec
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult
	
    call_BToHEX:      
    ; AX already contains the converted number from StrToNum
                      call   BToHEX
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult
	
    call_OToBIN:      
    ; call OToBIN
    ; jmp printResult
                      ret
	
    call_OToDEC:      
    ; call OToDEC
    ; jmp printResult
                      ret
	
    call_OToHEX:      
    ; call OToHEX
    ; jmp printResult
                      ret
	
    call_DToBIN:      
    ; call DToBIN
    ; jmp printResult
                      ret
	
    call_DToOCT:      
    ; call DToOCT
    ; jmp printResult
                      ret
	
    call_DToHEX:      
    ; call DToHEX
    ; jmp printResult
                      ret
	
    call_HToBIN:      
    ; call HToBIN
    ; jmp printResult
                      ret
	
    call_HToOCT:      
    ; call HToOCT
    ; jmp printResult
                      ret
	
    call_HToDEC:      
    ; call HToDEC
    ; jmp printResult
                      ret
	
    ; - - - - - - - - - - - - - - - - - - - Printing procedures - - - - - - - - - - - - - - - - - - -
	
    skip_conversion:  
                      lea    dx, msgError
                      call   print_string_wait
                      ret
	
    printResult:      
                      lea    dx, bufResult
                      call   print_string
                      mov    ah, 0                       ; Wait for key press
                      int    16h
                      ret
DoConversion ENDP
	
ReadBaseSource PROC NEAR
                      lea    dx, msgWelcome
                      call   print_string
                      lea    dx, listBases
                      call   print_string
	
                      lea    dx, bufBase
                      mov    ah, 0Ah
                      int    21h
                      mov    al, bufBase + 2             ; Read input ('1'..'4')
                      sub    al, '0'
                      cmp    al, 1
                      jb     ErrorBase                   ; If less than 1, show error
                      cmp    al, 4
                      ja     ErrorBase                   ; If greater than 4, show error
                      mov    bl, al                      ; Store valid input in BL
                      ret
    ErrorBase:        
                      lea    dx, msgError
                      call   print_string
                      call   ReadBaseSource              ; Retry reading source base
                      ret
ReadBaseSource ENDP
	
ReadBaseTarget PROC NEAR
                      lea    dx, msgTarget
                      call   print_string
                      lea    dx, listBases
                      call   print_string
	
                      lea    dx, bufBase
                      mov    ah, 0Ah
                      int    21h
                      mov    al, bufBase + 2             ; Read input ('1'..'4')
                      sub    al, '0'
                      cmp    al, 1
                      jb     ErrorTarget                 ; If less than 1, show error
                      cmp    al, 4
                      ja     ErrorTarget                 ; If greater than 4, show error
                      mov    bh, al                      ; Store valid input in BH
                      ret
    ErrorTarget:      
                      lea    dx, msgError
                      call   print_string
                      call   ReadBaseTarget              ; Retry reading target base
                      ret
ReadBaseTarget ENDP
	
ReadNumber PROC NEAR
                      lea    dx, msgDigitPrompt
                      call   print_string
                      lea    dx, bufNumber
                      mov    ah, 0Ah
                      int    21h
                      mov    cl, [bufNumber + 1]         ; CL = number of characters read
                      lea    di, bufNumber + 2
                      add    di, cx                      ; DI = address after the last digit
                      mov    byte ptr [di], '$'          ; Append '$' to terminate the string
                      ret
ReadNumber ENDP
	
ValidateNumber PROC NEAR
                      mov    cl, bufNumber + 1           ; Length of the input string
                      lea    si, bufNumber + 2
    ValidateLoop:     
                      cmp    cl, 0
                      je     ValidOK                     ; If all characters are valid, exit
                      mov    dl, [si]
                      cmp    bl, 1
                      je     CheckBin                    ; Validate for binary base
                      cmp    bl, 2
                      je     CheckOct                    ; Validate for octal base
                      cmp    bl, 3
                      je     CheckDec                    ; Validate for decimal base
                      cmp    bl, 4
                      je     CheckHex                    ; Validate for hexadecimal base
                      jmp    ErrorDigit
	
    CheckBin:         
                      cmp    dl, '0'
                      je     OK
                      cmp    dl, '1'
                      je     OK
                      jmp    ErrorDigit
	
    CheckOct:         
                      cmp    dl, '0'
                      jb     ErrorDigit
                      cmp    dl, '7'
                      ja     ErrorDigit
                      jmp    OK
	
    CheckDec:         
                      cmp    dl, '0'
                      jb     ErrorDigit
                      cmp    dl, '9'
                      ja     ErrorDigit
                      jmp    OK
	
    CheckHex:         
                      cmp    dl, '0'
                      jb     ErrorDigit
                      cmp    dl, '9'
                      jbe    OK
                      cmp    dl, 'A'
                      jb     ErrorDigit
                      cmp    dl, 'F'
                      jbe    OK
                      cmp    dl, 'a'
                      jb     ErrorDigit
                      cmp    dl, 'f'
                      jbe    OK
                      jmp    ErrorDigit
	
    OK:               
                      inc    si
                      dec    cl
                      jmp    ValidateLoop
	
    ErrorDigit:       
                      lea    dx, msgError
                      call   print_string
                      call   ReadNumber                  ; Retry reading the number
                      jmp    ValidateNumber
	
    ValidOK:          
                      ret
ValidateNumber ENDP
	
PrintSelection PROC NEAR
                      lea    dx, newline
                      call   print_string
                      lea    dx, msgSelPart1
                      call   print_string
                      mov    al, bl                      ; Source base in BL
                      call   PrintBaseName               ; Print the name of the source base
	
                      lea    dx, msgSelPart2
                      call   print_string
                      mov    al, bh                      ; Target base in BH
                      call   PrintBaseName               ; Print the name of the target base
	
                      lea    dx, newline
                      call   print_string
                      lea    dx, newline
                      call   print_string
                      lea    dx, msgNumPart
                      call   print_string
                      lea    dx, bufNumber + 2           ; Number string
                      call   print_string
	
                      lea    dx, newline
                      call   print_string
	
                      lea    dx, msgProceed
                      call   print_string
                      ret
PrintSelection ENDP
	
PrintBaseName PROC NEAR
                      cmp    al, 1
                      je     _Bin
                      cmp    al, 2
                      je     _Oct
                      cmp    al, 3
                      je     _Dec
                      cmp    al, 4
                      je     _Hex
                      ret
    _Bin:             lea    dx, msgBinary
                      call   print_string
                      ret
    _Oct:             lea    dx, msgOctal
                      call   print_string
                      ret
    _Dec:             lea    dx, msgDecimal
                      call   print_string
                      ret
    _Hex:             lea    dx, msgHex
                      call   print_string
                      ret
PrintBaseName ENDP
	
    ; Procedimiento corregido para convertir la cadena a número
    ; Procedimiento corregido para convertir la cadena a número
StrToNum PROC
                      push   bx
                      push   cx
                      push   dx
                      push   si
	
                      xor    ax, ax                      ; AX = 0 (acumulador)
                      mov    si, OFFSET bufNumber + 2    ; Puntero al inicio del número
	
    ; Determinar la base para la conversión numérica (no confundir con el código de base)
                      cmp    bl, 1
                      je     base_bin
                      cmp    bl, 2
                      je     base_oct
                      cmp    bl, 3
                      je     base_dec
                      cmp    bl, 4
                      je     base_hex
                      jmp    conv_done                   ; Base no válida, terminar
	
    base_bin:         mov    bx, 2                       ; Base 2 (binario)
                      jmp    start_conv
    base_oct:         mov    bx, 8                       ; Base 8 (octal)
                      jmp    start_conv
    base_dec:         mov    bx, 10                      ; Base 10 (decimal)
                      jmp    start_conv
    base_hex:         mov    bx, 16                      ; Base 16 (hexadecimal)
	
    start_conv:       
                      mov    cx, 0                       ; CX = contador de caracteres procesados
	
    next_digit:       
                      mov    dl, [si]                    ; Obtener el siguiente carácter
                      cmp    dl, '$'                     ; ¿Fin de la cadena?
                      je     conv_done                   ; Si es fin, terminar conversión
	
    ; Multiplicar el acumulador por la base
                      mul    bx                          ; AX = AX * BX
	
    ; Convertir carácter a valor numérico
                      cmp    dl, '0'
                      jb     invalid_char
                      cmp    dl, '9'
                      jbe    digit_0_9
	
    ; Es una letra (A - F o a - f)
                      cmp    dl, 'A'
                      jb     invalid_char
                      cmp    dl, 'F'
                      jbe    digit_A_F
                      cmp    dl, 'a'
                      jb     invalid_char
                      cmp    dl, 'f'
                      ja     invalid_char
                      sub    dl, 'a' - 10                ; 'a' - 'f' - > 10 - 15
                      jmp    add_digit
	
    digit_A_F:        
                      sub    dl, 'A' - 10                ; 'A' - 'F' - > 10 - 15
                      jmp    add_digit
	
    digit_0_9:        
                      sub    dl, '0'                     ; '0' - '9' - > 0 - 9
	
    add_digit:        
    ; Verificar si el dígito es válido para la base actual
                      cmp    dl, bl                      ; ESTE ES EL ERROR: Comparar con valor de la base, no con código
                      jae    invalid_char                ; Si es >= base, ignorar
	
    ; Agregar el dígito al acumulador
                      xor    dx, dx                      ; Limpiar la parte alta de DX
                      mov    dl, dl                      ; Mover el valor de DL a DX (DL ya tiene el dígito)
                      add    ax, dx                      ; AX = AX + DX (valor del dígito)
	
                      inc    si                          ; Avanzar al siguiente carácter
                      inc    cx                          ; Incrementar contador de caracteres
                      jmp    next_digit                  ; Procesar siguiente carácter
	
    invalid_char:     
                      inc    si                          ; Ignorar carácter inválido
                      inc    cx                          ; Contar carácter inválido
                      jmp    next_digit                  ; Continuar con el siguiente
	
    conv_done:        
                      pop    si
                      pop    dx
                      pop    cx
                      pop    bx
                      ret
StrToNum ENDP
	
PromptContinue PROC NEAR
                      lea    dx, bufBase                 ; reutiliza bufBase para leer 'Y' o 'N'
                      mov    ah, 0Ah
                      int    21h
                      mov    al, bufBase + 2             ; el carácter leído
                      ret
PromptContinue ENDP
	
	
    ; Helper procedure to print a string
print_string PROC
                      mov    ah, 09h
                      int    21h
                      ret
print_string ENDP
	
    ; Print and wait for a key press
print_string_wait PROC
                      mov    ah, 09h
                      int    21h
                      mov    ah, 0
                      int    16h
                      ret
print_string_wait ENDP
	
ClearScreen PROC
                      mov    ah, 0
                      mov    al, 3
                      int    10h
                      ret
ClearScreen ENDP
	
	END SelectBase
