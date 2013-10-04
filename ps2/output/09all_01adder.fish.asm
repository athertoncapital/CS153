	.text
	.align	2
	.globl main
main:
	addi	$30, $29, 0x0
	addi	$29, $30, 0xFFFFFFD8
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -20($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x3
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -32($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -20($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	slt	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -20($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x3
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sgt	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -32($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	slt	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -32($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x3
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sgt	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L14
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
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
	lw	$2, 0($29)
	addi	$29, $29, 0x4
	ori	$3, $2, 0x0
	jr	$31
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L13
L14:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L13:
	lw	$8, -20($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sge	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L12
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L11
L12:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L11:
	lw	$8, -20($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	mul	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sub	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -32($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sge	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L10
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L9
L10:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L9:
	lw	$8, -32($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	mul	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sub	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L8
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L7
L8:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -12($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L7:
	lw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L6
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L5
L6:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L5:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L4
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L3
L4:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L3:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	and	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	or	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L2
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L1
L2:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	sw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L1:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x4
	sw	$8, 0($29)
	lw	$8, -8($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	mul	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x2
	sw	$8, 0($29)
	lw	$8, -16($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	mul	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$9, 0($29)
	addi	$29, $29, 0x4
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	add	$8, $8, $9
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

