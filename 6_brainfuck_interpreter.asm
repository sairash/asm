section .data
	filename db "./input/input.bf", 0

	nofile_prompt db "no input file found", 10
	len_nofile_prompt equ $ - nofile_prompt

	

section .bss
	buffer  resb 1024
	stack   resb 1024
	lstack  resq 128  ; loop stack


section .text
	global _start




%macro write 2
	mov rax, 1
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro


panic:
	mov rax, 60
	mov rdi, 69
	syscall



no_file_found:
	write nofile_prompt, len_nofile_prompt
	call panic


interpreter:
	lea rbx, [rel buffer]
	mov r14, r13

	lea r15, [rel lstack]

	mov rsi, stack
	
	lea rbp, [rbx + r13] ; end of program = buffer + length

	.loop:
		cmp r14, 0
		je .done	


		mov al, [rbx]

		cmp al, '+'
		je .add
	
		cmp al, '.'
		je .print

		cmp al, '-'
		je .sub

		cmp al, '>'
		je .inc

		cmp al, '<'
		je .dec

		cmp al, '['
		je .loop_start
	
		cmp al, ']'
		je .loop_end


		jmp .next
	
	.print:
		write rsi, 1
		jmp .next

	.add:
		inc byte [rsi]
		jmp .next

	.sub:
		dec byte [rsi]
		jmp .next

	.inc:
		inc rsi

		cmp rsi, stack + 1024 ; making sure that the memory is within the stack frame
		jae panic
		
		jmp .next

	.dec:
		cmp rsi, stack
		jbe panic       ; the first operation cannot be < as it will go out of bound
	
		dec rsi
		jmp .next

	.loop_start:
		cmp byte [rsi], 0
		je .skip_forward      

		mov [r15], rbx
		add r15, 8         ; push
		jmp .next

	.loop_end:
		cmp byte [rsi], 0
		jne .jump_back        

		sub r15, 8         ; pop
		jmp .next

	.jump_back:
		mov rbx, [r15- 8]  ; peeking
		sub r15, 8 ; pop
		mov r14, rbp
		sub r14, rbx       ; r14 = remaining bytes from current position
		jmp .loop


	.skip_forward:
		mov rcx, 1

	.skip_loop:
		cmp r14, 1
		je panic

		inc rbx
		dec r14

		mov al, [rbx]

		cmp al, '['
		je .inc_depth

		cmp al, ']'
		je .dec_depth


		jmp .skip_loop

	.inc_depth:
		inc rcx
		jmp .cmp

	.dec_depth:
		dec rcx
		jmp .cmp

	.cmp:
		cmp rcx, 0
		je .next
			
		jmp .skip_loop	


	.next:
		inc rbx
		dec r14
		jmp .loop
	
	
	.done:
		ret

	
_start:
	; opening the file to read it
	mov rax, 2 ; sys_open 
	mov rdi, filename
	mov rsi, 0 ; 0 = read only
	mov rdx, 0 ; mode unused here
	syscall


	cmp rax, 0 ; check if the file is present or not if < 0
	jl no_file_found

	mov r12, rax  ; saving file descriptor

	; read the open file and put it to the buffer
	mov rax, 0   ; sys_read similar to using it for the stdin
	mov rdi, r12 ; file descriptor
	mov rsi, buffer
	mov rdx, 1024
	syscall

	mov r13, rax ; number of bytes that were read is here

	; now we need to close the file
	mov rax, 3 ; sys_close
	mov rdi, r12
	syscall


	call interpreter
	

	; exit the program
	mov rax, 60
	mov rdi, 0
	syscall
