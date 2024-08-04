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
; Helper functions - integer functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sort array in rdi of length rbx
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

; used during search in the unique function
unique_contains:
    xor rbx, rbx
    cmp r10, 0
    jnz contains_loop
    mov [r8], rdx
    inc r10
    ret

contains_loop:
    mov rax, [r8 + (rbx * 4)]
    cmp eax, edx
    jz contains_found
    inc rbx
    cmp rbx, r10
    jnz contains_loop
    mov [r8 + (r10 * 4)], rdx
    inc r10
    ret

contains_found:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper functions - floating point functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sort array in rdi of length rbx
d_bubble_sort:
    dec rbx
    mov r9, rbx

.sort_outer_loop:
    push r9
    xor rsi, rsi
    mov rdx, 0

.sort_inner_loop:
    movsd xmm0, [rdi + (rsi*8)]
    movsd xmm1, [rdi + (rsi*8) + 8]
    ucomisd xmm0, xmm1
    jb .no_swap
    movsd [rdi + (rsi*8)], xmm1
    movsd [rdi + (rsi*8) + 8], xmm0
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
; Integer type functions. These handle integer type values with no decimals points
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

; sort array in rdi of length rbx in ascending order
_proc sortasc
    mov rbx, rsi
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
    mov rax, 1
_endp

; sort array in rdi of length rbx in descending order
_proc sortdsc
    mov rbx, rsi
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
    jge .no_swap
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
    mov rax, 1
_endp

; test if given array contains specified element
_proc contains
    xor rax, rax
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .done

.contains_loop:
    mov eax, [rdi + (rbx * 4)]
    cmp eax, edx
    jne .not_found
    mov rax, rbx
    jmp .done

.not_found:
    inc rbx
    cmp rbx, rcx
    jne .contains_loop
    mov rax, -1 ; not found

.done:
_endp

; compares two arrays
; returns -1 if not equal size or array length is 0
; returns 0 if not equal in values
; returns 1 if equal in values
_proc compare
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx
    mov rax, 0 ; assume not equal

.compare_loop:
    mov r8, [rdi + rbx * 4]
    mov r9, [rdx + rbx * 4]
    cmp r8d, r9d
    jne .done
    inc rbx
    cmp rbx, rcx
    jl .compare_loop
    mov rax, 1
    jmp .done

.not_equal:
    mov rax, -1

.done:
_endp

; adds two arrays element-wise, result returned in array 1
_proc add
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.add_loop:
    xor rax, rax
    mov eax, [rdi + rbx * 4]
    add eax, [rdx + rbx * 4]
    mov [rdi + rbx * 4], eax
    inc rbx
    cmp rbx, rcx
    jl .add_loop
    mov rax, 1
    jmp .done

.done:
_endp

; subtracts two arrays element-wise, result returned in array 1
_proc sub
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.add_loop:
    xor rax, rax
    mov eax, [rdi + rbx * 4]
    sub eax, [rdx + rbx * 4]
    mov [rdi + rbx * 4], eax
    inc rbx
    cmp rbx, rcx
    jl .add_loop
    mov rax, 1
    jmp .done

.done:
_endp

; multiplies two arrays element-wise, result returned in array 1
_proc mul
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    mov r8, rdi
    mov r9, rdx
    xor r10,r10

.mul_loop:
    mov eax, [r8 + r10 * 4]
    mov ebx, [r9 + r10 * 4]
    mul ebx ; result is in rdx:rax
    mov [r8 + r10 * 4], eax
    inc r10
    cmp r10, rsi
    jl .mul_loop
    mov rax, 1

.done:
_endp

; performs the dot product between the two given arrays
_proc dot
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    mov r8, rdi
    mov r9, rdx
    xor r10,r10

.dot_loop:
    mov eax, [r8 + r10 * 4]
    mov ebx, [r9 + r10 * 4]
    mul ebx ; result is in rdx:rax
    mov [r8 + r10 * 4], eax
    inc r10
    cmp r10, rsi
    jl .dot_loop
    xor rax, rax
    xor r10, r10

.sum_loop:
    add eax, [r8 + r10 * 4]
    inc r10
    cmp r10, rsi
    jne .sum_loop

.done:
_endp

; return the unique numbers in the specified array
_proc unique
    ; allocate memory
    push rsi
    push rdi
    mov edi, 0          ; addr = NULL (let the kernel choose the address)
    mov edx, 0x3        ; prot = PROT_READ | PROT_WRITE
    mov r10d, 0x22      ; flags = MAP_PRIVATE | MAP_ANONYMOUS
    mov r8d, -1         ; fd = -1 (not backed by any file)
    mov r9, 0           ; offset = 0
    mov eax, 9          ; syscall number for mmap (sys_mmap)
    syscall

    ; setup
    mov r8, rax         ; address of our new array in r8
    pop rdi             ; pointer to input array
    pop rsi             ; length of input array
    xor r9, r9          ; our iterator for main scan loop
    xor r10, r10        ; how many unique elements so far?

