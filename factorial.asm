; nasm -felf32 factorial.asm -o factorial.o
; ld -melf_i386 factorial.o -o factorial

global  _start

section .rodata
newline: db 0xa
digit_table: db "0123456789abcdef"

section .text
; @edi - number to factor
;
; returns the factorial
factorial:
    push    edi
    mov     eax, 1
.loop:
    cmp     edi, 1
    jle     .end
    mul     edi
    dec     edi
    jmp     .loop
.end:
    pop     edi
    ret

; @edi - buffer to reverse
; @esi - length of buffer
reverse_bytes:
    push    ebx
    push    edi
    lea     eax, [edi + esi - 1]    ; buffer end
.loop:
    cmp     edi, eax
    jge     .end

    mov     cl, [edi]
    mov     bl, [eax]
    mov     [edi], bl
    mov     [eax], cl
    inc     edi
    dec     eax

    jmp     .loop
.end:
    pop     edi
    pop     ebx
    ret

; @edi - number to parse
; @esi - buffer to write to
; @edx - length of buffer
; @ecx - radix
;
; returns the number of bytes written
parse_int:
    push    ebx
    push    esi
    push    edi
    mov     eax, edi    ; move number, use @edi as counter
    push    ebp
    mov     ebp, edx    ; move length, use @edx for remainder
    xor     edi, edi

.loop:
    ; get and add ascii character
    xor     edx, edx
    div     ecx
    mov     ebx, [digit_table + edx]
    mov     [esi + edi], bl
    inc     edi

    ; no more digits to print?
    test    eax, eax
    jz      .end

    ; reached end of the buffer?
    cmp     edi, ebp
    je      .end

    jmp     .loop

.end:
    ; reverse the string
    mov     ebp, edi    ; move counter
    mov     edi, esi
    mov     esi, ebp
    call    reverse_bytes

    mov     eax, ebp
    pop     ebp
    pop     edi
    pop     esi
    pop     ebx
    ret

_start:
    mov     edi, 12     ; input
    call    factorial

    sub     esp, 32

    ; parse number
    mov     edi, eax
    lea     esi, [esp]
    mov     edx, 32
    mov     ecx, 10     ; radix
    call    parse_int

    ; write number
    mov     edx, eax
    mov     eax, 4      ; write
    mov     ebx, 1      ; stdout
    lea     ecx, [esp]
    int     0x80

    add     esp, 32

    ; write a newline
    mov     eax, 4      ; write
    mov     ebx, 1      ; stdout
    mov     ecx, newline
    mov     edx, 1
    int     0x80

    mov     eax, 1      ; exit
    mov     ebx, 0
    int     0x80
