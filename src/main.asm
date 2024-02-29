org 0x7C00

%define SCREEN_WIDTH 80
%define SCREEN_HEIGHT 25

%define VIDEO_MEM_ADDR 0x0B800
%define TIMER_ADDR 0x046C

%define PLAYER_HEIGHT 4
%define PLAYER_X 4

%define BOT_HEIGHT 4
%define BOT_X 156

%define BALL_HEIGHT 1
%define BALL_WIDTH 1
%define BALL_INITIAL_X 64
%define BALL_INITIAL_Y 16
%define BALL_VEL_Y 1
%define BALL_VEL_X 2


%define KEY_R 0x72
%define KEY_SPACE 0x20
%define KEY_W 'w'
%define KEY_S 's'

; Colors reference (https://wiki.osdev.org/Text_UI)
%define BLACK 0x0
%define WHITE 0x0F0 ; This means fg is white and bg is black

section .data
    player_y dw 12
    bot_y dw 16

    ball_x dw BALL_INITIAL_X
    ball_y dw BALL_INITIAL_Y

entry:
    mov ax, 0x3
    int 0x13

    mov ax, VIDEO_MEM_ADDR ; Video memory starts at 0xB8000 for color text mode (0x3)
    mov es, ax

game_loop:
    xor ax, ax
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
    rep stosw

    ; Draw Player
    mov ah, WHITE
    imul di, [player_y], SCREEN_WIDTH * 2
    mov cl, PLAYER_HEIGHT
    .loop_draw_player:
        mov [es:di + PLAYER_X], ax
        add di, SCREEN_WIDTH * 2
        loop .loop_draw_player

    ; Draw Bot
    imul di, [bot_y], SCREEN_WIDTH * 2
    mov cl, BOT_HEIGHT
    .loop_draw_bot:
        mov [es:di + BOT_X], ax
        add di, SCREEN_WIDTH * 2
        loop .loop_draw_bot

    ; Draw Ball
    imul di, [ball_y], SCREEN_WIDTH * 2
    add di, [ball_x]
    stosw

    ; Input
    .input_loop:
        hlt
        mov ah, 1
        int 0x16
        jz .input_loop

        xor ah, ah
        int 0x16

        cmp al, 'w'
        jz .move_up

        cmp al, 's'
        jz .move_down

        cmp al, 'r'
        jz .game_restart

        jmp .input_loop

        .move_up:
            cmp word [player_y], 0
            jle .input_loop

            dec word [player_y]
            jmp entry

        .move_down:
            cmp word [player_y], SCREEN_HEIGHT - PLAYER_HEIGHT
            jge .input_loop

            inc word [player_y]
            jmp entry

        .game_restart:
            int 0x19

    ; Move Ball / Check Collision
    

    mov bx, [TIMER_ADDR] ; # of IRQ0 timer ticks since boot [https://wiki.osdev.org/Memory_Map_(x86)]
    add bx, 2
    .delay:
        cmp [TIMER_ADDR], bx
        jl .delay

    jmp game_loop

move_cpu:

times 510-($-$$) db 0 ; Padding
dw 0xAA55 ; Signature