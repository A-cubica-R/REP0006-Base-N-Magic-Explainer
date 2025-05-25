.MODEL small

; Public buffers for external procedures
PUBLIC BUFFER_IntputStr
   
   ; External procedures
EXTERN MAIN_FROMB:NEAR
EXTERN MAIN_FROMO:NEAR

.DATA

    ; Util printing
    var_newLine            DB 13, 10, "$"
    ; For user messages
    var_messageWelcome     DB "Great!, please define the process", 13, 10, "$"
    var_messageFromBase    DB "Select the base to convert from:", 13, 10, "$"
    var_messageToBase      DB "Select the target base:", 13, 10, "$"
    var_messageNumber      DB "Enter your number to convert:", 13, 10, "$"
    var_messageConfirm0    DB "You have selected from ", "$"
    var_messageConfirm1    DB " to ", "$"
    var_messageConfirm2    DB "For this number: ", "$"
    var_messageConfirm3    DB "Do you want proceed? (Y / N):", "$"
    ; Error messages
    var_messageInputError1 DB "Error In Bases: invalid input.", 13, 10, "$"
    var_messageInputError2 DB "Error In Number: invalid input.", 13, 10, "$"
    ; Independent for conversion
    var_baseBinary         DB "Binary", "$"
    var_baseOctal          DB "Octal", "$"
    var_baseDecimal        DB "Decimal", "$"
    var_baseHexadecimal    DB "Hexadecimal", "$"
	
    ; List of base options
    var_basesList1         DB "1 - Binary", 13, 10, "$"
    var_basesList2         DB "2 - Octal", 13, 10, "$"
    var_basesList3         DB "3 - Decimal", 13, 10, "$"
    var_basesList4         DB "4 - Hexadecimal", 13, 10, "$"
	
    ; Buffers for input and output
    ; Buffer format: [max length][actual length][characters...]
    BUFFER_IntBase         DB 2, ?, 2 DUP(?)
    BUFFER_OutBase         DB 2, ?, 2 DUP(?)
    BUFFER_IntputStr       DB 11, ?, 11 DUP("$")

    ;Temporals for other uses
    BUFFER_TemporalLarge   DB 40, ?, 40 DUP(?)
    BUFFER_TemporalTinny   DB 2, ?, 2 DUP(?)

    ; Test and debugger vars
    var_Test1              DB "### Break point 1 ####", 13, 10, "$"
    var_Test2              DB "### Break point 2 ####", 13, 10, "$"
    var_Test3              DB "### Break point 3 ####", 13, 10, "$"
    var_Test4              DB "### Break point 4 ####", 13, 10, "$"
    var_Test5              DB "### Break point 5 ####", 13, 10, "$"
.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Main procedure
MAIN_CHOSE PROC NEAR PUBLIC
    ; Initialize the data segment
                        CALL InitSelection

                        LEA  DX, var_newLine
                        CALL PrintString

                        CALL ClearScreen
                        RET
MAIN_CHOSE ENDP

    ; Init the base-N to base-N convertion
