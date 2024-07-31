; Gideon Vos July 2024. www.linkedin.com/in/gideonvos
; prologue and epilogue macros originally by agguro (thanks!)

bits 64

; five macros to make life a bit easier
; each global function/method/routine (whatever you call it) must start with the PROLOGUE
%macro _prologue 0
    push    rbp
    mov     rbp,rsp
    push    rbx
    call    .get_GOT
.get_GOT:
    pop     rbx
    add     rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc
%endmacro

; each global function/method/routine (whatever you call it) must end with the EPILOGUE
%macro _epilogue 0
    mov     rbx,[rbp-8]
    mov     rsp,rbp
    pop     rbp
    ret
%endmacro

; macro to initiate and export the global procedure while defining it as a PROCEDURE
; doing so it's harder to forget to export it
%macro _proc 1
    global  %1:function
    %1:
    _prologue
%endmacro

; macro to end the procedure
%macro _endp 0
    _epilogue
%endmacro

extern  _GLOBAL_OFFSET_TABLE_

section .text
_start:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sort array in rdi of length rbx from small to large
bubble_sort:
    dec rbx
    mov r9, rbx

.sort_outer_loop:
    push r9
    xor rsi, rsi
    mov rdx, 0

.sort_inner_loop:
    mov eax, [rdi + (rsi*4)]
    mov r8d, [rdi + (rsi*4) + 4]
    cmp eax, r8d
    jle .no_swap
    mov [rdi + (rsi*4)], r8d
    mov [rdi + (rsi*4) + 4], eax
    mov rdx, 1

.no_swap:
    inc rsi
    dec r9
    test r9,r9
    jnz .sort_inner_loop
    pop r9
    cmp rdx, 0
    je .done
    dec rbx
    jnz .sort_outer_loop

.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Exported functions start here
;
;
; Notes:
;
; passing single values will arrive in rdi register
;
; passing arrays:
; upon _proc entry, rsi contains number of elements in the array or 0
; array elements will start at [rdi], for example, given an array of 11,22,33 then:
; rsi = 3
; [rdi] = 11
; [rdi+4] = 22
; [rdi+8] = 33
;
; result of _proc should be returned in rax so Python can get it back
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; dummy test function, just returns same int passed in as result
_proc dummy
    mov rax, rdi
_endp

;calculate the square of given value, result in rax
_proc square
    mov     rax, rdi
    imul    rax, rdi
_endp

;find max value given an array, result in rax
_proc max
    xor rax, rax
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    mov edx, [rdi + rbx * 4] ; load first element to bootstrap
    inc rbx

.max_loop:
    mov eax, [rdi + rbx * 4]
    cmp edx, eax
    jg .max_less
    mov edx, eax

.max_less:
    inc rbx
    cmp rbx, rcx
    jne .max_loop
    mov rax, rdx

.proc_done:
_endp

;find min value given an array, result in rax
_proc min
    xor rax, rax
    xor rbx, rbx
    xor rdx, rdx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    mov edx, [rdi + rbx * 4] ; load first element to bootstrap

.min_loop:
    mov eax, [rdi + rbx * 4]
    cmp eax, edx
    jg .min_more
    mov edx, eax

.min_more:
    inc rbx
    cmp rbx, rcx
    jne .min_loop
    mov rax, rdx

.proc_done:
_endp

;calculate sum of array, result in rax
_proc sum
    xor rax, rax
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done

.sum_loop:
    add eax, [rdi + rbx * 4]
    inc rbx
    cmp rbx, rcx
    jne .sum_loop

.proc_done:
_endp

;calculate mean of array, result in rax
_proc mean
    xor rax, rax
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done

.mean_loop:
    add eax, [rdi + rbx * 4]
    inc rbx
    cmp rbx, rcx
    jne .mean_loop
    cdq
    idiv ecx

.proc_done:
_endp

; calculate median of array, result in rax
_proc median
    mov rbx, rsi
    test ebx, ebx
    jz .proc_done           ; empty array passed
    push rbx
    push rdi
    call bubble_sort        ; need to sort to find median
    pop rdi
    pop rbx
    test rbx, 1             ; Check if the length is odd or even
    jz .even_median
    shr rbx, 1
    mov rax, [rdi + rbx * 4]
    jmp .proc_done

.even_median:
    shr rbx, 1
    mov rdx, [rdi + (rbx * 4) - 4]
    mov rax, [rdi + (rbx * 4)]
    add rax, rdx
    shr eax, 1

.proc_done:
_endp

