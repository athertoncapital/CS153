	.text
	.align	2
fibo:
	lw	$8, -4($16)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sle	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L%2
	lw	$8, -4($16)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	jr	$31
	j L%1
L%2:
	sw	$4, 0($30)
	sw	$5, 4($30)
	sw	$6, 8($30)
	sw	$7, 12($30)
	sw	$31, -4($16)
	sw	$30, -8($16)
	addi	$30, $30, 0xFFFFFFE4
	sw	$16, -12($29)
	addi	$16, $29, 0x0
	addi	$29, $29, 0xFFFFFFE4
	lw	$8, -4($16)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sub	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$4, 0($29)
	addi	$29, $29, 0x4
	jal fibo
	addi	$29, $16, 0x0
	lw	$31, -4($29)
	lw	$30, -8($29)
	lw	$16, -12($29)
	lw	$4, 0($30)
	lw	$5, 4($30)
	lw	$6, 8($30)
	lw	$7, 12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$2, 0($29)
	sw	$4, 0($30)
	sw	$5, 4($30)
	sw	$6, 8($30)
	sw	$7, 12($30)
	sw	$31, -4($16)
	sw	$30, -8($16)
	addi	$30, $30, 0xFFFFFFE4
	sw	$16, -12($29)
	addi	$16, $29, 0x0
	addi	$29, $29, 0xFFFFFFE4
	lw	$8, -4($16)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sub	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$4, 0($29)
	addi	$29, $29, 0x4
	jal fibo
	addi	$29, $16, 0x0
	lw	$31, -4($29)
	lw	$30, -8($29)
	lw	$16, -12($29)
	lw	$4, 0($30)
	lw	$5, 4($30)
	lw	$6, 8($30)
	lw	$7, 12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$2, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	jr	$31
L%1:
main:
	addi	$16, $30, 0x0
	addi	$29, $30, 0x1C
	sw	$4, 0($30)
	sw	$5, 4($30)
	sw	$6, 8($30)
	sw	$7, 12($30)
	sw	$31, -4($16)
	sw	$30, -8($16)
	addi	$30, $30, 0xFFFFFFE4
	sw	$16, -12($29)
	addi	$16, $29, 0x0
	addi	$29, $29, 0xFFFFFFE4
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0xB
	sw	$8, 0($29)
	lw	$4, 0($29)
	addi	$29, $29, 0x4
	jal fibo
	addi	$29, $16, 0x0
	lw	$31, -4($29)
	lw	$30, -8($29)
	lw	$16, -12($29)
	lw	$4, 0($30)
	lw	$5, 4($30)
	lw	$6, 8($30)
	lw	$7, 12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$2, 0($29)
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	jr	$31


	.data
	.align 0

#
# below here is the print debugging support code
#
	
.data
_spaceString: .asciiz " "
_newlineString: .asciiz "\n"

.text
.globl printInt     # int reg -> unit
.globl printSpace   # unit    -> unit
.globl printNewline # unit    -> unit

printInt: # int reg->unit
	                  # The syscall takes its argument in $a0
   add $t0, $v0, $zero    # since this function does not return anything, it should probably preserve $v0
   li $v0, 1              # print_int syscall
   syscall
   add $v0, $t0, $zero    # restore $v0 
jr $ra


printSpace: # unit->unit
add $t0, $v0, $zero
la $a0, _spaceString      # address of string to print
li $v0, 4                 # system call code for print_str
syscall                   # print the string
add $v0, $t0, $zero
jr $ra

printNewline: # unit->unit
add $t0, $v0, $zero
la $a0, _newlineString    # address of string to print
li $v0, 4                 # system call code for print_str
syscall                   # print the string
add $v0, $t0, $zero
jr $ra