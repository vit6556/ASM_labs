bits	64
;	Sorting each diagonal of a square matrix parallel to the side diagonal
section	.data
asc:
    db  ASC_ORDER
n:
	dw	4
matrix:
	dw	7, 8, 9, 4
	dw	16, 15, 14, 13
	dw	9, 10, 13, 12
	dw	1, 3, 2, 9

section	.text
global	_start
_start:
	mov r8w, [n]					; r8w - number of rows
	cmp r8w, 1						; check if n == 1
	jle exit						; if rows <= 1 exit

	mov rbx, matrix					; rbx - matrix

	xor r9w, r9w					; r9w - index of current row
	xor r10w, r10w					; r10w - index of current col

	mov cx, r8w
	add cx, r8w
	sub cx, 1						; cx = n * 2 - 1

; 1. iterates over rows from 0 to n
; 2. iterates over cols from 0 to n
main_loop:
	push cx							; save loop counter

	call get_diagonal_length		; cx - length of diagonal
	mov di, cx						; di - number of rows/cols
	sub di, 1						; di - r value of comb sort
	call main_sort_loop				; sort diagonal

	pop cx							; restore loop counter
	call increase_index				; increase index
	loop main_loop

	mov	eax, 60
	mov edi, 0
	syscall

main_sort_loop:
	cmp di, 0
	jle break						; break if r value <= l value

	mov r11w, 0						; current comb sort shift
	call comb_sort_loop				; start one comb iteration

	call divide_by_shrink_factor	; divide r value by shrink factor

	jmp main_sort_loop

comb_sort_loop:
	mov r14w, r11w
	add r14w, di
	cmp r14w, cx
	jge break						; break if r value + shift is outside matrix

	call get_matrix_shift
	mov ax, [matrix + r12*2]
	mov dx, [matrix + r13*2]

    cmp byte[asc], 1
    je  ascending
    jmp descending

    ascending:
	    cmp ax, dx
	    jge next_iter
        jmp swap

    descending:
        cmp ax, dx
        jle next_iter
        jmp swap

    swap:
	    ; swap l value and r value of comb sort
	    ; swap matrix[r9w - shift][r10w + shift] with matrix[r9w - shift - di][r10w + shift + di]
	    mov ax, [matrix + r12*2]
	    mov dx, [matrix + r13*2]
	    mov [matrix + r12*2], dx		; matrix[r9w - shift][r10w + shift] = matrix[r9w - shift - di][r10w + shift + di]
	    mov [matrix + r13*2], ax		; matrix[r9w - shift - di][r10w + shift + di] = matrix[r9w - shift][r10w + shift]

	next_iter:
		inc r11w
		jmp comb_sort_loop


; r12w = l value shift
; r13w = r value shift
get_matrix_shift:
	mov r12w, r9w
	sub r12w, r11w					; r12w = r9w - shift
	mov r13w, r12w
	sub r13w, di					; r13w = r9w - shift - di
	imul r12w, r8w					; r12w = (r9w - shift) * rows amount
	imul r13w, r8w					; r13w = (r9w - shift - di) * rows amount

	add r12w, r11w
	add r12w, r10w					; r12w = (r9w - shift) * rows amount + r10w + shift
	add r13w, r11w
	add r13w, r10w				
	add r13w, di					; r13w = (r9w - shift - di) * rows amount + r10w + shift + di

	ret

; increase current index
increase_index:
	mov r11w, r8w
	sub r11w, 1						; r11w - number of rows - 1
	if:								; if r9w != r11w
		cmp r9w, r11w				
		je elif						; r9w == r11w - jmp to elif
		inc r9w						
		jmp end						; jmp to end
	elif:							; elif r10w != r11w
		cmp r10w, r11w
		je end						; r10w == r11w - jmp to end
		inc r10w
	end:
		ret

; calc diagonal length, returns cx
get_diagonal_length:				; diagonal length = row index - col index + 1
	mov cx, r9w
	sub cx, r10w
	inc cx							; cx - diagonal length

	ret
	
; divide di by 1.247
divide_by_shrink_factor:
	mov eax, 1000
	mul edi           				; eax - num * 1000
	mov edx, 0
	mov r11d, 1247
	div r11d 						; eax - num / 1.247
	mov di, ax						; di - num / 1.247

	ret

break:
	ret
    
exit:
	mov	eax, 60
	mov edi, 1
	syscall
