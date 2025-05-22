.MODEL small

.STACK 100h

EXTERN ShowAbout:NEAR
EXTERN SelectBase:NEAR
; PUBLIC main

.DATA

    ; For title ON
    var_titleOn1        DB " /######    /##    / ##  /##      /##  /########", 13, 10, "$"
    var_titleOn2        DB "| #     ## | ###   | ## / ###    /### | ##_____/", 13, 10, "$"
    var_titleOn3        DB "| #     ## | ####  | ## | ####  /#### | ##      ", 13, 10, "$"
    var_titleOn4        DB "| ##### /  | ## ## | ## | ## ##/## ## | ######  ", 13, 10, "$"
    var_titleOn5        DB "| #     ## | ##\ ##| ## | ##  ###| ## | ##      ", 13, 10, "$"
    var_titleOn6        DB "| #     ## | ## \ ##### | ##\  # | ## | ##      ", 13, 10, "$"
    var_titleOn7        DB "| #######/ | ##  \ #### | ## \/  | ## | ########", 13, 10, "$"
    var_titleOn8        DB "|_______/  |__/   \___/ |__/     |__/ |________/", 13, 10, "$"

    ; For tittle OFF
    var_titleOff1       DB "                                          ", 13, 10, "$"
    var_titleOff2       DB " ######    ##    /##  /#      /## /#######", 13, 10, "$"
    var_titleOff3       DB "|#     ## |###   |## /###    /### |##____/", 13, 10, "$"
    var_titleOff4       DB "|#     ## |####  |## |####  /#### |##     ", 13, 10, "$"
    var_titleOff5       DB "|##### /  |## ## |## |## ##/## ## |###### ", 13, 10, "$"
    var_titleOff6       DB "|#     ## |##\ ##|## |##  ###| ## |##     ", 13, 10, "$"
    var_titleOff7       DB "|#     ## |## \ #### |##\  # | ## |##     ", 13, 10, "$"
    var_titleOff8       DB "|#######/ |##  \ ### |## \/  | ## |#######", 13, 10, "$"

    ; Presentation banner
    var_presentBanner1  DB "  ====================================  ",13,10,"$"
    var_presentBanner2  DB "  |          UNIT CONVERTER          |  ",13,10,"$"
    var_presentBanner3  DB "  |      Base-N Magic Explainer!     |  ",13,10,"$"
    var_presentBanner4  DB "  ====================================  ",13,10,"$"

    ; Menu
    var_initMenu1       DB "  ####################################  ",13,10,"$"
    var_initMenu2       DB "  #  Enter an option (ONLY MAYUS)    #  ",13,10,"$"
    var_initMenu3       DB "  #   [A] ABOUT                      #  ",13,10,"$"
    var_initMenu4       DB "  #   [C] CONVERT                    #  ",13,10,"$"
    var_initMenu5       DB "  ####################################  ",13,10,"$"

    ; Message for selected char
    var_selectedMessage DB "Char ' ' selected, press ENTER to continue:",13,10,"$"

    ; Message for select an option
    var_inputMessage    DB "Select your choice: $"

    ; Selected character
    BUFFER_charSelected DB 0


.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Main procedure
MAIN PROC PUBLIC
                        MOV  AX,@data
                        MOV  DS,AX
                        JMP  welcome_loop
MAIN ENDP

    ; Show the title types and repeat
Welcome_loop PROC
                        CALL ShowPresentationON
                        CALL ShowPresentationOFF
                        JMP  welcome_loop
Welcome_loop ENDP

    ; ======= SECONDARY PROCEDURES =======

    ; Show the title ON, banner, menu and messages
ShowPresentationON PROC
                        CALL ClearScreen
                        CALL PrintTitleON
                        CALL PrintBanner
                        CALL PrintMenu
                        CALL DoDelay
                        CALL CheckKey
                        RET
ShowPresentationON ENDP

    ; Show the title OFF, banner, menu and messages
ShowPresentationOFF PROC
                        CALL ClearScreen
                        CALL PrintTitleOFF
                        CALL PrintBanner
                        CALL PrintMenu
                        CALL DoDelay
                        CALL CheckKey
                        RET
ShowPresentationOFF ENDP

    ; ======= PRINT TITLES =======

    ; Print the title in ON style
PrintTitleON PROC
                        LEA  DX, var_titleOn1
                        CALL PrintString
                        LEA  DX, var_titleOn2
                        CALL PrintString
                        LEA  DX, var_titleOn3
                        CALL PrintString
                        LEA  DX, var_titleOn4
                        CALL PrintString
                        LEA  DX, var_titleOn5
                        CALL PrintString
                        LEA  DX, var_titleOn6
                        CALL PrintString
                        LEA  DX, var_titleOn7
                        CALL PrintString
                        LEA  DX, var_titleOn8
                        CALL PrintString
                        RET
