section .data
        msg db "Hello world", 10 ; 10 is \n 
        len equ $ - msg ; we are getting the len of msg

section .text
        global _start ; must be declared as the entry point for linker

_start:
        mov rax, 1   ; 1 = syscall - sysout
        mov rdi, 1   ; 1 = stdout
        mov rsi, msg ; starting point to print
        mov rdx, len ; till what we need to print
        syscall

        mov rax, 60  ; 60 = syscall - sysexit
        mov rdi, 0   ; 0 = success message 1 = error
        syscall
