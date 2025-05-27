.MODEL small

EXTERN BUFFER_OutBase:NEAR
EXTERN SUBMAIN_OB:NEAR
EXTERN SUBMAIN_OO:NEAR
EXTERN SUBMAIN_OD:NEAR
EXTERN SUBMAIN_OH:NEAR

.DATA
    ; Util printing
    var_newLine DB 13, 10, "$"
.CODE
MAIN_XPLN_O PROC NEAR PUBLIC
                       CALL ClearScreen
                       CALL StrBaseToNum_xplno

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
                       CALL OxplnB
                       JMP  _FinishMain

    _ExplainForOCT:    
                       CALL OxplnO
                       JMP  _FinishMain

    _ExplainForDEC:    
                       CALL OxplnD
                       JMP  _FinishMain

    _ExplainForHEX:    
                       CALL OxplnH
                       JMP  _FinishMain

    _FinishMain:       
                       RET

MAIN_XPLN_O ENDP

    ; Save the inputed base number in AL
StrBaseToNum_xplno PROC
                       LEA  SI, BUFFER_OutBase
                       MOV  AL, [SI + 2]
                       SUB  AL, '0'
                       RET
StrBaseToNum_xplno ENDP

    ; ======= EXPLICATEURS PROCEDURES =======

    ; Explanation for Binary to Binary
OxplnB PROC
                       CALL SUBMAIN_OB
                       RET
OxplnB ENDP

    ; Explanation for Binary to Octal
OxplnO PROC
                       CALL SUBMAIN_OO
                       RET
OxplnO ENDP

    ; Explanation for Binary to Decimal
OxplnD PROC
                       CALL SUBMAIN_OD
                       RET
OxplnD ENDP

    ; Explanation for Binary to Hexadecimal
OxplnH PROC
                       CALL SUBMAIN_OH
                       RET
OxplnH ENDP

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

END MAIN_XPLN_O