.scan_loop:
    mov rdx, [rdi + (r9 * 4)]
    push r8
    call unique_contains
    pop r8
    inc r9
    cmp r9, rsi
    jnz .scan_loop
    xor rbx, rbx

.copy_back:
    mov rdx, [r8 + (rbx * 4)]
    mov [rdi + (rbx * 4)], rdx
    inc rbx
    cmp rbx, r10
    jnz .copy_back

    ; deallocate memory
    mov rax, [r8 + 12]  
    push rax
    push r10
    mov rdi, r8         ; addr = address of allocated memory
    mov eax, 11         ; syscall number for munmap (sys_munmap)
    syscall
    pop r10
    pop rax
    mov rax, r10        ; total unique elements returned in r10

_endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Floating point function equivalents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;calculate the square of given value, result in rax
_proc d_square
    mulsd xmm0, xmm0
_endp

;find max value given a floating point array, result in rax
_proc d_max
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    movsd xmm0, qword [rdi + rbx * 8] ; load first element to bootstrap
    inc rbx

.max_loop:
    movsd xmm1, qword [rdi + rbx * 8]
    comisd xmm0, xmm1
    ja .max_less
    movsd xmm0, xmm1

.max_less:
    inc rbx
    cmp rbx, rcx
    jnz .max_loop

.proc_done:
_endp

;find min value given a floating point array, result in rax
_proc d_min
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    movsd xmm0, qword [rdi + rbx * 8] ; load first element to bootstrap
    inc rbx

.min_loop:
    movsd xmm1, qword [rdi + rbx * 8]
    comisd xmm0, xmm1
    jg .min_less
    movsd xmm0, xmm1

.min_less:
    inc rbx
    cmp rbx, rcx
    jnz .min_loop

.proc_done:
_endp

;calculate sum of floating point array, result in rax
_proc d_sum
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    movsd xmm0, qword [rdi + rbx * 8] ; load first element to bootstrap
    inc rbx

.sum_loop:
    movsd xmm1, qword [rdi + rbx * 8]
    addsd xmm0, xmm1
    inc rbx
    cmp rbx, rcx
    jnz .sum_loop

.proc_done:
_endp

; calculate the mean of a floating point array
_proc d_mean
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .proc_done
    movsd xmm0, qword [rdi + rbx * 8] ; load first element to bootstrap
    inc rbx

;calculate mean of array, result in rax
.mean_loop:
    movsd xmm1, qword [rdi + rbx * 8]
    addsd xmm0, xmm1
    inc rbx
    cmp rbx, rcx
    jnz .mean_loop
    cvtsi2sd xmm1, rbx
    divsd xmm0, xmm1

.proc_done:
_endp

; adds two arrays element-wise, result returned in array 1
_proc d_add
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.add_loop:
    xor rax, rax
    movsd xmm0, qword [rdi + rbx * 8]
    movsd xmm1, qword [rdx + rbx * 8]
    addsd xmm0, xmm1
    movsd qword [rdi + rbx * 8], xmm0
    inc rbx
    cmp rbx, rcx
    jl .add_loop
    mov rax, 1
    jmp .done

.done:
_endp

; subtracts two arrays element-wise, result returned in array 1
_proc d_sub
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.sub_loop:
    xor rax, rax
    movsd xmm0, qword [rdi + rbx * 8]
    movsd xmm1, qword [rdx + rbx * 8]
    subsd xmm0, xmm1
    movsd qword [rdi + rbx * 8], xmm0
    inc rbx
    cmp rbx, rcx
    jl .sub_loop
    mov rax, 1
    jmp .done

.done:
_endp

; multiplies two arrays element-wise, result returned in array 1
_proc d_mul
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.mul_loop:
    xor rax, rax
    movsd xmm0, qword [rdi + rbx * 8]
    movsd xmm1, qword [rdx + rbx * 8]
    mulsd xmm0, xmm1
    movsd qword [rdi + rbx * 8], xmm0
    inc rbx
    cmp rbx, rcx
    jl .mul_loop
    mov rax, 1
    jmp .done

.done:
_endp

; returns the dot product of two arrays
_proc d_dot
    pxor xmm0, xmm0
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx

