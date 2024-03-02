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

%define BALL_INITIAL_X 78
%define BALL_INITIAL_Y 12

%define BALL_VEL_Y 1
%define BALL_VEL_X -2

%define KEY_R 0x72
%define KEY_SPACE 0x20
%define KEY_W 'w'
%define KEY_S 's'

; Colors reference (https://wiki.osdev.org/Text_UI)
%define BLACK 0x00
%define GRAY 0x80
%define WHITE 0xF0

section .data
    player_y dw 12
    bot_y dw 12

    player_score dw 0
    bot_score dw 0

    ball_x dw BALL_INITIAL_X
    ball_y dw BALL_INITIAL_Y

    ball_vel_x db BALL_VEL_X
    ball_vel_y db BALL_VEL_Y

entry:
    mov ax, 0x3
    int 0x13

    mov ax, VIDEO_MEM_ADDR ; Video memory starts at 0xB8000 for this (0x3) mode
    mov es, ax

game_loop:
    xor ax, ax
    xor di, di
    mov cx, SCREEN_WIDTH * SCREEN_HEIGHT
    rep stosw

    mov ah, GRAY
	mov di, 78
	mov cl, 13
	.loop_draw_separator:
		stosw
		add di, (SCREEN_WIDTH * 2 - 1) * 2
		loop .loop_draw_separator

    mov ah, WHITE
    imul di, [player_y], SCREEN_WIDTH * 2
    mov cl, PLAYER_HEIGHT
    .loop_draw_player:
        mov [es:di + PLAYER_X], ax
        add di, SCREEN_WIDTH * 2
        loop .loop_draw_player

    imul di, [bot_y], SCREEN_WIDTH * 2
    mov cl, BOT_HEIGHT
    .loop_draw_bot:
        mov [es:di + BOT_X], ax
        add di, SCREEN_WIDTH * 2
        loop .loop_draw_bot

    imul di, [ball_y], SCREEN_WIDTH * 2
    add di, [ball_x]
    stosw

    .input_loop:
        hlt
        mov ah, 1
        int 0x16
        jz .calc

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
        jmp .calc

    .move_down:
        cmp word [player_y], SCREEN_HEIGHT - PLAYER_HEIGHT
        jge .input_loop

        inc word [player_y]
        jmp .calc

    .game_restart:
        int 0x19

    .calc:        
        mov bl, [ball_vel_y]
        add [ball_y], bl

        mov bl, [ball_vel_x]
        add [ball_x], bl

        cmp word [ball_x], PLAYER_X + 2
        jle .hit_check_player

        cmp word [ball_x], SCREEN_WIDTH + BOT_X
        jge .hit_check_bot

        cmp word [ball_x], 0
        jle .inc_bot

        cmp word [ball_x], SCREEN_WIDTH * 2
        jge .inc_player

        cmp word [ball_y], 0
        jle .uno_y
        cmp word [ball_y], SCREEN_HEIGHT
        jge .uno_y
        
        imul di, [ball_y], SCREEN_WIDTH * 2
        add di, [ball_x]
        stosw

        jmp delay

    .hit_check_player:  ; if (ball_y >= player_y && ball_y <= player_y - PLAYER_HEIGHT)        
        mov bx, [player_y]
        cmp bx, [ball_y]
        jg delay
        add bx, PLAYER_HEIGHT
        cmp bx, [ball_y]
        jl delay

        jmp .uno_x

    .hit_check_bot:
        mov bx, [bot_y]
        cmp bx, [ball_y]
        jg delay
        add bx, BOT_HEIGHT
        cmp bx, [ball_y]
        jl delay

        jmp .uno_x

    .uno_x:
        neg byte [ball_vel_x]
        jmp delay

    .uno_y:
        neg byte [ball_vel_y]
        jmp delay

    .inc_player:
        inc word [player_score]
        jmp .ball_reset

    .inc_bot:
        inc word [bot_score]
        jmp .ball_reset

    .ball_reset:
        mov word [ball_x], BALL_INITIAL_X
        mov word [ball_y], BALL_INITIAL_Y

        jmp .randomize_vel

    .randomize_vel:
        xor ah, ah
        int 0x1A ; Reference for int: (https://stanislavs.org/helppc/int_1a-0.html)

        mov ax, dx
        xor dx, dx
        mov cx, 2
        div cx

        test dx, dx
        jz .uno_x ; Randomizing for x is enough

    delay:
        mov bx, [TIMER_ADDR] ; # of IRQ0 timer ticks since boot [https://wiki.osdev.org/Memory_Map_(x86)]
        inc bx
        inc bx
        .loop_delay:
            cmp [TIMER_ADDR], bx
            jl .loop_delay


jmp game_loop

times 510-($-$$) db 0 ; Padding
dw 0xAA55 ; Signature