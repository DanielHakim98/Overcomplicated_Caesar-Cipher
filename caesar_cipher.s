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
    movzbq (%rdx), %rcx         # Dereference the pointer in RDX and zero-extend it in RCX

    cmpq $ZERO_ASCII, %rcx      # Compare the value if 0 ASCII
    jl not_number               # If it's less than 0, jump to not_a_number
    cmpq $NINE_ASCII, %rcx      # Compare the value with 9 ASCII
    jg not_number               # If it's greater than 57, jump to not_a_number

start_loop:
    # Load index 0
    movq $0, %rsi

    # Fetch 1st element into rax
    movb (%rbx, %rsi, 1), %dl

    # If 1st element equals 0, then exit loop
    cmpb $0, %dl
    je exit_loop

    # Convert ascii to decimal
    subq $ZERO_ASCII, %rcx

    # Add shifter to original
    addq %rcx, %rdx
    movb %dl, (%rbx, %rsi, 1)

continue_loop:
    # Increment index by 1
    incq %rsi

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl

    # If nth element equals 0 (null terminated), then exit loop
    cmpb $0, %dl
    je exit_loop

    # Add shifter to original
    addq %rcx, %rdx
    movb %dl, (%rbx, %rsi, 1)

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







# convert ascii representation to decimal
# for example 1 is 49 in ASCII, and 0 is 48 is ASCII
# so 49-48 = 1
# result will be loaded into registers
ascii_to_dec:
    subq $ZERO_ASCII, %rdx

# shifting data by second argument 'shifter'
shifting:
    addq %rbx, %rdx

