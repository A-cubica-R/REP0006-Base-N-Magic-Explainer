.model small
.stack 100h

.data

    ; ---------------------------------------------------
    ; Títulos Style A
    ; ---------------------------------------------------
    title1a     db "  ############################  ",13,10,"$"
    title2a     db "  #   UNIT CONVERTER 8-BIT   #  ",13,10,"$"
    title3a     db "  #       Base-N Magic!      #  ",13,10,"$"
    title4a     db "  ############################  ",13,10,"$"

    ; ---------------------------------------------------
    ; Títulos Style B
    ; ---------------------------------------------------
    title1b     db "  ****************************  ",13,10,"$"
    title2b     db "  *   UNIT CONVERTER 8-BIT   *  ",13,10,"$"
    title3b     db "  *       Base-N Magic!      *  ",13,10,"$"
    title4b     db "  ****************************  ",13,10,"$"

    ; ---------------------------------------------------
    ; Títulos Style C
    ; ---------------------------------------------------
    title1c     db "  ============================  ",13,10,"$"
    title2c     db "  |   UNIT CONVERTER 8-BIT   |  ",13,10,"$"
    title3c     db "  |       Base-N Magic!      |  ",13,10,"$"
    title4c     db "  ============================  ",13,10,"$"

    ; ---------------------------------------------------
    ; Menús Style A
    ; ---------------------------------------------------
    menu1a      db "  ############################  ",13,10,"$"
    menu2a      db "  #   [A] ABOUT              #  ",13,10,"$"
    menu3a      db "  #   [C] CONVERT            #  ",13,10,"$"
    menu4a      db "  #                          #  ",13,10,"$"
    menu5a      db "  #  Enter an option (MAYUS) #  ",13,10,"$"
    menu6a      db "  ############################  ",13,10,"$"

    ; ---------------------------------------------------
    ; Menús Style B
    ; ---------------------------------------------------
    menu1b      db "  ****************************  ",13,10,"$"
    menu2b      db "  *   [A] ABOUT              *  ",13,10,"$"
    menu3b      db "  *   [C] CONVERT            *  ",13,10,"$"
    menu4b      db "  *                          *  ",13,10,"$"
    menu5b      db "  *  Enter an option (MAYUS) *  ",13,10,"$"
    menu6b      db "  ****************************  ",13,10,"$"

    ; ---------------------------------------------------
    ; Menús Style C
    ; ---------------------------------------------------
    menu1c      db "  ============================  ",13,10,"$"
    menu2c      db "  |   [A] ABOUT              |  ",13,10,"$"
    menu3c      db "  |   [C] CONVERT            |  ",13,10,"$"
    menu4c      db "  |                          |  ",13,10,"$"
    menu5c      db "  |  Enter an option (MAYUS) |  ",13,10,"$"
    menu6c      db "  ============================  ",13,10,"$"

    ; ---------------------------------------------------
    ; Dynamic line
    ; ---------------------------------------------------
    selectedMsg db "Char ' ' selected, press ENTER to continue:",13,10,"$"

    ; ---------------------------------------------------
    ; Prompt message
    ; ---------------------------------------------------
    prompt      db "Select your choice: $"

    ; ---------------------------------------------------
    ; Buffer for the selected character
    ; ---------------------------------------------------
    charBuffer  db 0

