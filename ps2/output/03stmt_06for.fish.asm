	.text
	.align	2
	.globl main
main:
	addi	$30, $29, 0x0
	addi	$29, $30, 0xFFFFFFF0
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
L2:
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0xA
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
	beq	$8, $9, L1
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
L4:
	lw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
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
	beq	$8, $9, L3
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
L6:
	lw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
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
	beq	$8, $9, L5
	lw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L6
L5:
	lw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L4
L3:
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L2
L1:
	lw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	ori	$3, $2, 0x0
	jr	$31
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)


	.data
	.align 0

