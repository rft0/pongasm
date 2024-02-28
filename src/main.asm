BITS 64
CPU X64 ; x86_64

; Constants
%define SYSCALL_EXIT 60

section .text
    global _start

_start:
    mov rax, 1
    mov ebx, 0
    syscall