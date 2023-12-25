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

    movq %rax, %rcx
    # ======= #

    # Check if %dl is an ASCII character (a-zA-Z)
    cmpb $UPPERCASE_A, %dl      # Compare with 'A'
    jl not_ascii_alphabet
    cmpb $UPPERCASE_Z, %dl      # Compare with 'Z'
    jle is_ascii_alphabet

    cmpb $LOWERCASE_A, %dl      # Compare with 'a'
    jl not_ascii_alphabet
    cmpb $LOWERCASE_Z, %dl      # Compare with 'z'
    jle is_ascii_alphabet

not_ascii_alphabet:
    jmp continue_loop

is_ascii_alphabet:
    # FUNCTION: Add shifter to original
    pushq %rcx
    pushq %rsi
    pushq %rbx
    call shift_character
    popq %rbx
    popq %rsi
    popq %rcx
    # breakpoint
    #movq (%rbx), %rsi
    #jmp exit
    # ======= #

continue_loop:
    # Increment index by 1
    incq %rsi

    # Fetch nth element into rax
    movb (%rbx, %rsi, 1), %dl

    # If nth element equals 0 (null terminated), then exit loop
    cmpb $0, %dl
    je exit_loop

    # Check if %dl is an ASCII character (a-zA-Z)
    cmpb $UPPERCASE_A, %dl      # Compare with 'A'
    jl not_ascii_alphabet
    cmpb $UPPERCASE_Z, %dl      # Compare with 'Z'
    jle is_ascii_alphabet

    cmpb $LOWERCASE_A, %dl      # Compare with 'a'
    jl not_ascii_alphabet
    cmpb $LOWERCASE_Z, %dl      # Compare with 'z'
    jle is_ascii_alphabet

    # loop again!!
    jmp continue_loop


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

