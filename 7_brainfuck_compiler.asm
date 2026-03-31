; it takes input.bf and compiles it to somewhat optimized x86 asm which can be compiled by any compiler like nasm

section .data
	prompt db "Compiling the brainfuck file to asm: "
	len_prompt equ $ - prompt

	newline db 10
	
	nofile_prompt db "file not found: "
	len_nofile_prompt equ $ - nofile_prompt



section .bss
	input_file resq 4
	len_input_file resq 1
	buffer resb 1024

section .text
        global _start


%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

_panic:
	mov rax, 60
	mov rdi, 69
	syscall


_no_file_found:
	mov r13, [rel input_file]
	mov r14, [rel len_input_file]
	
	write nofile_prompt, len_nofile_prompt
	write r13, r14
	
	write newline, 1
	call _panic


_compiler:

	ret
	

_arg1:
	mov rax, [rsp + 24]  ; this is used to get the arg[1]
	mov [rel input_file], rax
	mov r13,[rel input_file]
	
	xor r14, r14

	.loop_len:
		cmp byte [r13 + r14], 0
		je .loop_end
		inc r14
		jmp .loop_len

	.loop_end:
		mov [rel len_input_file], r14
	
	ret	



_start:
	call _arg1
	mov r13, [rel input_file]

	mov rax, 2
	mov rdi, r13
	mov rsi, 0
	mov rdx, 0
	syscall


	cmp rax, 0
	jl _no_file_found

	mov r12, rax


	; reading all of the data in buffer
	mov rax, 0 
	mov rdi, r12
	mov rsi, buffer
	mov rdx, 1024
	syscall


	mov r15, rax ; moving the file length to r15

	; need to close the file after reading it
	mov rax, 3
	mov rdi, r12
	syscall


	mov r14, [rel len_input_file]
	write prompt, len_prompt
	write r13, r14
	write newline, 1

	call _compiler
	
	
	mov rax, 60
        mov rdi, 0
        syscall



