org 0x7C00

%define SCREEN_WIDTH 80
%define SCREEN_HEIGHT 25

%define PLAYER_HEIGHT 4
%define PLAYER_X 4

%define BOT_HEIGHT 4
%define BOT_X 156

%define BALL_HEIGHT 1
%define BALL_WIDTH 1

; Colors reference (https://wiki.osdev.org/Text_UI)
%define BLACK 0x0
%define WHITE 0x0F0 ; This means fg is white and bg is black

section .data
    player_y dw 1
    bot_y dw 16

    ball_x dw 64
    ball_y dw 16

entry:
    mov ax, 0x3
    int 0x13

    mov ax, 0x0B800 ; Video memory starts at 0xB8000 for color text mode (0x3)
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

    imul di, [ball_y], SCREEN_WIDTH * 2
    add di, [ball_x]
    
    ; Input
    .input_loop:
        hlt
        mov ah, 1
        int 0x16
        jz .input_loop

        cmp al, 'w'
        je .move_up

        cmp al, 's'
        je .move_down

        .move_up:
            inc word [player_y]
            jmp move_cpu

        .move_down:
            dec word [player_y]
            jmp move_cpu

    ; Delay
    mov bx, [0x046C] ; # of IRQ0 timer ticks since boot [https://wiki.osdev.org/Memory_Map_(x86)]
    inc bx
    inc bx
    .delay:
        cmp [0x046C], bx
        jl .delay

    jmp game_loop

move_cpu:

times 510-($-$$) db 0 ; Padding
dw 0xAA55 ; Signature