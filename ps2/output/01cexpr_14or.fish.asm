	.text
	.align	2
	.globl main
main:
	addi	$30, $29, 0x0
	addi	$29, $30, 0x0
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0xF
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L2
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L1
L2:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L1:
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	addi	$3, $2, 0x0
	jr	$31
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)


	.data
	.align 0

