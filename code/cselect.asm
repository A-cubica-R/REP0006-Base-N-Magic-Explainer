.MODEL small
.STACK 100h

EXTERN BToOCT:NEAR, BToDEC:NEAR, BToHEX:NEAR
;EXTERN OToBIN:NEAR, OToDEC:NEAR, OToHEX:NEAR
;EXTERN DToBIN:NEAR, DToOCT:NEAR, DToHEX:NEAR
;EXTERN HToBIN:NEAR, HToOCT:NEAR, HToDEC:NEAR

.DATA

    ; Public buffer
                   PUBLIC bufResult
    ; Messages
    msgWelcome     DB     0Dh,0Ah,'Welcome, select the source base:','$'        ; Welcome message for source base selection
    msgTarget      DB     0Dh,0Ah,'Select the target base:','$'                 ; Message for target base selection
    msgDigitPrompt DB     0Dh,0Ah,'Enter your number to convert:','$'           ; Prompt to enter the number to convert
    msgError       DB     0Dh,0Ah,'Error: invalid input.','$'                   ; Error message for invalid input
    msgSelPart1    DB     "You have selected from $"                            ; Part 1 of the selection summary message
    msgSelPart2    DB     " to $"                                               ; Part 2 of the selection summary message
    msgNumPart     DB     'Starting number: ' ,'$'                              ; Message for displaying the starting number
    msgProceed     DB     0Dh,0Ah,'Proceed? (Y/N):','$'                         ; Prompt to confirm proceeding with conversion
    ; Parts of the selection summary
    msgBinary      DB     "Binary$"                                             ; Label for binary base
    msgOctal       DB     "Octal$"                                              ; Label for octal base
    msgDecimal     DB     "Decimal$"                                            ; Label for decimal base
    msgHex         DB     "Hexadecimal$"                                        ; Label for hexadecimal base
    newline        DB     0Dh,0Ah,"$"                                           ; Newline character for formatting

    ; List of base options
    listBases      DB     0Dh,0Ah,'1 - Binary',0Dh,0Ah, '2 - Octal',0Dh,0Ah,
'3 - Decimal',0Dh,0Ah, '4 - Hexadecimal',0Dh,0Ah,'$'                            ; Menu options for base selection

    ; DOS buffers for input
    bufBase        DB     2, ?, 2 DUP(?)                                        ; Buffer for reading a single digit + CR
    bufNumber      DB     32, ?, 32 DUP(?)                                      ; Buffer for reading up to 31 characters + CR

    bufResult      DB     33 DUP('$')                                           ; espacio para hasta 32 dígitos + '$'
    msgResult      DB     0Dh,0Ah,'Result: $'                                   ; Message for displaying the result

.CODE
                      PUBLIC SelectBase

    ;===================================================================
    ; SelectBase: Main flow of the program
    ;===================================================================
    ; This procedure orchestrates the entire process:
    ; 1. Clears the screen.
    ; 2. Reads the source base and stores it in BL.
    ; 3. Reads the target base and stores it in BH.
    ; 4. Reads the number to convert and validates it based on the source base.
    ; 5. Displays the selection summary.
    ; 6. Prompts the user to confirm whether to proceed with the conversion.
    ; 7. If confirmed, it jumps to the conversion logic (not implemented here).
SelectBase PROC NEAR
    ; Prepare DS (Data Segment)
                      mov    ax, SEG @DATA
                      mov    ds, ax
                      mov    es, ax

    ; Call procedures for each step of the process
                      call   ClearScreen
                      call   ReadBaseSource            ; Reads and stores the source base in BL (1..4)
                      call   ClearScreen
                      call   ReadBaseTarget            ; Reads and stores the target base in BH (1..4)
                      call   ClearScreen
                      call   ReadNumber                ; Reads the number string into bufNumber
                      call   ValidateNumber            ; Validates bufNumber based on the source base in BL
                      call   ClearScreen
                      call   PrintSelection            ; Displays a summary of the selection (uses BL and BH)
                      call   PromptContinue            ; Prompts the user to confirm (Y/N)
                      cmp    al,'Y'
                      je     callConversion            ; If 'Y', proceed to conversion
                      cmp    al,'y'
                      je     callConversion            ; If 'y', proceed to conversion
                      ret                              ; Return without converting if not confirmed

    callConversion:   
                      call   DoConversion
                      ret
