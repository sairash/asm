; it takes input.bf and compiles it to somewhat optimized x86 asm which can be compiled by any compiler like nasm

section .data
	prompt db "Compiling the brainfuck to asm...", 10
	len_prompt equ $ - prompt


section .bss
	input_file resq 4


section .text
        global _start


%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro


_start:
	mov rax, [rsp + 16]  ; this is used to get the arg[1]
	mov [rel input_file], rax
	mov r13,[rel input_file]
	
	xor r14, r14

	.loop_len:
		cmp byte [r13 + r14], 0
		je .loop_end
		inc r14
		jmp .loop_len

	.loop_end:
		write r13, r14


	write prompt, len_prompt

	
	mov rax, 60
        mov rdi, 0
        syscall



