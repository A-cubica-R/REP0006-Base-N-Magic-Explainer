.MODEL small

.STACK 100h

EXTERN ShowAbout:NEAR
EXTERN SelectBase:NEAR
; PUBLIC main

.DATA

    ; For title ON
    var_titleOn1        db " /######    /##    / ##  /##      /##  /########", 13, 10, "$"
    var_titleOn2        db "| #     ## | ###   | ## / ###    /### | ##_____/", 13, 10, "$"
    var_titleOn3        db "| #     ## | ####  | ## | ####  /#### | ##      ", 13, 10, "$"
    var_titleOn4        db "| ##### /  | ## ## | ## | ## ##/## ## | ######  ", 13, 10, "$"
    var_titleOn5        db "| #     ## | ##\ ##| ## | ##  ###| ## | ##      ", 13, 10, "$"
    var_titleOn6        db "| #     ## | ## \ ##### | ##\  # | ## | ##      ", 13, 10, "$"
    var_titleOn7        db "| #######/ | ##  \ #### | ## \/  | ## | ########", 13, 10, "$"
    var_titleOn8        db "|_______/  |__/   \___/ |__/     |__/ |________/", 13, 10, "$"

    ; For tittle OFF
    var_titleOff1       db "                                          ", 13, 10, "$"
    var_titleOff2       db " ######    ##    /##  /#      /## /#######", 13, 10, "$"
    var_titleOff3       db "|#     ## |###   |## /###    /### |##____/", 13, 10, "$"
    var_titleOff4       db "|#     ## |####  |## |####  /#### |##     ", 13, 10, "$"
    var_titleOff5       db "|##### /  |## ## |## |## ##/## ## |###### ", 13, 10, "$"
    var_titleOff6       db "|#     ## |##\ ##|## |##  ###| ## |##     ", 13, 10, "$"
    var_titleOff7       db "|#     ## |## \ #### |##\  # | ## |##     ", 13, 10, "$"
    var_titleOff8       db "|#######/ |##  \ ### |## \/  | ## |#######", 13, 10, "$"

    ; Presentation banner
    var_presentBanner1  db "  ====================================  ",13,10,"$"
    var_presentBanner2  db "  |          UNIT CONVERTER          |  ",13,10,"$"
    var_presentBanner3  db "  |      Base-N Magic Explainer!     |  ",13,10,"$"
    var_presentBanner4  db "  ====================================  ",13,10,"$"

    ; Menu
    var_initMenu1       db "  ####################################  ",13,10,"$"
    var_initMenu2       db "  #  Enter an option (ONLY MAYUS)    #  ",13,10,"$"
    var_initMenu3       db "  #   [A] ABOUT                      #  ",13,10,"$"
    var_initMenu4       db "  #   [C] CONVERT                    #  ",13,10,"$"
    var_initMenu5       db "  ####################################  ",13,10,"$"

    ; Message for selected char
    var_selectedMessage db "Char ' ' selected, press ENTER to continue:",13,10,"$"

    ; Message for select an option
    var_inputMessage    db "Select your choice: $"

    ; Selected character
    BUFFER_charSelected db 0


.CODE

    ; ======= PRINCIPAL PROCEDURES =======

    ; Main procedure
MAIN PROC PUBLIC
                        mov  ax,@data
                        mov  ds,ax
                        jmp  welcome_loop
MAIN ENDP

    ; Show the title types and repeat
Welcome_loop PROC
                        call ShowPresentationON
                        call ShowPresentationOFF
                        jmp  welcome_loop
Welcome_loop ENDP

    ; ======= SECONDARY PROCEDURES =======

    ; Show the title ON, banner, menu and messages
ShowPresentationON PROC
                        call ClearScreen
                        call PrintTitleON
                        call PrintBanner
                        call PrintMenu
                        call DoDelay
                        call CheckKey
                        ret
ShowPresentationON ENDP

    ; Show the title OFF, banner, menu and messages
ShowPresentationOFF PROC
                        call ClearScreen
                        call PrintTitleOFF
                        call PrintBanner
                        call PrintMenu
                        call DoDelay
                        call CheckKey
                        ret
ShowPresentationOFF ENDP

    ; ======= PRINT TITLES =======

    ; Print the title in ON style
PrintTitleON PROC
                        lea  dx, var_titleOn1
                        call PrintString
                        lea  dx, var_titleOn2
                        call PrintString
                        lea  dx, var_titleOn3
                        call PrintString
                        lea  dx, var_titleOn4
                        call PrintString
                        lea  dx, var_titleOn5
                        call PrintString
                        lea  dx, var_titleOn6
                        call PrintString
                        lea  dx, var_titleOn7
                        call PrintString
                        lea  dx, var_titleOn8
                        call PrintString
                        ret
