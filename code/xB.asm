.MODEL small

EXTERN BUFFER_OutBase:NEAR
EXTERN SUBMAIN_BB:NEAR
EXTERN SUBMAIN_BO:NEAR
EXTERN SUBMAIN_BD:NEAR
EXTERN SUBMAIN_BH:NEAR

.DATA
    var_newLine DB 13, 10, "$"

.CODE
MAIN_XPLN_B PROC NEAR PUBLIC
                       CALL ClearScreen
                       CALL StrBaseToNum_xplnb

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
                       CALL BxplnB
                       JMP  _FinishMain

    _ExplainForOCT:    
                       CALL BxplnO
                       JMP  _FinishMain

    _ExplainForDEC:    
                       CALL BxplnD
                       JMP  _FinishMain

    _ExplainForHEX:    
                       CALL BxplnH
                       JMP  _FinishMain

    _FinishMain:       
                       RET

MAIN_XPLN_B ENDP

    ; Save the inputed base number in AL
StrBaseToNum_xplnb PROC
                       LEA  SI, BUFFER_OutBase
                       MOV  AL, [SI + 2]
                       SUB  AL, '0'
                       RET
StrBaseToNum_xplnb ENDP

    ; ======= EXPLICATEURS PROCEDURES =======

    ; Explanation for Binary to Binary
BxplnB PROC
                       CALL SUBMAIN_BB
                       RET
BxplnB ENDP

    ; Explanation for Binary to Octal
BxplnO PROC
                       CALL SUBMAIN_BO
                       RET
BxplnO ENDP

    ; Explanation for Binary to Decimal
BxplnD PROC
                       CALL SUBMAIN_BD
                       RET
BxplnD ENDP

    ; Explanation for Binary to Hexadecimal
BxplnH PROC
                       CALL SUBMAIN_BH
                       RET
BxplnH ENDP

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

END MAIN_XPLN_B