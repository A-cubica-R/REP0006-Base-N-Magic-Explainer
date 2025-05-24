.MODEL small

PUBLIC BUFFER_IntputStr
PUBLIC BUFFER_IntputNum
PUBLIC BUFFER_OutputStr
PUBLIC BUFFER_OutputNum
                          
.DATA

    ; Util printing
    var_newLine           DB 13, 10, "$"
    ; For user messages
    var_messageWelcome    DB "Great!, please define the process", 13, 10, "$"
    var_messageFromBase   DB "Select the base to convert from:", 13, 10, "$"
    var_messageToBase     DB "Select the target base:", 13, 10, "$"
    var_messageNumber     DB "Enter your number to convert:", 13, 10, "$"
    var_messageConfirm1   DB "You have selected from ? To ?", 13, 10, "$"
    var_messageConfirm2   DB "For this number: ?", 13, 10, "$"
    var_messageConfirm3   DB "Do you want proceed? (Y / N):", "$"
    ;Templates for confirm
    var_confirmTemplate1  DB "You have selected from ? To ?", 13, 10, "$"
    var_confirmTemplate2  DB "For this number: ?", 13, 10, "$"
    ; Error messages
    var_messageInputError1 DB "Error In Bases: invalid input.", 13, 10, "$"
    var_messageInputError2 DB "Error In Number: invalid input.", 13, 10, "$"
    ; Bases for conversion
    var_baseBinary        DB "Binary", "$"
    var_baseOctal         DB "Octal", "$"
    var_baseDecimal       DB "Decimal", "$"
    var_baseHexadecimal   DB "Hexadecimal", "$"
	
    ; List of base options
    var_basesList1        DB "1 - Binary", 13, 10, "$"
    var_basesList2        DB "2 - Octal", 13, 10, "$"
    var_basesList3        DB "3 - Decimal", 13, 10, "$"
    var_basesList4        DB "4 - Hexadecimal", 13, 10, "$"
	
    ; Buffers for input and output
    ; Buffer format: [max length][actual length][characters...]
    BUFFER_IntBase        DB 2, ?, 2 DUP(?)
    BUFFER_OutBase        DB 2, ?, 2 DUP(?)
    BUFFER_IntputStr      DB 10, ?, 10 DUP("$")
    BUFFER_OutputStr      DB 40, ?, 40 DUP("$")
    BUFFER_IntputNum      DD ?
    BUFFER_OutputNum      DQ ?
    BUFFER_Temporal       DB 40 DUP("$")

    ; Buffer de prueba con la cadena 'Prueba'
    var_Prueba            DB "Prueba", "$"
.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Main procedure
MAIN_CHOSE PROC NEAR PUBLIC
    ; Initialize the data segment
                     MOV  AX, SEG @DATA
                     MOV  DS, AX
                     CALL InitSelection
                     RET
MAIN_CHOSE ENDP

    ; Init the base-N to base-N convertion
InitSelection PROC NEAR PUBLIC

    ; The init of the procedure, could be jumped for other procedures
    _PresentAndInit: 
                     CALL ClearScreen
                     LEA  DX, var_messageWelcome
                     CALL PrintString
                     LEA  DX, var_messageFromBase      ; Ask for the source base
                     CALL PrintString
                     CALL PrintListOfBases             ; Print the list of bases
                     CALL _ReadBaseInput               ; Read the source base

                     CALL ClearScreen
                     LEA  DX, var_messageToBase        ; Ask for the target base
                     CALL PrintString
                     CALL PrintListOfBases             ; Print the list of bases
                     CALL _ReadBaseOutput              ; Read the destination base

                     CALL ClearScreen
                     LEA  DX, var_messageNumber        ; Ask for the number to convert
                     CALL PrintString
                     CALL _ReadNumber                  ; Read the number to convert
                     CALL ValidateNumber               ; Validate the number entered by the user
                     JMP  _Finish                      ; Exit the program

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
                     LEA  DX, BUFFER_IntputStr         ; Prepare the buffer for input
                     MOV  AH, 0Ah
                     INT  21h
    
                     LEA  SI, BUFFER_IntputStr
                     MOV  CL, [SI+1]                   ; CL = number of characters entered
                     ADD  SI, 2                        ; SI points to the first entered character
                     MOV  CH, 0                        ; Clean the high byte of CX
                     ADD  SI, CX                       ; SI points to the byte after the last character
                     DEC  SI                           ; SI points to the last entered character (should be 0Dh)
                     MOV  AL, [SI]
                     CMP  AL, 0Dh
                     JNZ  _Finish                      ; If it's not 0Dh, exit
                     MOV  BYTE PTR [SI], "$"           ; Replace 0Dh with '$'
                     RET

    ; Exit of the Procedure or SubProcedures if they was called (NOT JUMPED)
    _Finish:         
                     RET
InitSelection ENDP

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
                     MOV  CL, [SI + 1]                 ; CL = number of characters entered
                     LEA  SI, BUFFER_IntputStr + 2     ; SI = address of the first character

    _ValidateLoop:   
                     CMP  CL, 0
                     JE   _ValidOK                     ; If there are no more characters, exit

                     MOV  DL, [SI]

                     CMP  BL, 1
                     JE   _CheckBin
                     CMP  BL, 2
                     JE   _CheckOct
                     CMP  BL, 3
                     JE   _CheckDec
                     CMP  BL, 4
                     JE   _CheckHex
                     JMP  _ErrorDigit                  ; If the base is not valid, show error

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

    ; Return the base name based on the value in AX
GetBaseName PROC
                     CMP  AL, 1
                     JE   _BaseBin
                     CMP  AL, 2
                     JE   _BaseOct
                     CMP  AL, 3
                     JE   _BaseDec
                     CMP  AL, 4
                     JE   _BaseHex
                     RET
    _BaseBin:        
                     LEA  AX, var_baseBinary
                     RET
    _BaseOct:        
                     LEA  AX, var_baseOctal
                     RET
    _BaseDec:        
                     LEA  AX, var_baseDecimal
                     RET
    _BaseHex:        
                     LEA  AX, var_baseHexadecimal
                     RET
GetBaseName ENDP

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

    ; Erase the content of the screen
ClearScreen PROC
                     MOV  AH,0
                     MOV  AL,3
                     INT  10h
                     RET
ClearScreen ENDP

END MAIN_CHOSE
