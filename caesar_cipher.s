.section .data
# Syscall code
.equ SYS_EXIT, 60
.equ SYS_WRITE, 1

# Standard file descriptors
.equ STDOUT, 1

# For CLI arguments
.equ ARG_NUM, 0
.equ ARG_0, 8
.equ ARG_1, 16
.equ ARG_2, 24

# ASCII to decimal
.equ ZERO_ASCII, 48
.equ NINE_ASCII, 57
.equ NULL_TERMINATE_ASCII, 0
.equ END_LINE_ASCII, 10


# ASCII Characters boundary
.equ LOWERCASE_A, 'a'
.equ LOWERCASE_Z, 'z'
.equ UPPERCASE_A, 'A'
.equ UPPERCASE_Z, 'Z

# string for displaying error
ERR_NOT_NUM:
    .string "Shifter is not a number\n"
END_ERR_NOT_NUM:
    LEN_ERR_NOT_NUM = . - ERR_NOT_NUM


# Buffer sizse
.equ BUFFER_SIZE, 1024
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
.globl _start

# load stack pointer into base pointer register
_start:
    movq %rsp, %rbp

# load cli arguments
# data & shifter
# into rbx and rdx register
collect_args:
    movq ARG_1(%rbp), %rbx
    movq ARG_2(%rbp), %rdx

check_shifter:
    # Dereference pointer into ascii decimal and then zero extend it
    movzbq (%rdx), %rcx
    # Compare the value if 0 ASCII
    cmpq $ZERO_ASCII, %rcx
    # If it's less than 0, jump to not_a_number
    jl not_number
    # Compare the value with 9 ASCII
    cmpq $NINE_ASCII, %rcx
    # If it's greater than 57, jump to not_a_number
    jg not_number

start_loop:
    # Load index 0
    movq $0, %rsi

    # Fetch 1st element into rax
    movb (%rbx, %rsi, 1), %dl

    # If 1st element equals 0, then exit loop
    cmpb $0, %dl
    je exit_loop

    # FUNCTION: Get decimal value from rcx (if 48, then 0, if 49, then 1)
    pushq %rcx
    call get_decimal_value
    popq %rcx
    movq %rax, %rcx
    # ======= #

    # FUNCTION: Add shifter to original
    pushq %rcx
    pushq %rsi
    pushq %rbx
    call shift_character
    popq %rbx
    popq %rsi
    popq %rcx
    # ======= #

continue_loop:
    # Increment index by 1
    incq %rsi

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl

    # If nth element equals 0 (null terminated), then exit loop
    cmpb $0, %dl
    je exit_loop

    # FUNCTION: Add shifter to original
    pushq %rcx
    pushq %rsi
    pushq %rbx
    call shift_character
    popq %rbx
    popq %rsi
    popq %rcx
    # ======= #

    # loop again!!
    jmp continue_loop

not_number:
    # Write *[]char to stdout
    movq $SYS_WRITE, %rax
    movq $STDOUT, %rdi
    movq $ERR_NOT_NUM, %rsi
    movq $LEN_ERR_NOT_NUM, %rdx
    syscall
    # Exit status
    movq $1, %rsi
    jmp exit

exit_loop:
    # Add end of sequence (LF)
    movb $END_LINE_ASCII, (%rbx, %rsi, 1)  # Add newline char

    # Increment index to store 1 extra character
    incq %rsi
    movb $NULL_TERMINATE_ASCII, (%rbx, %rsi, 1)   # Append back \0

display:
    movq $SYS_WRITE, %rax
    movq $STDOUT, %rdi
    movq %rsi, %rdx
    movq %rbx, %rsi
    syscall
    # Exit status
    movq $0, %rsi

exit:
    movq %rsi, %rdi
    movq $SYS_EXIT, %rax
    syscall

get_decimal_value:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rax
    subq $ZERO_ASCII, %rax

    # epilogue
    movq %rbp, %rsp
    popq %rbp
    ret

shift_character: # *[]char %rbx, index %rsi, shifter %rcx
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rbx # First argument: *[]char
    movq 24(%rbp), %rsi # Second argument: index
    movq 32(%rbp), %rcx # Third argument: shifter

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl
    # add shifter to nth element
    addq %rcx, %rdx
    # store back nth element into *[]char
    movb %dl, (%rbx, %rsi, 1)

    # epilogue
    movq %rbp, %rsp
    popq %rbp
    ret