SelectBase ENDP

DoConversion PROC
                      call   ClearScreen
                      call   StrToNum
                      lea    di, bufResult
    ; From BL stored base to BH stored base

    ; BL=1 (From Binary)
                      cmp    bl, 1                     ; The base is 1? Jump if not
                      jne    check_Oct
    ; The base was 1, so
                      cmp    bh, 2                     ; The target base is 2? Jump if yes
                      je     call_BToOCT
                      cmp    bh, 3                     ; The target base is 3? Jump if yes
                      je     call_BToDEC
                      cmp    bh, 4                     ; The target base is 4? Jump if yes
                      je     call_BToHEX
    ; The target base is 1, so no conversion needed
                      jmp    skip_conversion

    ; BL=2 (From Octal)
    check_Oct:        
                      cmp    bl, 2                     ; The base is 2? Jump if not
                      jne    check_Dec
    ; The base was 2, so
                      cmp    bh, 1                     ; The target base is 1? Jump if yes
                      je     call_OToBIN
                      cmp    bh, 3                     ; The target base is 3? Jump if yes
                      je     call_OToDEC
                      cmp    bh, 4                     ; The target base is 4? Jump if yes
                      je     call_OToHEX
    ; The target base is 2, so no conversion needed
                      jmp    skip_conversion

    ; BL=3 (From Decimal)
    check_Dec:        
                      cmp    bl, 3                     ; The base is 3? Jump if not
                      jne    checkHex
    ; The base was 3, so
                      cmp    bh, 1                     ; The target base is 1? Jump if yes
                      je     call_DToBIN
                      cmp    bh, 2                     ; The target base is 2? Jump if yes
                      je     call_DToOCT
                      cmp    bh, 4                     ; The target base is 4? Jump if yes
                      je     call_DToHEX
    ; The target base is 3, so no conversion needed
                      jmp    skip_conversion

    ; BL=4 (From Hexadecimal)
    check_Hex:        
                      cmp    bl, 4                     ; The base is 4? Jump if not
                      jne    skip_conversion
    ; The base was 4, so
                      cmp    bh, 1                     ; The target base is 1? Jump if yes
                      je     call_HToBIN
                      cmp    bh, 2                     ; The target base is 2? Jump if yes
                      je     call_HToOCT
                      cmp    bh, 3                     ; The target base is 3? Jump if yes
                      je     call_HToDEC
    ; The target base is 4, so no conversion needed
                      jmp    skip_conversion

    ; -------------- Calls to conversion procedures --------------
    call_BToOCT:      
                      call   BToOCT
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult

    call_BToDEC:      
                      lea    si, bufNumber             ; donde se guardó la cadena binaria
                      call   StrBinToNum               ; al volver, AX = número decimal 10
                      call   BToDec                    ; convierte ese AX a string decimal en bufResult
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult

    call_BToHEX:      
                      call   BToHEX
                      lea    dx, msgResult
                      call   print_string
                      jmp    printResult

    call_OToBIN:      
    ; call   OToBIN
    ; jmp    printResult
                      ret

    call_OToDEC:      
    ; call   OToDEC
    ; jmp    printResult
                      ret

    call_OToHEX:      
    ; call   OToHEX
    ; jmp    printResult
                      ret

    call_DToBIN:      
    ; call   DToBIN
    ; jmp    printResult
                      ret

    call_DToOCT:      
    ; call   DToOCT
    ; jmp    printResult
                      ret

    call_DToHEX:      
    ; call   DToHEX
    ; jmp    printResult
                      ret

    call_HToBIN:      
    ; call   HToBIN
    ; jmp    printResult
                      ret

    call_HToOCT:      
    ; call   HToOCT
    ; jmp    printResult
                      ret

    call_HToDEC:      
    ; call   HToDEC
    ; jmp    printResult
                      ret

    ; ------------------- Printing procedures -------------------

    skip_conversion:  
                      lea    dx, msgError
                      call   print_string_wait
                      ret

    printResult:      
                      mov    ah, 09h
                      lea    dx, bufResult
                      int    21h
                      mov    ah, 0                     ; Wait for key press
                      int    16h
                      ret