InitSelection PROC

    ; The init of the procedure, could be jumped for other procedures
    _PresentAndInit:    
                        CALL ClearScreen
                        LEA  DX, var_messageWelcome
                        CALL PrintString
                        LEA  DX, var_messageFromBase                  ; Ask for the source base
                        CALL PrintString
                        CALL PrintListOfBases                         ; Print the list of bases
                        CALL _ReadBaseInput                           ; Read the source base

                        CALL ClearScreen
                        LEA  DX, var_messageToBase                    ; Ask for the target base
                        CALL PrintString
                        CALL PrintListOfBases                         ; Print the list of bases
                        CALL _ReadBaseOutput                          ; Read the destination base

                        CALL ClearScreen
                        LEA  DX, var_messageNumber                    ; Ask for the number to convert
                        CALL PrintString
                        CALL _ReadNumber                              ; Read the number to convert
                        CALL ValidateNumber                           ; Validate the number entered by the user

    _DoUWantProceed:    
                        CALL ClearScreen
                        CALL PrintSelection                           ; Print the confirmation message
                        CALL ReceiveConfirm                           ; AL = confirmation input

                        CMP  AL, 'Y'
                        JE   _Proceed
                        CMP  AL, 'y'
                        JE   _Proceed
                        CMP  AL, 'N'
                        JE   _Finish
                        CMP  AL, 'n'
                        JE   _Finish

                        LEA  DX, var_messageInputError2
                        CALL PrintString_wait                         ; Any input was valid to proceed, retry
                        JMP  _DoUWantProceed


    ; ####### READING SUB-PROCEDURES #######

    ; Read the origin base and save it in BL
    _ReadBaseInput:     
                        LEA  DX, BUFFER_IntBase
                        MOV  AH, 0AH
                        INT  21H

                        LEA  SI, BUFFER_IntBase
                        MOV  AL, [SI + 2]
                        SUB  AL, '0'
                        CMP  AL, 1
                        JB   _ShowErrorInt
                        CMP  AL, 4
                        JA   _ShowErrorInt
                        MOV  BL, AL
                        RET
    _ShowErrorInt:      
                        LEA  DX, var_messageInputError1
                        CALL PrintString_wait
                        JMP  _ReadBaseInput

    ; Read the destination base and save it in BH
    _ReadBaseOutput:    
                        LEA  DX, BUFFER_OutBase
                        MOV  AH, 0AH
                        INT  21H

                        LEA  SI, BUFFER_OutBase
                        MOV  AL, [SI + 2]
                        SUB  AL, '0'
                        CMP  AL, 1
                        JB   _ShowErrorOut
                        CMP  AL, 4
                        JA   _ShowErrorOut
                        MOV  BH, AL
                        RET
    _ShowErrorOut:      
                        LEA  DX, var_messageInputError1
                        CALL PrintString_wait
                        JMP  _ReadBaseOutput

    ; Read the number to convert and save it in the buffer
    _ReadNumber:        
                        LEA  DX, BUFFER_IntputStr                     ; Prepare the buffer for input
                        MOV  AH, 0Ah
                        INT  21h
    
                        LEA  SI, BUFFER_IntputStr
                        MOV  CL, [SI+1]                               ; CL = number of characters entered

                        CMP  CL, [SI]                                 ; Check if the number of characters is valid
                        JA   _ErrorAtNumber

                        ADD  SI, 2                                    ; SI points to the first entered character
                        MOV  CH, 0                                    ; Clean the high byte of CX
                        ADD  SI, CX                                   ; SI points to the byte after the last character
                        DEC  SI                                       ; SI points to the last entered character (should be 0Dh)
                        MOV  AL, [SI]
                        CMP  AL, 0Dh
                        JNZ  _Finish                                  ; If it's not 0Dh, exit
                        MOV  BYTE PTR [SI], "$"                       ; Replace 0Dh with '$'
                        RET

    _ErrorAtNumber:     
                        LEA  DX, var_messageInputError2
                        CALL PrintString_wait
                        JMP  _ReadNumber

    ; Proceed with the conversion if the user confirmed
    _Proceed:           
                        CALL DoConvertion
                        JMP  _Finish

    ; Exit of the Procedure or SubProcedures if they was called (NOT JUMPED)
    _Finish:            
                        RET
InitSelection ENDP

    ; ====== EXTERNAL PROCEDURES ======

DoConvertion PROC
                        CALL ClearScreen
                        CMP  BL, 1
                        JE   _fromBin
                        CMP  BL, 2
                        JE   _fromOct
                        CMP  BL, 3
                        JE   _fromDec
                        CMP  BL, 4
                        JE   _fromHex
                        JMP  _FinishDoConvertion

    _fromBin:           
                        CALL MAIN_FROMB
                        JMP  _FinishDoConvertion
    _fromOct:           
                        CALL MAIN_FROMO
                        JMP  _FinishDoConvertion
    _fromDec:           
                        JMP  _FinishDoConvertion
    _fromHex:           
                        JMP  _FinishDoConvertion
    _FinishDoConvertion:
                        RET
DoConvertion ENDP

    ; ======= SUP PROCEDURES =======

    ; Print the list of bases available for conversion

PrintListOfBases PROC
                        LEA  DX, var_basesList1
                        CALL PrintString
                        LEA  DX, var_basesList2
                        CALL PrintString
                        LEA  DX, var_basesList3
                        CALL PrintString
                        LEA  DX, var_basesList4
                        CALL PrintString
                        RET
PrintListOfBases ENDP

    ; Validate the number entered by the user with the base selected
ValidateNumber PROC

    _ValidateRetry:     
                        LEA  SI, BUFFER_IntputStr
                        MOV  CL, [SI + 1]                             ; CL = number of characters entered
                        LEA  SI, BUFFER_IntputStr + 2                 ; SI = address of the first character

    _ValidateLoop:      
                        CMP  CL, 0
                        JE   _ValidOK                                 ; If there are no more characters, exit

                        MOV  DL, [SI]

                        CMP  BL, 1
                        JE   _CheckBin
                        CMP  BL, 2
                        JE   _CheckOct
                        CMP  BL, 3
                        JE   _CheckDec
                        CMP  BL, 4
                        JE   _CheckHex
                        JMP  _ErrorDigit                              ; If the base is not valid, show error

    _CheckBin:          
                        CMP  DL, '0'
                        JE   _ItsOk
                        CMP  DL, '1'
                        JE   _ItsOk
                        JMP  _ErrorDigit

    _CheckOct:          
                        CMP  DL, '0'
                        JB   _ErrorDigit
                        CMP  DL, '7'
                        JA   _ErrorDigit
                        JMP  _ItsOk

    _CheckDec:          
                        CMP  DL, '0'
                        JB   _ErrorDigit
                        CMP  DL, '9'
                        JA   _ErrorDigit
                        JMP  _ItsOk

    _CheckHex:          
                        CMP  DL, '0'
                        JB   _ErrorDigit
                        CMP  DL, '9'
                        JBE  _ItsOk
                        CMP  DL, 'A'
                        JB   _ErrorDigit
                        CMP  DL, 'F'
                        JBE  _ItsOk
                        CMP  DL, 'a'
                        JB   _ErrorDigit
                        CMP  DL, 'f'
                        JBE  _ItsOk
                        JMP  _ErrorDigit

    _ItsOk:             
                        INC  SI
                        DEC  CL
                        JMP  _ValidateLoop

    _ErrorDigit:        
                        LEA  DX, var_messageInputError2
                        CALL PrintString_wait
                        LEA  DX, var_messageNumber
                        CALL PrintString
                        CALL _ReadNumber
                        JMP  _ValidateRetry

    _ValidOK:           
                        RET
