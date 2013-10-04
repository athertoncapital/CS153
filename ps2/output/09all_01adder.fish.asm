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
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L60
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L59
L60:
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
L59:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L58
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L57
L58:
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
L57:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L56
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L55
L56:
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
L55:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L54
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
	addi	$3, $2, 0x0
	jr	$31
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	j L53
L54:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L53:
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
	beq	$8, $9, L52
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
	j L51
L52:
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
L51:
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
	beq	$8, $9, L50
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
	j L49
L50:
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
L49:
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
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L48
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L47
L48:
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
L47:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L44
	lw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L46
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L45
L46:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L45:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L43
L44:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L43:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L42
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
	j L41
L42:
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
L41:
	lw	$8, -24($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L40
	lw	$8, -36($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L39
L40:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L39:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L38
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
	j L37
L38:
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
L37:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L36
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L35
L36:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L35:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L34
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L33
L34:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L33:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L28
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L27
L28:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L32
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L31
L32:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L31:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L30
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L29
L30:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L29:
L27:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L22
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L21
L22:
	lw	$8, -28($30)
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
	li	$9, 0x0
	beq	$8, $9, L26
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L25
L26:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L25:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L24
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L23
L24:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L23:
L21:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L16
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L15
L16:
	lw	$8, -28($30)
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
	li	$9, 0x0
	beq	$8, $9, L20
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	seq	$8, $8, $9
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L19
L20:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L19:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L18
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L17
L18:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L17:
L15:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L14
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
	j L13
L14:
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
L13:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L12
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L11
L12:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L11:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L8
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L7
L8:
	lw	$8, -28($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L10
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L9
L10:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L9:
L7:
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L4
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x1
	sw	$8, 0($29)
	j L3
L4:
	lw	$8, -40($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	lw	$8, 0($29)
	addi	$29, $29, 0x4
	li	$9, 0x0
	beq	$8, $9, L6
	lw	$8, -4($30)
	addi	$29, $29, 0xFFFFFFFC
	sw	$8, 0($29)
	j L5
L6:
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
L5:
L3:
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
	addi	$3, $2, 0x0
	jr	$31
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)
	addi	$29, $29, 0xFFFFFFFC
	li	$8, 0x0
	sw	$8, 0($29)


	.data
	.align 0

