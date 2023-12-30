.include "constants.s"

.section .text
.globl shift_character
.type shift_character, @function


# UPDATE (31/12/23): Solve edge cases when char + shifter reaches 128 (0x80)
#                    Example, expected H + 56 == L but got P instead.
#                    because 72 + 56 = 128 or 0x80 which is treated as negative
#                    if signed instruction is used. So some instruction are changes
#                    to only work with unsigned such as jl -> jb, jg -> ja and cmpb/cmpq -> cmp
shift_character:         # *[]char %rbx, index %rsi, shifter %rcx
    pushq %rbp
    movq %rsp, %rbp

    movq 16(%rbp), %rbx # First argument: *[]char
    movq 24(%rbp), %rsi # Second argument: index
    movq 32(%rbp), %rcx # Third argument: shifter

    # Fetch nth element into rdx
    # ASCII characters at most in 7 bits if I'm not mistaken
    movl $0, %eax
    movq (%rbx, %rsi, 1), %rdx

    is_uppercase_or_lowercase:
        cmpb $UPPERCASE_A, %dl
        jl not_upper_nor_lower   # if %dl < 65

        cmpb $UPPERCASE_Z, %dl  # if %dl <= 90
        jle is_upper

        cmpb $LOWERCASE_A, %dl  # if %dl < 97
        jl not_upper_nor_lower

        cmpb $LOWERCASE_Z, %dl  # if %dl < 122
        jle is_lower

        # Auto jump to not_upper_nor_lower if %dl > 122

    not_upper_nor_lower:
        jmp epilogue

    is_upper:
        addq %rcx, %rdx     # add shifter to nth element
        jmp check_wrap_upper

    is_lower:
        addq %rcx, %rdx
        jmp check_wrap_lower

    check_wrap_upper:
        cmp $UPPERCASE_A, %dl
        jb wrap_less_than_upper_a   # shifted char < 65
        cmp $UPPERCASE_Z, %dl
        jbe epilogue                # shifted char within 65-90
        jmp wrap_more_than_upper_z  # shifted char > 90

    wrap_less_than_upper_a:
        # need to reconfirm
        addq $26, %rdx
        cmp $UPPERCASE_A, %dl
        jb wrap_less_than_upper_a   # loop again if shifted char still < 65
        jmp epilogue                # jmp to end if okay

    wrap_more_than_upper_z:
        # need to reconfirm
        subq $26, %rdx
        cmp $UPPERCASE_Z, %dl
        ja wrap_more_than_upper_z       # loop again if shited char > 90
        jmp epilogue                    # jmp to end if okay

    check_wrap_lower:
        cmp $LOWERCASE_A, %dl
        jb wrap_less_than_lower_a   # shifted char < 97

        cmp $LOWERCASE_Z, %dl
        jbe epilogue                # shifted char within 97-122

        jmp wrap_more_than_lower_z  # shifted char > 122


    wrap_less_than_lower_a:
        # need to reconfirm
        addq $26, %rdx
        cmp $LOWERCASE_A, %dl
        jb wrap_less_than_lower_a   # loop again if shifted char still < 97
        jmp epilogue                # jmp to end if okay

    wrap_more_than_lower_z:
        # need to reconfirm
        subq $26, %rdx
        cmp $LOWERCASE_Z, %dl
        ja wrap_more_than_lower_z       # loop again if shited char > 122
        jmp epilogue # jmp to end if okay (%dl <= 122)

    epilogue:
        # store back nth element into *[]char
        movb %dl, (%rbx, %rsi, 1)
        movq %rbp, %rsp
        popq %rbp
        ret

emergency:
    # Exit status
    movq %rsi, %rdi
    movq $SYS_EXIT, %rax
    syscall
