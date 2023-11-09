.section .data
.equ SYS_EXIT, 60

.equ ARG_NUM, 0
.equ ARG_0, 8
.equ ARG_1, 16
.equ ARG_2, 24
.equ ZERO_ASCII, 48

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

# As the data passed as pointers,
# this process is to dereferences them
# to get the value passed in
derefernce_pointer:
    movq (%rbx), %rbx
    movq (%rdx), %rdx

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

# copy data into rdi register as status code for SYS_EXIT
copy_into_rdi:
    movq %rdx, %rdi

exit:
    movq $SYS_EXIT, %rax
    syscall