.mul_loop:
    xor rax, rax
    movsd xmm0, qword [rdi + rbx * 8]
    movsd xmm1, qword [rdx + rbx * 8]
    mulsd xmm0, xmm1
    movsd qword [rdi + rbx * 8], xmm0
    inc rbx
    cmp rbx, rcx
    jl .mul_loop
    xor rbx, rbx
    pxor xmm0, xmm0

.sum_loop:
    movsd xmm1, qword [rdi + rbx * 8]
    addsd xmm0, xmm1
    inc rbx
    cmp rbx, rcx
    jl .sum_loop

.done:
_endp

; compares two floating point arrays
; returns -1 if not equal size or array length is 0
; returns 0 if not equal in values
; returns 1 if equal in values
_proc d_compare
    mov rax, -1
    mov rbx, rsi
    test ebx, ebx
    jz .done ; zero length array 1
    test ecx, ecx
    jz .done ; zero length array 2
    cmp rsi, rcx
    jne .done
    xor rbx, rbx
    mov rax, 0 ; assume not equal

.compare_loop:
    movsd xmm0, qword [rdi + rbx * 8]
    movsd xmm1, qword [rdx + rbx * 8]
    comisd xmm0, xmm1
    jne .done
    inc rbx
    cmp rbx, rcx
    jl .compare_loop
    mov rax, 1
    jmp .done

.not_equal:
    mov rax, -1

.done:
_endp

; determines if array contains given floating point value
; returns -1 if no
; else element index (zero-based) returned
_proc d_contains
    mov rax, -1 ; assume no
    xor rbx, rbx
    mov rcx, rsi
    test ecx, ecx
    jz .done

.contains_loop:
    movsd xmm1, [rdi + (rbx * 8)]
    comisd xmm0, xmm1
    jne .not_found
    mov rax, rbx
    jmp .done

.not_found:
    inc rbx
    cmp rbx, rcx
    jne .contains_loop
    mov rax, -1 ; not found

.done:
_endp

; sort array in rdi of length rsi in ascending order
_proc d_sortasc
    xor rax, rax
    mov rcx, rsi
    test ecx, ecx
    jz .done
    mov rbx, rsi
    dec rbx
    mov r9, rbx

.sort_outer_loop:
    xor rsi, rsi
    mov rdx, 0

.sort_inner_loop:
    movsd xmm0, [rdi + rsi*8]
    movsd xmm1, [rdi + rsi*8 + 8]
    ucomisd xmm0, xmm1
    jb .no_swap
    movsd [rdi + rsi*8], xmm1
    movsd [rdi + rsi*8 + 8], xmm0
    mov rdx, 1

.no_swap:
    inc rsi
    cmp rsi, r9
    jb .sort_inner_loop
    dec r9
    test r9, r9
    jz .done
    test rdx, rdx
    jnz .sort_outer_loop

.done:
    mov rax, 1
_endp

; sort array in rdi of length rsi in descending order
_proc d_sortdsc
    xor rax, rax
    mov rcx, rsi
    test ecx, ecx
    jz .done
    mov rbx, rsi
    dec rbx
    mov r9, rbx

.sort_outer_loop:
    xor rsi, rsi
    mov rdx, 0

.sort_inner_loop:
    movsd xmm0, [rdi + rsi*8]
    movsd xmm1, [rdi + rsi*8 + 8]
    ucomisd xmm0, xmm1
    ja .no_swap
    movsd [rdi + rsi*8], xmm1
    movsd [rdi + rsi*8 + 8], xmm0
    mov rdx, 1

.no_swap:
    inc rsi
    cmp rsi, r9
    jb .sort_inner_loop
    dec r9
    test r9, r9
    jz .done
    test rdx, rdx
    jnz .sort_outer_loop

.done:
    mov rax, 1
_endp

; calculate median of array
_proc d_median
    mov rbx, rsi
    test ebx, ebx
    jz .proc_done           ; empty array passed
    push rbx
    push rdi
    call d_bubble_sort        ; need to sort to find median
    pop rdi
    pop rbx
    test rbx, 1             ; Check if the length is odd or even
    jz .even_median
    shr rbx, 1
    movsd xmm0, [rdi + rbx * 8]
    jmp .proc_done

.even_median:
    shr rbx, 1
    movsd xmm1, [rdi + (rbx * 8) - 8]
    movsd xmm0, [rdi + (rbx * 8)]
    addsd xmm0, xmm1
    mov rax, 0x3FE0000000000000  ; 0.5 in IEEE 754 double-precision format
    movq xmm1, rax               ; Move the constant 0.5 into xmm1
    ; Divide xmm0 by 2 (multiply by 0.5)
    mulsd xmm0, xmm1

.proc_done:
_endp
