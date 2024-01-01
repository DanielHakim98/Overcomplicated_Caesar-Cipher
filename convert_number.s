.include "constants.s"

.section .text
.globl atoi
.type atoi, @function

atoi:
    prologue:
        pushq %rbp
        movq %rsp, %rbp
        movq 16(%rbp), %rbx

    head:
        # Dereference pointer in rbx and move the value to rsi
        movq $0, %rsi
        movq (%rbx, %rsi, 1), %rcx

        # If minus sign, then skip
        cmpb $HYPHEN_MINUS, %cl
        je is_minus

        # Check if current value in rsi is a number
        cmpb $ZERO_ASCII, %cl      # Compare the value if 0 ASCII
        jl not_number              # If it's less than 0, jump to not_a_number
        cmpb $NINE_ASCII, %cl      # Compare the value with 9 ASCII
        jg not_number              # If it's greater than 57, jump to not_a_number

        # Substract with ASCII decimal 49 to get decimal number
        subq $ZERO_ASCII, %rcx
        movq $0, %rax
        addq %rcx,%rax

    next:
        # Increase current index by 1
        incq %rsi

        # Dereference pointer in rbx at current index and move into rsi
        movq (%rbx, %rsi, 1), %rcx

        # Check if current value is null terminated
        cmpb $0, %cl
        je epilogue

        # Check if current value in rsi is a number
        cmpb $ZERO_ASCII, %cl      # Compare the value if 0 ASCII
        jl not_number              # If it's less than 0, jump to not_a_number
        cmpb $NINE_ASCII, %cl      # Compare the value with 9 ASCII
        jg not_number              # If it's greater than 57, jump to not_a_number

        # Substract with ASCII decimal 49 to get decimal number
        subq $ZERO_ASCII, %rcx
        imulq $10, %rax
        addq %rcx, %rax

        jmp next

    is_minus:
        xorq %rcx, %rcx
        xorq %rax, %rax
        jmp next

    epilogue:
        movq %rbp, %rsp
        popq %rbp
        ret

not_number:
    # Write *[]char to stdout
    movq $SYS_WRITE, %rax
    movq $STDOUT, %rdi
    movq $ERR_NOT_NUM, %rsi
    movq $LEN_ERR_NOT_NUM, %rdx
    syscall
    # Exit status
    movq $1, %rsi
    movq %rsi, %rdi
    movq $SYS_EXIT, %rax
    syscall
