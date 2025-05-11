.model small

.stack 100h

EXTERN ShowAbout:NEAR

.data
    ; Title Style A
    title1a     db "  ############################  ",13,10,"$"
    title2a     db "  #   UNIT CONVERTER 8-BIT   #  ",13,10,"$"
    title3a     db "  #       Base-N Magic!      #  ",13,10,"$"
    title4a     db "  ############################  ",13,10,"$"

    ; Title Style B
    title1b     db "  ****************************  ",13,10,"$"
    title2b     db "  *   UNIT CONVERTER 8-BIT   *  ",13,10,"$"
    title3b     db "  *       Base-N Magic!      *  ",13,10,"$"
    title4b     db "  ****************************  ",13,10,"$"

    ; Title Style C
    title1c     db "  ============================  ",13,10,"$"
    title2c     db "  |   UNIT CONVERTER 8-BIT   |  ",13,10,"$"
    title3c     db "  |       Base-N Magic!      |  ",13,10,"$"
    title4c     db "  ============================  ",13,10,"$"

    ; Menu Style A
    menu1a      db "  ############################  ",13,10,"$"
    menu2a      db "  #   [A] ABOUT              #  ",13,10,"$"
    menu3a      db "  #   [C] CONVERT            #  ",13,10,"$"
    menu4a      db "  #                          #  ",13,10,"$"
    menu5a      db "  #  Enter an option (MAYUS) #  ",13,10,"$"
    menu6a      db "  ############################  ",13,10,"$" 

    ; Menu Style B
    menu1b      db "  ****************************  ",13,10,"$"
    menu2b      db "  *   [A] ABOUT              *  ",13,10,"$"
    menu3b      db "  *   [C] CONVERT            *  ",13,10,"$"
    menu4b      db "  *                          *  ",13,10,"$"
    menu5b      db "  *  Enter an option (MAYUS) *  ",13,10,"$"
    menu6b      db "  ****************************  ",13,10,"$"

    ; Menu Style C
    menu1c      db "  ============================  ",13,10,"$"
    menu2c      db "  |   [A] ABOUT              |  ",13,10,"$"
    menu3c      db "  |   [C] CONVERT            |  ",13,10,"$"
    menu4c      db "  |                          |  ",13,10,"$"
    menu5c      db "  |  Enter an option (MAYUS) |  ",13,10,"$"
    menu6c      db "  ============================  ",13,10,"$"

    ; Dynamic line
    selectedMsg db "Char ' ' selected, press ENTER to continue:",13,10,"$"

    ; Prompt message
    prompt      db "Select your choice: $"

    ; Buffer for the selected character
    charBuffer  db 0

.code
main PROC
                        mov  ax,@data
                        mov  ds,ax
                        call menu_animation_loop
main ENDP

menu_animation_loop PROC
                        call ShowWelcomeVariantA
                        call ShowWelcomeVariantB
                        call ShowWelcomeVariantC
                        jmp  menu_animation_loop
menu_animation_loop ENDP

    ; ---------------------------------------------------
    ; Imprimir string
    ; ---------------------------------------------------
PrintString PROC
                        mov  ah,09h
                        int  21h
                        ret
PrintString ENDP

    ; ---------------------------------------------------
    ; Limpiar pantalla
    ; ---------------------------------------------------
ClearScreen PROC
                        mov  ah,0
                        mov  al,3
                        int  10h
                        ret
ClearScreen ENDP

    ; ---------------------------------------------------
    ; Delay
    ; ---------------------------------------------------
Delay PROC
                        push cx
                        mov  cx,0FFFFh
    DelayLoop1:         
                        nop
                        loop DelayLoop1
                        mov  cx,0FFFFh
    DelayLoop2:         
                        nop
                        loop DelayLoop2
                        pop  cx
                        ret
Delay ENDP

    ; ---------------------------------------------------
    ; Variant A
    ; ---------------------------------------------------
ShowWelcomeVariantA PROC
                        call ClearScreen                   ; clear screen
                        lea  dx, title1a                   ; defining the title A
                        call PrintString
                        lea  dx, title2a
                        call PrintString
                        lea  dx, title3a
                        call PrintString
                        lea  dx, title4a
                        call PrintString
                        lea  dx, menu1a                    ; defining the menu A
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
                        lea  dx, selectedMsg               ; Dinamic line for selected character
                        call PrintString
                        lea  dx, prompt                    ; write line for the user
                        call PrintString
                        call Delay                         ; delay for a while
                        call CheckKey                      ; check if the correct key was pressed
                        ret
ShowWelcomeVariantA ENDP

    ; ---------------------------------------------------
    ; Variant B
    ; ---------------------------------------------------
ShowWelcomeVariantB PROC
                        call ClearScreen                   ; clear screen
                        lea  dx, title1b                   ; defining the title B
                        call PrintString
                        lea  dx, title2b
                        call PrintString
                        lea  dx, title3b
                        call PrintString
                        lea  dx, title4b
                        call PrintString
                        lea  dx, menu1b                    ; defining the menu B
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
                        lea  dx, selectedMsg               ; Dinamic line for selected character
                        call PrintString
                        lea  dx, prompt                    ; write line for the user
                        call PrintString
                        call Delay                         ; delay for a while
                        call CheckKey                      ; check if the correct key was pressed
                        ret
ShowWelcomeVariantB ENDP

    ; ---------------------------------------------------
    ; Variant C
    ; ---------------------------------------------------
ShowWelcomeVariantC PROC
                        call ClearScreen                   ; clear screen
                        lea  dx, title1c                   ; defining the title C
                        call PrintString
                        lea  dx, title2c
                        call PrintString
                        lea  dx, title3c
                        call PrintString
                        lea  dx, title4c
                        call PrintString
                        lea  dx, menu1c                    ; defining the menu C
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
                        lea  dx, selectedMsg               ; Dinamic line for selected character
                        call PrintString
                        lea  dx, prompt                    ; write line for the user
                        call PrintString
                        call Delay                         ; delay for a while
                        call CheckKey                      ; check if the correct key was pressed
                        ret
ShowWelcomeVariantC ENDP

    ; ---------------------------------------------------
    ; CheckKey con etiquetas locales
    ; ---------------------------------------------------
CheckKey PROC
                        mov  ah, 0Bh                       ; check keyboard without waiting
                        int  21h
                        cmp  al, 0
                        je   no_key

                        mov  ah, 01h                       ; leer tecla (espera si no hay)
                        int  21h                           ; AL = carácter leído
                        cmp  al, 'A'
                        je   store_char
                        cmp  al, 'C'
                        je   store_char
                        jmp  no_key

    store_char:         
                        mov  [charBuffer], al
                        mov  byte ptr selectedMsg+6, al
                        ret                                ; vuelve al bucle principal

    no_key:             
                        cmp  al, 0Dh                       ; ¿Enter?
                        jne  exit_key

    ; Si llegamos aquí, se pulsó Enter:
                        mov  al, [charBuffer]
                        cmp  al, 'A'
                        je   do_about_a
                        cmp  al, 'C'
                        je   valid_exit

    ; cualquier otra, repintar menú
                        call ClearScreen
                        jmp  menu_animation_loop

    do_about_a:         
                        call ClearScreen
                        call ShowAbout

    valid_exit:         
                        lea  dx, selectedMsg
                        call PrintString
                        mov  ah, 4Ch
                        int  21h

    exit_key:           
                        ret
CheckKey ENDP

end main
