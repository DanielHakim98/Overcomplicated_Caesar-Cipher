.include "constants.s"

.section .text
.globl shift_character
.type shift_character, @function

shift_character: # *[]char %rbx, index %rsi, shifter %rcx
    # prologue
    prologue:
        pushq %rbp
        movq %rsp, %rbp
        subq $8, %rsp      # allocate a local variable

    body:
        movq 16(%rbp), %rbx # First argument: *[]char
        movq 24(%rbp), %rsi # Second argument: index
        movq 32(%rbp), %rcx # Third argument: shifter

        # Fetch nth element into rdx
        movb (%rbx, %rsi, 1), %dl

        # store old value
        movq %rdx, -8(%rbp)

        # add shifter to nth element
        addq %rcx, %rdx

    check_wrap:
        # Update (12/11/23) - Compare characters the best with cmpb
        # Do not use cmpq to compare whole 64 bit register just to compare
        # character
        cmpb $UPPERCASE_A, %dl
        jl fix_wrapping_less_than_upper_a

        cmpb $UPPERCASE_Z, %dl
        jle epilogue

        cmpb $LOWERCASE_A, %dl
        jl less_than_lower_a_or_more_than_upper_z

        cmpb $LOWERCASE_Z, %dl
        jle epilogue

        jmp fix_wrapping_more_than_lower_z


    fix_wrapping_less_than_upper_a:
        add $26, %dl
        cmpb $UPPERCASE_A, %dl
        jl fix_wrapping_less_than_upper_a
        jmp epilogue

    less_than_lower_a_or_more_than_upper_z:
        # check old value before shifted if it's less than Z or more
        pushq %rdx
        movq -8(%rbp), %rdx
        # This command below won't trigger jump is less (jle)
        # not sure why. I'm curious why...
        # cmpq $UPPERCASE_Z, %rdx
        cmpb $UPPERCASE_Z, %dl
        popq %rdx
        jle fix_wrapping_more_than_upper_z  # Jump if less than or equal to UPPERCASE_Z
        jmp fix_wrapping_less_than_lower_a

    fix_wrapping_more_than_upper_z:
        subq $26, %rdx
        cmpb $UPPERCASE_Z, %dl
        jg fix_wrapping_more_than_upper_z
        jmp epilogue

    fix_wrapping_less_than_lower_a:
        addb $26, %dl
        cmpb $LOWERCASE_A, %dl
        jl fix_wrapping_less_than_lower_a
        jmp epilogue


    fix_wrapping_more_than_lower_z:
        subq $26, %rdx
        cmpb $LOWERCASE_Z, %dl
        jg fix_wrapping_more_than_lower_z
        jmp epilogue

    epilogue:

        # store back nth element into *[]char
        movb %dl, (%rbx, %rsi, 1)

        # epilogue
        addq $8, %rsp       # deallocate a local variable
        movq %rbp, %rsp
        popq %rbp
        ret