DoConversion ENDP


    ;===================================================================
    ; ReadBaseSource: Displays options and reads the source base into BL
    ;===================================================================
    ; This procedure:
    ; 1. Displays the welcome message and base options.
    ; 2. Reads the user's input and validates it (1..4).
    ; 3. Stores the valid input in BL.
    ; 4. If invalid, displays an error message and retries.
ReadBaseSource PROC NEAR
                      lea    dx, msgWelcome
                      call   print_string
                      lea    dx, listBases
                      call   print_string

                      lea    dx, bufBase
                      mov    ah,0Ah
                      int    21h
                      mov    al, bufBase+2             ; Read input ('1'..'4')
                      sub    al,'0'
                      cmp    al,1
                      jb     ErrorBase                 ; If less than 1, show error
                      cmp    al,4
                      ja     ErrorBase                 ; If greater than 4, show error
                      mov    bl,al                     ; Store valid input in BL
                      ret
    ErrorBase:        
                      lea    dx, msgError
                      call   print_string
                      call   ReadBaseSource            ; Retry reading source base
                      ret
ReadBaseSource ENDP

    ;===================================================================
    ; ReadBaseTarget: Reads the target base into BH
    ;===================================================================
    ; This procedure:
    ; 1. Displays the target base selection message and options.
    ; 2. Reads the user's input and validates it (1..4).
    ; 3. Stores the valid input in BH.
    ; 4. If invalid, displays an error message and retries.
ReadBaseTarget PROC NEAR
                      lea    dx, msgTarget
                      call   print_string
                      lea    dx, listBases
                      call   print_string

                      lea    dx, bufBase
                      mov    ah,0Ah
                      int    21h
                      mov    al, bufBase+2             ; Read input ('1'..'4')
                      sub    al,'0'
                      cmp    al,1
                      jb     ErrorTarget               ; If less than 1, show error
                      cmp    al,4
                      ja     ErrorTarget               ; If greater than 4, show error
                      mov    bh,al                     ; Store valid input in BH
                      ret
    ErrorTarget:      
                      lea    dx, msgError
                      call   print_string
                      call   ReadBaseTarget            ; Retry reading target base
                      ret
ReadBaseTarget ENDP

    ;===================================================================
    ; ReadNumber: Reads the numeric string into bufNumber
    ;===================================================================
    ; This procedure:
    ; 1. Prompts the user to enter the number to convert.
    ; 2. Reads the input string into bufNumber.
    ; 3. Appends a '$' character at the end for proper string termination.
ReadNumber PROC NEAR
                      lea    dx, msgDigitPrompt
                      call   print_string
                      lea    dx, bufNumber
                      mov    ah,0Ah
                      int    21h
                      mov    cl, [bufNumber+1]         ; CL = number of characters read
                      lea    di, bufNumber+2
                      add    di, cx                    ; DI = address after the last digit
                      mov    byte ptr [di], '$'        ; Append '$' to terminate the string
                      ret
ReadNumber ENDP

    ;===================================================================
    ; ValidateNumber: Validates each digit based on the source base (BL)
    ;===================================================================
    ; This procedure:
    ; 1. Iterates through each character in bufNumber.
    ; 2. Checks if the character is valid for the source base (BL).
    ; 3. If invalid, displays an error message and retries reading the number.
