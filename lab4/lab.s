bits	64

section	.data
    msg_scan_x  	db "Input x: ", 0
	msg_scan_n  	db "Input n: ", 0
	msg_invalid_x	db "Invalid x", 10, 0
	msg_invalid_n	db "Invalid n", 10, 0
	msg_res 		db "ln(1 + x) = %lf", 10, 0
	x_format		db "%lf", 0
	n_format    	db "%d", 0

section .text
    extern  printf
	extern	scanf
    global  main

main:
    push	rbp
	mov	    rbp, rsp
	sub		rsp, 16						; stack pointer should be 16-byte aligned
	call 	scan_x
	cmp 	eax, 0
	je 		quit
	movsd 	[rbp - 8], xmm0				; move x to rbp - 8
	xor		eax, eax
	call 	scan_n
	cmp 	eax, -1
	je 		quit

	mov 	ecx, eax					; move n to loop value
	mov 	rax, 1						; eax - i
	movsd	xmm1, [rbp - 8]				; xmm1 - x^i
	pxor 	xmm0, xmm0					; result in xmm0
	xor 	edx, edx					; edx - bool var is_negative
	while:
		movsd		xmm2, xmm1
		cvtsi2sd 	xmm3, rax		
		divsd		xmm2, xmm3			; xmm2 - x^i / i
		cmp			edx, 0
		je			.add
		.sub:
			subsd	xmm0, xmm2
			jmp 	.end
		.add:
			addsd	xmm0, xmm2
		.end:
			xor		edx, 1				; invert is_negative
			inc 	rax					; rax - i + 1
			mulsd	xmm1, [rbp - 8]		; xmm1 - x^(i+1)
		loop while

	mov		edi, msg_res
	xor		eax, 1
	call	printf

	quit:
		leave
		xor		eax, eax
		ret

scan_x:
	push	rbp
	mov	    rbp, rsp
	sub		rsp, 16						; stack pointer should be 16-byte aligned
	mov	    edi, msg_scan_x
	xor	    eax, eax					
	call	printf

	mov		edi, x_format
	lea		rsi, [rbp - 8]				; pointer to where to put result
	xor		eax, eax					
	call 	scanf
	movsd	xmm0, [rbp - 8]				; move result to xmm0

	cmp 	rax, 0
	jne		.end
	.print_error_msg:
		mov	    edi, msg_invalid_x
		xor	    eax, eax				
		call	printf
		mov		eax, 0
	.end:
		leave
		ret

scan_n:
	push	rbp
	mov	    rbp, rsp
	sub		rsp, 16						; stack pointer should be 16-byte aligned
	mov	    edi, msg_scan_n
	xor	    eax, eax					
	call	printf

	mov		edi, n_format
	lea		rsi, [rbp - 8]				; pointer to where to put result
	xor		eax, eax					
	call 	scanf

	cmp 	eax, 0
	mov		eax, [rbp - 8]				; move return value to rax
	jne		.end
	.print_error_msg:
		mov	    edi, msg_invalid_n
		xor	    eax, eax				
		call	printf
		mov		eax, -1
	.end:
		leave
		ret
