[section .text]
[bits 64]
[global start64]
[extern kernel_main]
start64:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov rcx, qword higher_half
    jmp rcx
higher_half:
    invlpg [0]
    
    add rsp, 0xFFFFFF8000000000 ; stack pointer for higher half
    add rdi, 0xFFFFFF8000000000 ; multiboot2 ptr for higher half

    call kernel_main ; calling c function kernel_main
    
    jmp $ ; infinite loop