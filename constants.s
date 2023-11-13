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
.equ UPPERCASE_A, 65
.equ UPPERCASE_Z, 90
.equ LOWERCASE_A, 97
.equ LOWERCASE_Z, 122


# string for displaying error
ERR_NOT_NUM:
    .string "Shifter is not a number\n"
END_ERR_NOT_NUM:
    LEN_ERR_NOT_NUM = . - ERR_NOT_NUM


# Buffer size
.equ BUFFER_SIZE, 1024
.lcomm BUFFER_DATA, BUFFER_SIZE

