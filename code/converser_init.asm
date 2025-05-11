.model small

.stack 100h

EXTERN ShowAbout:NEAR

.data

    titleOn1    db " /######    /##    / ##  /##      /##  /########", 13, 10, "$"
    titleOn2    db "| #     ## | ###   | ## / ###    /### | ##_____/", 13, 10, "$"
    titleOn3    db "| #     ## | ####  | ## | ####  /#### | ##      ", 13, 10, "$"
    titleOn4    db "| ##### /  | ## ## | ## | ## ##/## ## | ######  ", 13, 10, "$"
    titleOn5    db "| #     ## | ##\ ##| ## | ##  ###| ## | ##      ", 13, 10, "$"
    titleOn6    db "| #     ## | ## \ ##### | ##\  # | ## | ##      ", 13, 10, "$"
    titleOn7    db "| #######/ | ##  \ #### | ## \/  | ## | ########", 13, 10, "$"
    titleOn8    db "|_______/  |__/   \___/ |__/     |__/ |________/", 13, 10, "$"

    titleOff1   db "                                          ", 13, 10, "$"
    titleOff2   db " ######    ##    /##  /#      /## /#######", 13, 10, "$"
    titleOff3   db "|#     ## |###   |## /###    /### |##____/", 13, 10, "$"
    titleOff4   db "|#     ## |####  |## |####  /#### |##     ", 13, 10, "$"
    titleOff5   db "|##### /  |## ## |## |## ##/## ## |###### ", 13, 10, "$"
    titleOff6   db "|#     ## |##\ ##|## |##  ###| ## |##     ", 13, 10, "$"
    titleOff7   db "|#     ## |## \ #### |##\  # | ## |##     ", 13, 10, "$"
    titleOff8   db "|#######/ |##  \ ### |## \/  | ## |#######", 13, 10, "$"

    ; Title Style C
    descript0   db "  ====================================  ",13,10,"$"
    descript1   db "  |          UNIT CONVERTER          |  ",13,10,"$"
    descript2   db "  |      Base-N Magic Explainer!     |  ",13,10,"$"
    descript3   db "  ====================================  ",13,10,"$"

    ; Menu Style A
    dmenu0      db "  ####################################  ",13,10,"$"
    dmenu1      db "  #  Enter an option (ONLY MAYUS)    #  ",13,10,"$"
    dmenu2      db "  #   [A] ABOUT                      #  ",13,10,"$"
    dmenu3      db "  #   [C] CONVERT                    #  ",13,10,"$"
    dmenu4      db "  ####################################  ",13,10,"$"

    selectedMsg db "Char ' ' selected, press ENTER to continue:",13,10,"$"

    prompt      db "Select your choice: $"

    charBuffer  db 0

.code
main PROC
                  mov  ax,@data
                  mov  ds,ax
                  call welcome_loop
main ENDP

welcome_loop PROC
                  call PrintTitleOn
                  call PrintTitleOff
                  jmp  welcome_loop
welcome_loop ENDP

Delay PROC
                  push cx
                  push bx

                  mov  bx, 10                        ; Número de bucles externos (ajustable)
    OuterLoop:    
                  mov  cx, 0FFFFh                    ; Bucle interno largo
    DelayLoop1:   
                  nop
                  loop DelayLoop1
                  dec  bx
                  jnz  OuterLoop
                  pop  bx
                  pop  cx
                  ret
Delay ENDP


Wait1Second PROC
                  mov  ah, 86h                       ; Función BIOS: esperar tiempo
                  mov  cx, 0h                        ; Alto de milisegundos
                  mov  dx, 1000                      ; 1000 ms = 1 segundo
                  int  15h
                  ret
Wait1Second ENDP


    ;=====================
    ;Show the welcome
    ;=====================

PrintTitleOn PROC
                  call ClearScreen
                  lea  dx, titleOn1
                  call PrintString
                  lea  dx, titleOn2
                  call PrintString
                  lea  dx, titleOn3
                  call PrintString
                  lea  dx, titleOn4
                  call PrintString
                  lea  dx, titleOn5
                  call PrintString
                  lea  dx, titleOn6
                  call PrintString
                  lea  dx, titleOn7
                  call PrintString
                  lea  dx, titleOn8
                  call PrintString
                  call PrintDescript
                  call PrintMenu
                  call Delay
                  call CheckKey
                  ret
PrintTitleOn ENDP

PrintTitleOff PROC
                  call ClearScreen
                  lea  dx, titleOff1
                  call PrintString
                  lea  dx, titleOff2
                  call PrintString
                  lea  dx, titleOff3
                  call PrintString
                  lea  dx, titleOff4
                  call PrintString
                  lea  dx, titleOff5
                  call PrintString
                  lea  dx, titleOff6
                  call PrintString
                  lea  dx, titleOff7
                  call PrintString
                  lea  dx, titleOff8
                  call PrintString
                  call PrintDescript
                  call PrintMenu
                  call Delay
                  call CheckKey
                  ret
PrintTitleOff ENDP

PrintDescript PROC
                  lea  dx, descript0
                  call PrintString
                  lea  dx, descript1
                  call PrintString
                  lea  dx, descript2
                  call PrintString
                  lea  dx, descript3
                  call PrintString
                  ret
PrintDescript ENDP

PrintMenu PROC
                  lea  dx, dmenu0
                  call PrintString
                  lea  dx, dmenu1
                  call PrintString
                  lea  dx, dmenu2
                  call PrintString
                  lea  dx, dmenu3
                  call PrintString
                  lea  dx, dmenu4
                  call PrintString
                  lea  dx, selectedMsg
                  call PrintString
                  lea  dx, prompt
                  call PrintString
                  ret
PrintMenu ENDP
                        
    ;=====================
    ; Auxiliar methods
    ;=====================
PrintString PROC
                  mov  ah,09h
                  int  21h
                  ret
PrintString ENDP

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
                  jmp  welcome_loop

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

ClearScreen PROC
                  mov  ah,0
                  mov  al,3
                  int  10h
                  ret
ClearScreen ENDP

end main