.code
    main:               
                        mov  ax, @data
                        mov  ds, ax

    menu_animation_loop:
    ; === Style A ===
                        call ClearScreen

                        lea  dx, title1a
                        call PrintString
                        lea  dx, title2a
                        call PrintString
                        lea  dx, title3a
                        call PrintString
                        lea  dx, title4a
                        call PrintString

                        lea  dx, menu1a
                        call PrintString
                        lea  dx, menu2a
                        call PrintString
                        lea  dx, menu3a
                        call PrintString
                        lea  dx, menu4a
                        call PrintString
                        lea  dx, menu5a
                        call PrintString
                        lea  dx, menu6a
                        call PrintString

    ; Dinamic line
    ; "Char 'X' selected..."
                        lea  dx, selectedMsg
                        call PrintString

    ; prompt
                        lea  dx, prompt
                        call PrintString

                        call Delay
                        call CheckKey

    ; === Style B ===
                        call ClearScreen

                        lea  dx, title1b
                        call PrintString
                        lea  dx, title2b
                        call PrintString
                        lea  dx, title3b
                        call PrintString
                        lea  dx, title4b
                        call PrintString

                        lea  dx, menu1b
                        call PrintString
                        lea  dx, menu2b
                        call PrintString
                        lea  dx, menu3b
                        call PrintString
                        lea  dx, menu4b
                        call PrintString
                        lea  dx, menu5b
                        call PrintString
                        lea  dx, menu6b
                        call PrintString

    ; Dinamic line
                        lea  dx, selectedMsg
                        call PrintString

    ; prompt
                        lea  dx, prompt
                        call PrintString

                        call Delay
                        call CheckKey

    ; === Style C ===
                        call ClearScreen

                        lea  dx, title1c
                        call PrintString
                        lea  dx, title2c
                        call PrintString
                        lea  dx, title3c
                        call PrintString
                        lea  dx, title4c
                        call PrintString

                        lea  dx, menu1c
                        call PrintString
                        lea  dx, menu2c
                        call PrintString
                        lea  dx, menu3c
                        call PrintString
                        lea  dx, menu4c
                        call PrintString
                        lea  dx, menu5c
                        call PrintString
                        lea  dx, menu6c
                        call PrintString

    ; Dinamic line
                        lea  dx, selectedMsg
                        call PrintString

    ; prompt
                        lea  dx, prompt
                        call PrintString

                        call Delay
                        call CheckKey

                        jmp  menu_animation_loop           ; infinitely loop

    ; ---------------------------------------------------
    ; Subroutines
    ; ---------------------------------------------------
    PrintString:        
                        mov  ah, 09h
                        int  21h
                        ret

    ClearScreen:        
                        mov  ah, 0
                        mov  al, 3
                        int  10h
                        ret

    Delay:              
                        push cx
                        mov  cx, 0FFFFh
    DelayLoop1:         
                        nop
                        loop DelayLoop1
                        mov  cx, 0FFFFh
    DelayLoop2:         
                        nop
                        loop DelayLoop2
                        pop  cx
                        ret

    ; ---------------------------------------------------
    ; CheckKey:
    ;  - Only accepts A or C.
    ;  - On ENTER, validates the buffer:
    ;      * if it's A/C → prints selectedMsg + exits.
    ;      * if not      → clears the screen and restarts the animation.
    ;  - When storing A/C, updates selectedMsg[6].
    ; ---------------------------------------------------
    CheckKey:           
                        mov  ah, 0Bh                       ; test keyboard without waiting
                        int  21h
                        cmp  al, 0
                        je   .no_key

                        mov  ah, 01h                       ; read character (blocking if buffer)
                        int  21h                           ; AL = key

                        cmp  al, 'A'
                        je   .store_char
                        cmp  al, 'C'
                        je   .store_char
    ; not A/C → ignore
                        jmp  .no_key

.store_char:
                        mov  [charBuffer], al
    ; update the dynamic message at position 6
    ; "Char 'X' selected..."
                        mov  byte ptr selectedMsg+6, al
                        ret

.no_key:
                        cmp  al, 0Dh                       ; Check if it was ENTER
                        jne  .exit_key                     ; if not, return normally

                        mov  al, [charBuffer]              ; It was ENTER: validate buffer
                        cmp  al, 'A'
                        je   .valid_exit
                        cmp  al, 'C'
                        je   .valid_exit

    ; ENTER + invalid buffer → restart “animation”
                        call ClearScreen
                        jmp  menu_animation_loop

.valid_exit:
    ; ENTER + valid buffer → print dynamic line and exit
                        lea  dx, selectedMsg
                        call PrintString

                        mov  ah, 4Ch
                        int  21h

.exit_key:
                        ret

end main