ValidateNumber PROC NEAR
                      mov    cl, bufNumber+1           ; Length of the input string
                      lea    si, bufNumber+2
    ValidateLoop:     
                      cmp    cl,0
                      je     ValidOK                   ; If all characters are valid, exit
                      mov    dl,[si]
                      cmp    bl,1
                      je     CheckBin                  ; Validate for binary base
                      cmp    bl,2
                      je     CheckOct                  ; Validate for octal base
                      cmp    bl,3
                      je     CheckDec                  ; Validate for decimal base
                      cmp    bl,4
                      je     CheckHex                  ; Validate for hexadecimal base
                      jmp    ErrorDigit

    CheckBin:         
                      cmp    dl,'0'
                      je     OK
                      cmp    dl,'1'
                      je     OK
                      jmp    ErrorDigit

    CheckOct:         
                      cmp    dl,'0'
                      jb     ErrorDigit
                      cmp    dl,'7'
                      ja     ErrorDigit
                      jmp    OK

    CheckDec:         
                      cmp    dl,'0'
                      jb     ErrorDigit
                      cmp    dl,'9'
                      ja     ErrorDigit
                      jmp    OK

    CheckHex:         
                      cmp    dl,'0'
                      jb     ErrorDigit
                      cmp    dl,'9'
                      jbe    OK
                      cmp    dl,'A'
                      jb     ErrorDigit
                      cmp    dl,'F'
                      jbe    OK
                      cmp    dl,'a'
                      jb     ErrorDigit
                      cmp    dl,'f'
                      jbe    OK
                      jmp    ErrorDigit

    OK:               
                      inc    si
                      dec    cl
                      jmp    ValidateLoop

    ErrorDigit:       
                      lea    dx, msgError
                      call   print_string
                      call   ReadNumber                ; Retry reading the number
                      jmp    ValidateNumber

    ValidOK:          
                      ret
ValidateNumber ENDP

    ;===================================================================
    ; PrintSelection: Displays BL (source), BH (target), and the number
    ;===================================================================
    ; This procedure:
    ; 1. Displays the source base, target base, and the entered number.
    ; 2. Uses helper procedures to print the base names and the number.
PrintSelection PROC NEAR
                      lea    dx, newline
                      call   print_string
                      lea    dx, msgSelPart1
                      call   print_string
                      mov    al, bl                    ; Source base in BL
                      call   PrintBaseName             ; Print the name of the source base

                      lea    dx, msgSelPart2
                      call   print_string
                      mov    al, bh                    ; Target base in BH
                      call   PrintBaseName             ; Print the name of the target base

                      lea    dx, newline
                      call   print_string
                      lea    dx, newline
                      call   print_string
                      lea    dx, msgNumPart
                      call   print_string
                      lea    dx, bufNumber+2           ; Number string
                      call   print_string

                      lea    dx, newline
                      call   print_string

                      lea    dx, msgProceed
                      call   print_string
                      ret
PrintSelection ENDP

    ;===================================================================
    ; PrintBaseName: Prints the name of the base passed in AL
    ;===================================================================
    ; This procedure:
    ; 1. Takes AL as input (1..4).
    ; 2. Prints the corresponding base name (Binary, Octal, Decimal, Hexadecimal).
PrintBaseName PROC NEAR
                      cmp    al,1
                      je     _Bin
                      cmp    al,2
                      je     _Oct
                      cmp    al,3
                      je     _Dec
                      cmp    al,4
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

    ;---------------------------------------------
    ; StrToNum PROC
    ;   Convierte cadena en bufNumber (terminada en '$')
    ;   en un entero en AX, según la base en BL:
    ;     BL = 1→bin, 2→oct, 3→dec, 4→hex
    ;---------------------------------------------
