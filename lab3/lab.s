bits	64

section	.data
file_corrupted_msg db "Error: corrupted file", 0x0a, 0
invalid_args db "Usage: ./lab <filename>", 0x0a, 0
space db 0x20
new_line db 0x0a
buff db 0

section	.text
	global	_start

_start:
    ; r9 - current descriptor status
    ; 0 - not_in_word
    ; 1 - in_word_to_print
    ; 2 - in_word_to_delete
    mov     r9, 0
    mov     r8, 0                                   ; r8 - first char of first word
    mov     r10, 0                                  ; r10 - is current delimiter new line

	pop 	rax					                    ; Get amount of arguments
	cmp 	rax, 0x2
	jne 	invalid_args_error

	pop		rax 				                    ; Pop ./lab address

main:
    mov     rax, 2			                        ; sys_open
    pop     rdi                                     ; Filename in rdi
    mov     rsi, 0       		                    ; Read only
    mov     rdx, 0644o       	                    ; File permision
    syscall

    cmp     rax, 0				                    ; Check file not corrupted
    jl      file_corrupted_error
    mov     rbp, rax        	                    ; Save the file descriptor in rbp

	.loop:
        mov     rax, 0      	                    ; sys_read
        mov     rdi, rbp                            ; Put file descriptor
        mov     rsi, buff                           ; Put buff address in rsi
        mov     rdx, 1                              ; Read one char
        syscall

		test    rax, rax    	                    ; check for EOF
        je      .end

        mov     rdi, buff
        call    check_if_delimiter
        cmp     rax, 1
        je      .delimiter
        jmp     .not_delimiter

        .delimiter:
            cmp     r9, 1
            jge     .in_word
            jmp     .next_iter

            .in_word:
            mov     r9, 0                           ; Set status not_in_word
            jmp     .next_iter

        .not_delimiter:
            cmp     r9, 1
            jl      .not_in_word
            je      .in_word_to_print
            jmp     .next_iter
            
            .not_in_word:
                cmp     r8, 0
                jne     .not_first_word

                .update_first_word_char:
                mov     r8, [rdi]
                mov     r9, 1                       ; Set status in_word_to_print
                call    print_char
                jmp     .next_iter

                .not_first_word:
                    cmp     r8, [rdi]
                    je      .set_word_to_print

                    .set_word_to_delete:
                        mov     r9, 2               ; Set status in_word_to_delete
                        jmp     .next_iter

                   .set_word_to_print:
                        mov     r9, 1               ; Set status in_word_to_print

                        ; Print delimiter
                        push    rdi
                        cmp     r10, 0              ; Check if delimiter is \n
                        je      .print_space
                        jmp     .print_new_line

                        .print_space:
                        mov     rdi, space
                        jmp     .print_delimiter
                        .print_new_line:
                        mov     rdi, new_line
                        mov     r10, 0              ; Set new line delimiter false

                        .print_delimiter:
                        call    print_char
                        pop     rdi

                        ; Print char
                        call    print_char
                        jmp     .next_iter

            .in_word_to_print:
            call    print_char
            jmp     .next_iter

        .next_iter:
		jmp 	.loop

	.end:
    ; Print \n
    cmp     r10, 1                                  ; check if already new line
    jne     .print_one_new_line
    mov     rdi, new_line
    call    print_char

    .print_one_new_line:
    mov     rdi, new_line
    call    print_char

	; Close file
	mov rax, 3
    mov rdi, rbp
    syscall

	call exit_normal

check_if_delimiter:
    ; Check if delimiter in edx
    ; Result (0 or 1) in eax
    mov     rax, 0

    cmp     byte [rdi], 0x20                        ; check if space
    je      .is_delimiter
    cmp     byte [rdi], 0x09                        ; check if tab
    je      .is_delimiter
    cmp     byte [rdi], 0x0a                        ; check if \n
    je      .is_new_line
    jmp     .end

    .is_new_line:
    cmp     r8, 0                                   ; check if before first word
    je     .print_new_line
    cmp     r10, 1                                  ; check if already new line
    je     .print_new_line

    mov     r10, 1                                  ; set new line delimiter true
    jmp     .is_delimiter

    .print_new_line:
    push    rdi
    mov     rdi, new_line
    call    print_char
    pop     rdi

    .is_delimiter:
    mov     rax, 1

    .end:
    ret

print_char:
    ; Print char from rdi
	mov 	rsi, rdi
    mov     rdi, 1      		                    ; File descriptor for stdout
    mov     rdx, 1				                    ; Print one char
	mov     rax, 1          	                    ; System call for write
    syscall

	ret

print_string:
	; Print string from rdi
	mov 	rsi, rdi
    mov     rdi, 1      		                    ; File descriptor for stdout
    mov     rdx, 1				                    ; Print one char
    .loop:
        mov     rax, 1                              ; System call for write
        syscall					                    ; Write one char
		inc     rsi

        cmp     byte [rsi], 0
        jne      .loop

    ret

invalid_args_error:
	; Invalid arguments error
    push 	invalid_args
    jmp 	exit_with_error

file_corrupted_error:
	; Corrupted file error
    push 	file_corrupted_msg
    jmp 	exit_with_error

exit_with_error:
	; Print error and quit
	pop 	rdi
    call	print_string
    mov		rdi, 1
    jmp 	exit

exit_normal:
    ; Exit program without error
    mov     rdi, 0
    jmp     exit

exit:
    mov     rax, 60                                 ; Syscall for exit
	syscall


