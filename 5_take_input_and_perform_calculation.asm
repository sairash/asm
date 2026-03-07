; take data from the user "a" and "b" then a sign "+,-" then perform the actions from the user


section .data
        prompt db "Enter number: "
        len_prompt equ $ - prompt
        prompt_sign db "Enter sign (+ | -): "
        len_prompt_sign equ $ - prompt


section .bss
        a resb 8 ; first number
        b resb 8 ; second number
        s resb 8 ; operration


section .text
        global _start


panic:
        mov rax, 60
        mov rdi, 69
        syscall

%macro convert_ascii_to_number 1
        ; here will be the loop to convert the ascii to number
        mov rax, %1
        extract:
                mov rcx, 10
                div rcx
                sub rdx, 48

                mov rcx, 9
                cmp rdx, rcx
                jg panic
                
%endmacro


get_numbers:
        num_a:
                mov rax, 0
                mov rdi, 0
                mov rsi, a
                mov rdx, 8
                syscall

                convert_ascii_to_number a

        num_b:
                mov rax, 0
                mov rdi, 0
                mov rsi, b
                mov rdx, 8
                syscall


        ret


_start:
        mov rax, 1
        mov rdi, 1
        mov rsi, prompt
        mov rdx, len_prompt
        syscall

        call get_numbers



        mov rax, 60
        mov rdi, 0
        syscall