StrToNum PROC
                      push   bx
                      push   cx
                      push   dx
                      push   si

                      xor    ax, ax                    ; AX = 0 (acumulador)
                      mov    si, OFFSET bufNumber+2

    ; Determinar el factor multiplicador (BX = base)
                      cmp    bl, 1
                      je     .set2
                      cmp    bl, 2
                      je     .set8
                      cmp    bl, 3
                      je     .set10
                      cmp    bl, 4
                      je     .set16
                      jmp    .doneBase
.set2: mov  bx, 2                                      ; binario
                      jmp    .doneBase
.set8: mov  bx, 8                                      ; octal
                      jmp    .doneBase
.set10: mov  bx, 10                                    ; decimal
                      jmp    .doneBase
.set16: mov  bx, 16                                    ; hexadecimal
.doneBase:

.loop:
                      mov    dl, [si]                  ; siguiente carácter
                      cmp    dl, '$'
                      je     .endLoop

    ; calcular valor de dl en DX
    ; si '0'–'9'
                      cmp    dl, '9'
                      jle    .digitOK
    ; si 'A'–'F' o 'a'–'f'
                      cmp    dl, 'F'
                      jle    .hexUpper
                      cmp    dl, 'f'
                      jl     .invalidChar
                      sub    dl, 32                    ; llevar 'a'–'f' → 'A'–'F'
.hexUpper:
                      sub    dl, 'A' - 10
                      jmp    .digitDone
.digitOK:
                      sub    dl, '0'
.digitDone:
    ; DX = valor del dígito válido (0–15)
                      xor    dx, dx                    ; Clear DX
                      mov    dl, dl                    ; Move DL into DX (zero-extend)

    ; AX = AX * base + DX
                      mul    bx                        ; DX:AX = AX * BX, pero AX small suficiente
                      add    ax, dx

                      inc    si
                      jmp    .loop

.invalidChar:
    ; aquí podrías manejar error, pero asumimos que ValidateNumber ya filtró
                      jmp    .loop

.endLoop:
                      pop    si
                      pop    dx
                      pop    cx
                      pop    bx
                      ret
StrToNum ENDP

    ; Entrada: DS:SI apunta a cadena binaria ASCII terminada en '$'
    ; Salida:  AX contiene el número convertido (base 2)

    ; Entrada: DS:SI apunta a cadena binaria terminada en '$'
    ; Salida: AX contiene el valor decimal
StrBinToNum PROC
                      xor    ax, ax                    ; AX = resultado acumulado
                      xor    bx, bx                    ; BX se usa para valor del dígito (0 o 1)

.next:
                      mov    bl, [si]                  ; BL = siguiente carácter
                      cmp    bl, '$'
                      je     .done
                      inc    si                        ; avanzar al siguiente carácter

                      cmp    bl, '0'
                      jb     .next                     ; si menor a '0', ignorar
                      cmp    bl, '1'
                      ja     .next                     ; si mayor a '1', ignorar

                      shl    ax, 1                     ; AX *= 2
                      sub    bl, '0'                   ; convierte ASCII '0'/'1' → 0/1
                      add    ax, bx                    ; AX += bit
                      jmp    .next

.done:
                      ret
StrBinToNum ENDP




    ;===================================================================
    ; PromptContinue: Returns AL = key pressed
    ;===================================================================
    ; This procedure:
    ; 1. Waits for a key press.
    ; 2. Returns the key pressed in AL.
PromptContinue PROC NEAR
                      lea    dx, bufBase               ; reutiliza bufBase para leer 'Y' o 'N'
                      mov    ah, 0Ah
                      int    21h
                      mov    al, bufBase+2             ; el carácter leído
                      ret
PromptContinue ENDP


    ; Helper procedure to print a string
print_string PROC
                      mov    ah,09h
                      int    21h
                      ret
print_string ENDP

    ; Print and wait for a key press
print_string_wait PROC
                      mov    ah,09h
                      int    21h
                      mov    ah,0
                      int    16h
                      ret
print_string_wait ENDP

ClearScreen PROC
                      mov    ah,0
                      mov    al,3
                      int    10h
                      ret
ClearScreen ENDP

END SelectBase
