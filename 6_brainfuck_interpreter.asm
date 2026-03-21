section .data
	filename db "input.bf", 0

	nofile_prompt db "no input file found", 10
	len_nofile_prompt equ $ - nofile_prompt

	

section .bss
	buffer resb 1024
	stack  resb 1024


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

	ret


no_file_found:
	write nofile_prompt, len_nofile_prompt
	call panic
	ret


interpreter:
	lea rbx, [rel buffer]
	mov r14, r13


	mov rsi, stack
	
	mov rbp, 0 ; it'll track the bf loop pointer

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
		jmp .next

	.dec:
		dec rsi
		jmp .next

	.loop_start:
		cmp byte [rsi], 0
		je .skip_forward      
		push rbx              
		jmp .next

	.loop_end:
		cmp byte [rsi], 0
		jne .jump_back        

		pop rbx               
		jmp .next

	.jump_back:
		mov rbx, [rsp]        
		jmp .next



	.skip_forward:
		mov rcx, 1

	.skip_loop:
		inc rbx

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
