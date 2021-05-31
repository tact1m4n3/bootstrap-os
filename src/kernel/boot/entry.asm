KERNEL_OFFSET equ 0xFFFFFF8000000000

[section .text]
[bits 32]
[global start]
[extern start64]
start:
    cli ; disable 32 bit interrupts

    ; setting up a temp stack pointer
    mov esp, stack_top - KERNEL_OFFSET

    ; saving multiboot2 info for later use
    mov edi, ebx

    ; checking for long mode support
    call check_cpuid
    call check_long_mode

    ; setting up paging and long mode
    call setup_page_tables
    call enable_paging

    ; setting up the temp global descriptor table
    lgdt [gdt64.pointer - KERNEL_OFFSET]
    
    jmp gdt64.kernel_code:start64 - KERNEL_OFFSET

    hlt

check_cpuid:
    pushfd

    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax

    popfd

    pushfd
    pop eax
    push ecx
    popfd

    cmp eax, ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov al, 'C'
    jmp error

check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .no_long_mode
    ret
.no_long_mode:
    mov al, 'L'
    jmp error

setup_page_tables:
    ; setting up the page tables
    mov eax, page_table_l3 - KERNEL_OFFSET
    or eax, 0b11
    mov [page_table_l4 - KERNEL_OFFSET], eax
    mov [page_table_l4 + 511 * 8 - KERNEL_OFFSET], eax

    mov eax, page_table_l2 - KERNEL_OFFSET
    or eax, 0b11
    mov [page_table_l3 - KERNEL_OFFSET], eax

    mov eax, page_table_l1 - KERNEL_OFFSET
    or eax, 0b11
    mov [page_table_l2 - KERNEL_OFFSET], eax

    mov eax, page_table_l1 + 512 * 8 - KERNEL_OFFSET
    or eax, 0b11
    mov [page_table_l2 + 1 * 8 - KERNEL_OFFSET], eax

    ; Mapping 2MB of memory
    mov ecx, 0
.loop:
    mov eax, 0x1000
    mul ecx
    or eax, 0b10000011
    mov [page_table_l1 + ecx * 8 - KERNEL_OFFSET], eax

    inc ecx
    cmp ecx, 512
    jne .loop

    ret

enable_paging:
    ; telling the cpu the page table address
    mov eax, page_table_l4 - KERNEL_OFFSET
    mov cr3, eax

    ; setting PAE bit
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; enabling long mode
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enabling paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret

error:
    ; formating the error message (ERR: + code)
    mov dword [0xb8000 + 0], 0x4f524f45
    mov dword [0xb8000 + 4], 0x4f3a4f52
    mov dword [0xb8000 + 8], 0x4f204f20
    mov byte [0xb8000 + 10], al

    hlt

[section .bss]
align 4096
page_table_l4:
    resb 4096
page_table_l3:
    resb 4096
page_table_l2:
    resb 4096
page_table_l1:
    resb 4096
stack_bottom:
    resb 4096 * 4
stack_top:

[section .rodata]
gdt64:
    dq 0
.kernel_code: equ $ - gdt64
    dw 0
    dw 0
    db 0
    db 10011010b
    db 10100000b
    db 0
.pointer:
    dw $ - gdt64 - 1
    dq gdt64 - KERNEL_OFFSET
