section .data
        a equ 1
        b equ 8

section .bss
        c resb 8

section .text
        global _start

_start:
        mov rax, b
        sub rax, a
        add rax, 48

        mov [c], rax


        mov rax, 1
        mov rdi, 1
        mov rsi, c
        mov rdx, 1
        syscall

        mov rax, 60
        mov rdi, 0
        syscall