PrintTitleON ENDP

    ; Print the title in OFF style
PrintTitleOFF PROC
                        LEA  DX, var_titleOff1
                        CALL PrintString
                        LEA  DX, var_titleOff2
                        CALL PrintString
                        LEA  DX, var_titleOff3
                        CALL PrintString
                        LEA  DX, var_titleOff4
                        CALL PrintString
                        LEA  DX, var_titleOff5
                        CALL PrintString
                        LEA  DX, var_titleOff6
                        CALL PrintString
                        LEA  DX, var_titleOff7
                        CALL PrintString
                        LEA  DX, var_titleOff8
                        CALL PrintString
                        RET
PrintTitleOff ENDP

    ; ------- PRINT MESSAGES -------

    ; Print the banner
PrintBanner PROC
                        LEA  DX, var_presentBanner1
                        CALL PrintString
                        LEA  DX, var_presentBanner2
                        CALL PrintString
                        LEA  DX, var_presentBanner3
                        CALL PrintString
                        LEA  DX, var_presentBanner4
                        CALL PrintString
                        RET
PrintBanner ENDP

    ; Print the menu and the selection messages
PrintMenu PROC
                        LEA  DX, var_initMenu1
                        CALL PrintString
                        LEA  DX, var_initMenu2
                        CALL PrintString
                        LEA  DX, var_initMenu3
                        CALL PrintString
                        LEA  DX, var_initMenu4
                        CALL PrintString
                        LEA  DX, var_initMenu5
                        CALL PrintString
                        LEA  DX, var_selectedMessage
                        CALL PrintString
                        LEA  DX, var_inputMessage
                        CALL PrintString
                        RET
PrintMenu ENDP

    ; ======= AUX PROCEDURES =======

    ; Do a delay to simulate a 1 second waiting (not exactly)
DoDelay PROC
                        PUSH CX                                    ; Save anything in CX before
                        PUSH BX                                    ; Save anything in BX before

                        MOV  BX, 10                                ; Number of bucles (adjustable)
    _OuterLoop:         
                        MOV  CX, 0FFFFh                            ; Internal large bucle
    _DelayLoop1:        
                        NOP                                        ; Do nothing, just consume time
                        LOOP _DelayLoop1                           ; Do an internal bucle of CX (not the same as BX counter)
                        DEC  BX
                        JNZ  _OuterLoop                            ; Jump if BX is not zero
                        POP  BX                                    ; Restore BX to the original value
                        POP  CX                                    ; Restore CX to the original value
                        RET
DoDelay ENDP

    ; Check the key inputed by the user and comprobe if is 'A' or 'C'
CheckKey PROC
                        MOV  AH, 0Bh                               ; check keyboard without waiting
                        INT  21h
                        CMP  AL, 0
                        JE   _noKey                                ; Jump if any key was pressed

                        MOV  AH, 01h                               ; Read the character pressed
                        INT  21h                                   ; Return the readed character in AL register
                        CMP  AL, 'A'
                        JE   _storeChar
                        CMP  AL, 'C'
                        JE   _storeChar
                        JMP  _noKey

    _storeChar:         
                        MOV  [BUFFER_charSelected], AL             ; Save in Buffer the value of al
                        MOV  BYTE PTR var_selectedMessage+6, AL    ; Edit the position 6 of the message (the space between '')
                        RET                                        ; Return to the caller method (Who called for CheckKey routine?)

    _noKey:             
                        CMP  AL, 0Dh                               ; Enter input was pressed?
                        JNE  _exitKey                              ; Wasn't pressed, so, exit of the method

                        MOV  AL, [BUFFER_charSelected]             ; ENTER pressed, Buffer value to al
                        CMP  AL, 'A'                               ; It's 'A'? Then Jump
                        JE   _doAboutA
                        CMP  AL, 'C'                               ; It's 'B'? Then Jump
                        JE   _doAboutC

                        CALL ClearScreen                           ; If It's any other, refresh the screen
                        JMP  Welcome_Loop

    _doAboutA:          
                        CALL ClearScreen
                        CALL ShowAbout                             ; EXTERNAL PROCEDURE -> cabout.asm

    _doAboutC:          
                        CALL ClearScreen
                        CALL SelectBase                            ; EXTERNAL PROCEDURE -> cselect.asm
    _exitKey:           
                        RET
CheckKey ENDP

    ; Print the value located in DX register
PrintString PROC
                        MOV  AH,09h
                        INT  21h
                        RET
PrintString ENDP

    ; Erase the content of the screen
ClearScreen PROC
                        MOV  AH,0
                        MOV  AL,3
                        INT  10h
                        RET
ClearScreen ENDP

END MAIN
