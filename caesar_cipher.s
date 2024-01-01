.include "constants.s"


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
    movq ARG_2(%rbp), %rcx

start_loop:
    # Load index 0
    movq $0, %rsi

    # Fetch 1st element into rdx
    movb (%rbx, %rsi, 1), %dl

    # If 1st element equals 0, then exit loop
    cmpb $0, %dl
    je exit_loop

    # move signess (positive or negative) to rax
    movb (%rcx, %rsi, 1), %al

    # save previous rax value before func call
    pushq %rax
    # FUNCTION: Get decimal value from rcx (if 48, then 0, if 49, then 1)
    pushq %rbx
    pushq %rsi
    pushq %rdx
    pushq %rcx
    call atoi
    popq %rcx
    popq %rdx
    popq %rsi
    popq %rbx
    # move return value from rax into rcx (shifter)
    movq %rax, %rcx
    # ======= #

    # get back previous saved rax value after func all
    popq %rax

is_ascii_alphabet:
    # FUNCTION: Add shifter to original
    pushq %rax
    pushq %rcx
    pushq %rsi
    pushq %rbx
    call shift_character
    popq %rbx
    popq %rsi
    popq %rcx
    popq %rax
    # ======= #



continue_loop:
    # Increment index by 1
    incq %rsi

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl

    # If nth element equals 0 (null terminated), then exit loop
    cmpb $0, %dl
    je exit_loop

    # shift character and loop again!!
    jmp is_ascii_alphabet


exit_loop:
    # Add end of sequence (LF)
    movb $END_LINE_ASCII, (%rbx, %rsi, 1)  # Add newline char

    # Increment index to store 1 extra character
    incq %rsi
    movb $NULL_TERMINATE_ASCII, (%rbx, %rsi, 1)   # Append back \0

display_shifted_string:
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

