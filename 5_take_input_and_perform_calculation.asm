; take data from the user "a" and "b" then a sign "+,-" then perform the actions from the user


section .data
        info db "Operation performed in a sign b (ie: a / b or a * b)", 10
        len_info equ $ - info
        prompt db "Enter number: "
        len_prompt equ $ - prompt
        prompt_sign db "Enter sign (+ , - , * , / ): "
        len_prompt_sign equ $ - prompt_sign
        err_input_empty db "Can't be empty! ", 10
        len_err_input_empty db $ - err_input_empty

section .bss
        a resb 8 ; number store
        s resb 8 ; operration
        r resb 9 ; result


section .text
        global _start


panic:
        mov rax, 60
        mov rdi, 69
        syscall

%macro write 2
        mov rax, 1
        mov rdi, 1
        mov rsi, %1
        mov rdx, %2
        syscall
%endmacro


%macro convert_ascii_to_number 0
        ; here will be the loop to convert the ascii to number
        xor rax, rax

        mov bl, [rsi]
        inc rsi
        ; checking if the string is empty
        cmp bl, 10
        je .empty
        
        
        .loop:

                sub bl, '0'
                
                cmp bl, 9
                jg panic ; greater than
                cmp bl, 0
                jl panic ; ;less than

                imul rax, 10 ; imul is integer multiply
                movzx rbx, bl ; movz is move with zero extended this makes the current al 7 to rbx = 0000000000000007
                add rax, rbx


                mov bl, [rsi]
                inc rsi

                cmp bl, 10
                je .done  ; equals to
                
                jmp .loop

        .empty:
                write err_input_empty, len_err_input_empty
                call panic
        
        .done:
                push rax
%endmacro


%macro ascii_and_print 0
        ; convert the calculated number to ascii and then print it to screen improved
        mov rcx, 8

        mov rdx, 0

        mov byte [r + rcx], 10

        .loop:
                dec rcx
                mov rbx, 10
                xor rdx, rdx
                div rbx

                add rdx, 48
                
                mov byte [r + rcx], dl
                
                cmp rax, 0
                jne .loop

        .print:
                write r, 9
                
%endmacro

calculator:
        mov r8, 2
        
        num:
                write prompt, len_prompt
                mov rax, 0
                mov rdi, 0
                mov rsi, a
                mov rdx, 8
                syscall

                convert_ascii_to_number

                dec r8
                jnz num ; jnz means Jump if Not Zero. normally used with cmp but here dec auto sets the zero flag 


        sign:
                write prompt_sign, len_prompt_sign
                mov rax, 0
                mov rdi, 0
                mov rsi, s
                mov rdx, 8
                syscall

                mov al, byte [rel s]

                
                cmp al, '-'
                je .sub
                
                cmp al, '+'
                je .add

                cmp al, '*'
                je .mul

                cmp al, '/'
                je .div
                
                call panic
                

        .add:
                pop rbx
                pop rax
                add rax, rbx
                push rax
                jmp .done
        .sub:
                pop rbx
                pop rax
                sub rax, rbx
                push rax
                jmp .done

        .mul:
                pop rax
                pop rbx
                mul rbx
                push rax
                jmp .done

        .div:
                pop rbx
                pop rax
                xor rdx, rdx
                div rbx
                push rax
                jmp .done


        .done:
                pop rax
                ascii_and_print
ret


_start:
        write info, len_info
        call calculator


        mov rax, 60
        mov rdi, 0
        syscall
