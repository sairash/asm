; Take input from the user and greet the user,

section .data
        prompt db "Enter your name: " 
        len_prompt equ $ - prompt

        greet db "Hello: "
        len_greet equ $ - greet

section .bss
        name resb 256 ; reserving 256 bytes for input data
        len_name equ $ - name

section .text
        global _start



%macro write 2     ; A macro print text to terminal screen stdout
        mov rax, 1
        mov rdi, 1
        mov rsi, %1
        mov rdx, %2
        syscall
%endmacro



_start:
        write prompt, len_prompt
        
        mov rax, 0 ; 0 = syscall - sys_read
        mov rdi, 0 ; 0 = input from terminal stdin
        mov rsi, name
        mov rdx, len_name
        syscall

        write greet, len_greet
        write name, len_name

        ; -- ending
        mov rax, 60
        mov rdi, 0
        syscall
