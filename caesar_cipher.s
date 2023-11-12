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

ERR_NOT_NUM:
    .string "Shifter is not a number\n"
END_ERR_NOT_NUM:
    LEN_ERR_NOT_NUM = . - ERR_NOT_NUM

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
    movzbq (%rdx), %rdx         # Dereference the pointer in RDX and zero-extend it

    cmpq $ZERO_ASCII, %rdx      # Compare the value if 0 ASCII
    jl not_number               # If it's less than 0, jump to not_a_number
    cmpq $NINE_ASCII, %rdx      # Compare the value with 9 ASCII
    jg not_number               # If it's greater than 57, jump to not_a_number

start_loop:
    # Load index 0
    movq $0, %rsi

    # Fetch 1st element into rax
    movb (%rbx, %rsi, 1), %dl

    # If 1st element equals 0, then exit loop
    cmpb $0, %dl
    je exit_loop

continue_loop:
    # Increment index by 1
    incq %rsi

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl

    # If nth element equals 0 (null terminated), then exit loop
    cmpb $0, %dl
    je exit_loop

    # loop again!!
    jmp continue_loop

not_number:
    movq $SYS_WRITE, %rax
    movq $STDOUT, %rdi
    movq $ERR_NOT_NUM, %rsi
    movq $LEN_ERR_NOT_NUM, %rdx
    syscall

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

exit:
    movq $0, %rdi
    movq $SYS_EXIT, %rax
    syscall







# convert ascii representation to decimal
# for example 1 is 49 in ASCII, and 0 is 48 is ASCII
# so 49-48 = 1
# result will be loaded into registers
ascii_to_dec:
    subq $ZERO_ASCII, %rbx
    subq $ZERO_ASCII, %rdx

# shifting data by second argument 'shifter'
shifting:
    addq %rbx, %rdx