PrintTitleON ENDP

    ; Print the title in OFF style
PrintTitleOFF PROC
                        lea  dx, var_titleOff1
                        call PrintString
                        lea  dx, var_titleOff2
                        call PrintString
                        lea  dx, var_titleOff3
                        call PrintString
                        lea  dx, var_titleOff4
                        call PrintString
                        lea  dx, var_titleOff5
                        call PrintString
                        lea  dx, var_titleOff6
                        call PrintString
                        lea  dx, var_titleOff7
                        call PrintString
                        lea  dx, var_titleOff8
                        call PrintString
                        ret
PrintTitleOff ENDP

    ; ------- PRINT MESSAGES -------

    ; Print the banner
PrintBanner PROC
                        lea  dx, var_presentBanner1
                        call PrintString
                        lea  dx, var_presentBanner2
                        call PrintString
                        lea  dx, var_presentBanner3
                        call PrintString
                        lea  dx, var_presentBanner4
                        call PrintString
                        ret
PrintBanner ENDP

    ; Print the menu and the selection messages
PrintMenu PROC
                        lea  dx, var_initMenu1
                        call PrintString
                        lea  dx, var_initMenu2
                        call PrintString
                        lea  dx, var_initMenu3
                        call PrintString
                        lea  dx, var_initMenu4
                        call PrintString
                        lea  dx, var_initMenu5
                        call PrintString
                        lea  dx, var_selectedMessage
                        call PrintString
                        lea  dx, var_inputMessage
                        call PrintString
                        ret
PrintMenu ENDP

    ; ======= AUX PROCEDURES =======

    ; Do a delay to simulate a 1 second waiting (not exactly)
DoDelay PROC
                        push cx                                    ; Save anything in CX before
                        push bx                                    ; Save anything in BX before

                        mov  bx, 10                                ; Number of bucles (adjustable)
    _OuterLoop:         
                        mov  cx, 0FFFFh                            ; Internal large bucle
    _DelayLoop1:        
                        nop                                        ; Do nothing, just consume time
                        loop _DelayLoop1                           ; Do an internal bucle of CX (not the same as BX counter)
                        dec  bx
                        jnz  _OuterLoop                            ; Jump if BX is not zero
                        pop  bx                                    ; Restore BX to the original value
                        pop  cx                                    ; Restore CX to the original value
                        ret
DoDelay ENDP

    ; Print the value located in DX register
PrintString PROC
                        mov  ah,09h
                        int  21h
                        ret
PrintString ENDP

    ; Check the key inputed by the user and comprobe if is 'A' or 'C'
CheckKey PROC
                        mov  ah, 0Bh                               ; check keyboard without waiting
                        int  21h
                        cmp  al, 0
                        je   _noKey                               ; Jump if any key was pressed

                        mov  ah, 01h                               ; Read the character pressed
                        int  21h                                   ; Return the readed character in AL register
                        cmp  al, 'A'
                        je   _storeChar
                        cmp  al, 'C'
                        je   _storeChar
                        jmp  _noKey

    _storeChar:        
                        mov  [BUFFER_charSelected], al             ; Save in Buffer the value of al
                        mov  byte ptr var_selectedMessage+6, al    ; Edit the position 6 of the message (the space between '')
                        ret                                        ; Return to the caller method (Who called for CheckKey routine?)

    _noKey:            
                        cmp  al, 0Dh                               ; Enter input was pressed?
                        jne  _exitKey                             ; Wasn't pressed, so, exit of the method

                        mov  al, [BUFFER_charSelected]             ; ENTER pressed, Buffer value to al
                        cmp  al, 'A'                               ; It's 'A'? Then Jump
                        je   _doAboutA
                        cmp  al, 'C'                               ; It's 'B'? Then Jump
                        je   _doAboutC

                        call ClearScreen                           ; If It's any other, refresh the screen
                        jmp  Welcome_Loop

    _doAboutA:        
                        call ClearScreen
                        call ShowAbout                             ; EXTERNAL PROCEDURE -> cabout.asm

    _doAboutC:        
                        call ClearScreen
                        call SelectBase                            ; EXTERNAL PROCEDURE -> cselect.asm
    _exitKey:          
                        ret
CheckKey ENDP


    ; Erase the content of the screen
ClearScreen PROC
                        mov  ah,0
                        mov  al,3
                        int  10h
                        ret
ClearScreen ENDP

END MAIN
