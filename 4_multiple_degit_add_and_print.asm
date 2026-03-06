section .data
        a equ 4210
        b equ 1
        n db 10

        
section .bss
        c resb 8
        rem resb 1


section .text
        global _start

%macro write 1
        mov rax, 1
        mov rdi, 1
        mov rsi, %1
        mov rdx, 1
        syscall
%endmacro

loop:
        extract_loop:
                xor rdx, rdx ; zero out rdx for unsigned 64 bit division
                mov rcx, 10
                div rcx
                add rdx, 48

                push rdx

                inc rbx

                test rax, rax
                jne extract_loop

        print_loop:
                write rsp ; rsp is the stack pointer as the write macro expects memory pointer address
                pop rax
                dec rbx
                jnz print_loop

        write n
        ret ; need this return from the function tooke me 1 hour to figure out.




_start:
        ; calculations
        mov rax, a
        add rax, b


        call loop
        

        mov rax, 60
        mov rdi, 0
        syscall