ValidateNumber ENDP

    ; This procedure prints the selection made by the user, save the selection in AL
PrintSelection PROC NEAR
                        CALL PrintNewLine

                        LEA  DX, var_messageConfirm0
                        CALL PrintString                              ; "You have selected from ..."

                        MOV  AL, BL                                   ; Source base in BL
                        CALL PrintBaseName                            ; "...[source base]..."
    
                        LEA  DX, var_messageConfirm1
                        CALL PrintString                              ; "... To ..."

                        MOV  AL, BH                                   ; Target base in BH
                        CALL PrintBaseName                            ; "[target base]..."
    
                        CALL PrintNewLine
                        CALL PrintNewLine

                        LEA  DX, var_messageConfirm2
                        CALL PrintString

                        LEA  DX, BUFFER_IntputStr + 2
                        CALL PrintString
    
                        CALL PrintNewLine
    
                        LEA  DX, var_messageConfirm3
                        CALL PrintString

                        RET
PrintSelection ENDP


ReceiveConfirm PROC
                        LEA  DX, BUFFER_TemporalTinny
                        mov  AH, 0Ah
                        int  21h

                        MOV  AL, BYTE PTR [BUFFER_TemporalTinny+2]    ; Read the first character of the confirmation input
                        RET
ReceiveConfirm ENDP
    
    ; Print the name of the base selected in AL (Only used in PrintSelection)
PrintBaseName PROC NEAR
                        CMP  AL, 1
                        JE   _Bin
                        CMP  AL, 2
                        JE   _Oct
                        CMP  AL, 3
                        JE   _Dec
                        CMP  AL, 4
                        JE   _Hex
                        RET
    _Bin:               LEA  DX, var_baseBinary
                        CALL PrintString
                        RET
    _Oct:               LEA  DX, var_baseOctal
                        CALL PrintString
                        RET
    _Dec:               LEA  DX, var_baseDecimal
                        CALL PrintString
                        RET
    _Hex:               LEA  DX, var_baseHexadecimal
                        CALL PrintString
                        RET
PrintBaseName ENDP

    ; Entrada: AL = carácter ASCII
    ; Salida: AL = valor numérico (0-15)
    ; Usa base BL para validar (ej: base 2 permite solo 0-1)

ConvertCharToVal PROC
                        CMP  AL, '0'
                        JB   _Invalido
                        CMP  AL, '9'
                        JBE  _EsNumero
                        CMP  AL, 'A'
                        JB   _chkMinus
                        CMP  AL, 'F'
                        JBE  _EsMayus
                        JMP  _chkMinus

    _chkMinus:          
                        CMP  AL, 'a'
                        JB   _Invalido
                        CMP  AL, 'f'
                        JA   _Invalido
                        SUB  AL, 'a' - 10
                        JMP  _CheckBase

    _EsMayus:           
                        SUB  AL, 'A'
                        ADD  AL, 10
                        JMP  _CheckBase

    _EsNumero:          
                        SUB  AL, '0'

    _CheckBase:         
    ; Verifica que AL < base (BL)
                        CMP  AL, BL
                        JB   _Ok
    _Invalido:          
                        MOV  AL, 0                                    ; Podrías emitir error si deseas
    _Ok:                
                        RET
ConvertCharToVal ENDP


    ; ======= AUX OF PROCEDURES =======

    ; Print a string to the screen from DX register
PrintString PROC
                        MOV  AH,09h
                        INT  21h
                        RET
PrintString ENDP

    ; Print a string to the screen from DX register and wait for a key press
PrintString_wait PROC
                        MOV  ah, 09h
                        INT  21h
                        MOV  ah, 0
                        INT  16h
                        RET
PrintString_wait ENDP

    ; Print a string to the screen from DX register and add a new line
PrintNewLine PROC
                        MOV  AH, 09h
                        LEA  DX, var_newLine
                        INT  21h
                        RET
PrintNewLine ENDP

    ; Erase the content of the screen
ClearScreen PROC
                        MOV  AH,0
                        MOV  AL,3
                        INT  10h
                        RET
ClearScreen ENDP

END MAIN_CHOSE
