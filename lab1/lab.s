bits	64
;	(a**3 + b**3) / (a**2 * c - b**2 * d + e)
section	.data
res:
	dq	0
a:
	dw	-5
b:
	dw	-6
c:
	dd	7
d:
	dw	8
e:
	dd	113
section	.text
global	_start
_start:
    ; count a**3
    movsx eax, word[a]
    imul eax
    mov r8d, eax        ; a**2 in r8d
    movsx ebx, word[a]
    imul ebx            ; a**3 in edx:eax
    sal rdx, 32
    or rdx, rax
    mov rsi, rdx        ; a**3 in rsi

    ; count b**3
    movsx eax, word[b]
    imul eax
    mov r9d, eax        ; b**2 in r9d
    movsx ebx, word[b]
    imul ebx            ; b**3 in edx:eax
    sal rdx, 32
    or rdx, rax
    mov rdi, rdx        ; b**3 in rdi

    ; count a**3 + b**3
    add rsi, rdi        ; (a**3 + b**3) in rsi

    ; count a**2 * c
    mov eax, r8d
    mov ebx, dword[c]
    imul ebx            ; a**2 * c in edx:eax
    sal rdx, 32
    or rdx, rax
    mov rdi, rdx        ; a**2 * c in rdi

    ; count b**2 * d
    mov eax, r9d
    movsx ebx, word[d]
    imul ebx            ; b**2 * d in edx:eax
    sal rdx, 32
    or rdx, rax         ; b**2 * d in rdx

    ; count a**2 * c - b**2 * d + e
    sub rdi, rdx        ; a**2 * c - b**2 * d in rdi
    movsx rbx, dword[e]
    add rdi, rbx        ; a**2 * c - b**2 * d + e in rdi

    ; check rdi not zero
    cmp rdi, 0
    je exit

    ; count (a**3 + b**3) / (a**2 * c - b**2 * d + e)
    mov rax, rsi
    xor rdx, rdx
    cqo
    idiv rdi

    ; save answer to res
    mov [res], rax

    ; quit
    mov rax, 60
    mov rdx, 0
    syscall

exit:
    mov rax, 60
    mov rdx, 1
    syscall



