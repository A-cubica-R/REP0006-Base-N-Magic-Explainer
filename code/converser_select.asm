.MODEL small
.STACK 100h
.DATA
    ; Mensajes generales
    msgWelcome     DB 0Dh,0Ah,'Welcome, select the source base:','$'
    msgTarget      DB 0Dh,0Ah,'Select the target base:','$'
    msgDigitPrompt DB 0Dh,0Ah,'Enter your number to convert:','$'
    msgError       DB 0Dh,0Ah,'Error: invalid input.','$'
    msgSelPart1    DB "You have selected from $"
    msgSelPart2    DB " to $"
    msgNumPart     DB 'Starting number: ' ,'$'
    msgProceed     DB 0Dh,0Ah,'Proceed? (Y/N):','$'
    msgBinary      DB "Binary$"
    msgOctal       DB "Octal$"
    msgDecimal     DB "Decimal$"
    msgHex         DB "Hexadecimal$"
    newline        DB 0Dh,0Ah,"$"

    ; Listado de opciones de bases
    listBases      DB 0Dh,0Ah,
'1 - Binary',0Dh,0Ah,
'2 - Octal',0Dh,0Ah,
'3 - Decimal',0Dh,0Ah,
'4 - Hexadecimal',0Dh,0Ah,'$'

    ; Buffers DOS para lectura
    bufBase        DB 2, ?, 2 DUP(?)                                    ; lee 1 dígito + CR
    bufNumber      DB 32, ?, 32 DUP(?)                                  ; hasta 31 caracteres + CR

.CODE
                   PUBLIC SelectBase

    ;===================================================================
    ; SelectBase: flujo principal
    ;===================================================================
SelectBase PROC NEAR
    ; preparar DS
                   mov    ax,@data
                   mov    ds,ax

                   call   ClearScreen
                   call   ReadBaseSource        ; lee y guarda en BL (1..4)
                   call   ClearScreen
                   call   ReadBaseTarget        ; lee y guarda en BH (1..4)
                   call   ClearScreen
                   call   ReadNumber            ; lee cadena en bufNumber
                   call   ValidateNumber        ; valida bufNumber según base en BL
                   call   ClearScreen
                   call   PrintSelection        ; muestra resumen (usa BL y BH)
                   call   PromptContinue        ; pregunta Y/N
                   cmp    al,'Y'
                   je     DoConversion
                   cmp    al,'y'
                   je     DoConversion
                   ret                          ; retorna sin convertir

    DoConversion:  
    ; aquí llamarías al conversor específico según BL->BH
    ; e.g., call Convert_3_to_1  si fuente=BL=3 (Decimal) y destino=BH=1 (Binary)
                   ret
SelectBase ENDP

    ;===================================================================
    ; ReadBaseSource: muestra opciones y lee la base de origen en BL
    ;===================================================================
ReadBaseSource PROC NEAR
                   lea    dx, msgWelcome
                   call   print_string
                   lea    dx, listBases
                   call   print_string

                   lea    dx, bufBase
                   mov    ah,0Ah
                   int    21h
                   mov    al, bufBase+2         ; '1'..'4'
                   sub    al,'0'
                   cmp    al,1
                   jb     ErrorBase
                   cmp    al,4
                   ja     ErrorBase
                   mov    bl,al                 ; BL = base fuente
                   ret
    ErrorBase:     
                   lea    dx, msgError
                   call   print_string
                   call   ReadBaseSource        ; reintentar
                   ret
ReadBaseSource ENDP

    ;===================================================================
    ; ReadBaseTarget: lee la base destino en BH
    ;===================================================================
ReadBaseTarget PROC NEAR
                   lea    dx, msgTarget
                   call   print_string
                   lea    dx, listBases
                   call   print_string

                   lea    dx, bufBase
                   mov    ah,0Ah
                   int    21h
                   mov    al, bufBase+2         ; '1'..'4'
                   sub    al,'0'
                   cmp    al,1
                   jb     ErrorTarget
                   cmp    al,4
                   ja     ErrorTarget
                   mov    bh,al                 ; BH = base destino
                   ret
    ErrorTarget:   
                   lea    dx, msgError
                   call   print_string
                   call   ReadBaseTarget        ; reintentar
                   ret
ReadBaseTarget ENDP

    ;===================================================================
    ; ReadNumber: lee la cadena numérica en bufNumber
    ;===================================================================
ReadNumber PROC NEAR
                   lea    dx, msgDigitPrompt
                   call   print_string
                   lea    dx, bufNumber
                   mov    ah,0Ah
                   int    21h
                   mov    cl, [bufNumber+1]     ; CL = número de caracteres leídos
                   lea    di, bufNumber+2
                   add    di, cx                ; DI = dirección tras el último dígito
                   mov    byte ptr [di], '$'
                   ret
ReadNumber ENDP

    ;===================================================================
    ; ValidateNumber: valida cada dígito según base fuente (BL)
    ;===================================================================
ValidateNumber PROC NEAR
                   mov    cl, bufNumber+1       ; longitud
                   lea    si, bufNumber+2
    ValidateLoop:  
                   cmp    cl,0
                   je     ValidOK
                   mov    dl,[si]
                   cmp    bl,1
                   je     CheckBin
                   cmp    bl,2
                   je     CheckOct
                   cmp    bl,3
                   je     CheckDec
                   cmp    bl,4
                   je     CheckHex
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
                   call   ReadNumber            ; reingresa número
                   jmp    ValidateNumber

    ValidOK:       
                   ret
ValidateNumber ENDP

    ;===================================================================
    ; PrintSelection: muestra BL (fuente), BH (destino) y número
    ;===================================================================
PrintSelection PROC NEAR
    ; "You've selected: "
                   lea    dx, newline
                   call   print_string
                   lea    dx, msgSelPart1
                   call   print_string
                   mov    al, bl                ; base fuente en BL
                   call   PrintBaseName         ; imprime nombre de base en AL

    ; " -> "
                   lea    dx, msgSelPart2
                   call   print_string
                   mov    al, bh                ; base destino en BH
                   call   PrintBaseName         ; imprime nombre de base en AL

    ; "Starting number: "
                   lea    dx, newline
                   call   print_string
                   lea    dx, newline
                   call   print_string
                   lea    dx, msgNumPart
                   call   print_string
                   lea    dx, bufNumber+2       ; cadena de dígitos
                   call   print_string

    ; salto de línea antes de prompt
                   lea    dx, newline
                   call   print_string

    ; Prompt de confirmación
                   lea    dx, msgProceed
                   call   print_string
                   ret
PrintSelection ENDP

    ;===================================================================
    ; PrintBaseName: imprime el nombre de la base pasada en AL
    ; Entrada: AL = 1..4
    ;===================================================================
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
    _Bin:          lea    dx, msgBinary
                   call   print_string
                   ret
    _Oct:          lea    dx, msgOctal
                   call   print_string
                   ret
    _Dec:          lea    dx, msgDecimal
                   call   print_string
                   ret
    _Hex:          lea    dx, msgHex
                   call   print_string
                   ret
PrintBaseName ENDP

    ;===================================================================
    ; PromptContinue: devuelve AL = tecla pulsada
    ;===================================================================
PromptContinue PROC NEAR
                   mov    ah,01h
                   int    21h
                   ret                          ; AL contiene 'Y' o 'N'
PromptContinue ENDP

print_string PROC
                   mov    ah,09h
                   int    21h
                   ret
print_string ENDP

ClearScreen PROC
                   mov    ah,0
                   mov    al,3
                   int    10h
                   ret
ClearScreen ENDP

END SelectBase
