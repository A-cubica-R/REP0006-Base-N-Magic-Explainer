.MODEL small

EXTERN BUFFER_IntputStr:NEAR
EXTERN BUFFER_OutBase:NEAR

.DATA
    var_newLine DB 13, 10, "$"
.CODE
MAIN_XPLN_H PROC NEAR PUBLIC
                       CALL ClearScreen
                       CALL StrBaseToNum_xplnh

                       CMP  AL, 1
                       JE   _ExplainForBIN
                       CMP  AL, 2
                       JE   _ExplainForOCT
                       CMP  AL, 3
                       JE   _ExplainForDEC
                       CMP  AL, 4
                       JE   _ExplainForHEX
                       JMP  _FinishMain


    _ExplainForBIN:    
                       CALL HxplnB
                       JMP  _FinishMain

    _ExplainForOCT:    
                       CALL HxplnO
                       JMP  _FinishMain

    _ExplainForDEC:    
                       CALL HxplnD
                       JMP  _FinishMain

    _ExplainForHEX:    
                       CALL HxplnH
                       JMP  _FinishMain

    _FinishMain:       
                       RET

MAIN_XPLN_H ENDP

    ; Save the inputed base number in AL
StrBaseToNum_xplnh PROC
                       LEA  SI, BUFFER_OutBase
                       MOV  AL, [SI + 2]
                       SUB  AL, '0'
                       RET
StrBaseToNum_xplnh ENDP

    ; ======= EXPLICATEURS PROCEDURES =======

    ; Explanation for Binary to Binary
HxplnB PROC
                       RET
HxplnB ENDP

    ; Explanation for Binary to Octal
HxplnO PROC
                       RET
HxplnO ENDP

    ; Explanation for Binary to Decimal
HxplnD PROC
                       RET
HxplnD ENDP

    ; Explanation for Binary to Hexadecimal
HxplnH PROC
                       RET
HxplnH ENDP

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

END MAIN_XPLN_H