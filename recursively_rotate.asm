
.data

space: .asciiz " "
escapen: .asciiz "\n"
matrix: .word 0:65536

# Given a Matrix as input, this MIPS asm will rotate it recursively


# FIXME: no matrix() but with $a0


.text
.globl main

main:
	#read matrix side
	li $v0,5
	syscall
	move $a0,$v0
	jal get2NPower
	move $s0,$v0
	mul $t0,$v0,$v0
	sll $t0,$t0,2
	
	#read matrix numbers
	loop_reader:
	li $v0,5
	syscall
	sw $v0,matrix($t1)
	addi $t1,$t1,4
	blt  $t1,$t0,loop_reader

	#rotate Counter-Clockwise recursively
	la $a0,matrix
	move $a1,$s0
	jal rotateCW
	
	#print matrix
	la $a0,matrix
	move $a1,$s0
	jal printMatrix
exit:
	li $v0,10
	syscall	

#rotate a matrix counter-clockwise recursively
#
# $a0 -> matrix address
# $a1 -> matrix side
rotateCW:
	addi $sp,$sp,-4	
	sw $ra,0($sp)
	li $a2,0
	li $a3,0
	jal rotateMagic	
	lw $ra,0($sp)
	addi $sp,$sp,4	
	jr $ra										

rotateMagic:
	addi $sp,$sp,-20
	sw $ra,0($sp)
	sw $a0,4($sp)
	sw $a1,8($sp)
	sw $a2,12($sp)
	sw $a3,16($sp)
	beq $a1,1,rotateMagic_return
	srl $a1,$a1,1
	jal rotateMagic
	lw $a0,4($sp)
	lw $a1,8($sp)
	lw $a2,12($sp)
	lw $a3,16($sp)
	srl $a1,$a1,1
	add $a2,$a2,$a1
	jal rotateMagic
	lw $a0,4($sp)
	lw $a1,8($sp)
	lw $a2,12($sp)
	lw $a3,16($sp)
	srl $a1,$a1,1
	add $a3,$a3,$a1
	jal rotateMagic
	lw $a0,4($sp)
	lw $a1,8($sp)
	lw $a2,12($sp)
	lw $a3,16($sp)
	srl $a1,$a1,1
	add $a2,$a2,$a1
	add $a3,$a3,$a1
	jal rotateMagic
	lw $a0,4($sp)
	lw $a1,8($sp)
	lw $a2,12($sp)
	lw $a3,16($sp)
	jal blocksRotator
	rotateMagic_return:
	lw $ra,0($sp)
	lw $a0,4($sp)
	lw $a1,8($sp)
	lw $a2,12($sp)
	lw $a3,16($sp)
	addi $sp,$sp,20
	jr $ra	

# rotate the 4 blocks of the submatrix
#
# $a0 -> matrix address
# $a1 -> matrix side
# $a2 -> offset x
# $a3 -> offset y
blocksRotator:
	move $t0,$a2
	srl $t1,$a1,1
	add $t1,$a2,$t1
	move $t2,$a3
	add $t3,$a3,$a1
	
	ciclo1:
	beq $t0,$t1,endciclo1
		move $t2,$a3
		ciclo2:
		beq  $t2,$t3,endciclo2
		#address 1
		mul $t4,$t2,$s0
		add $t4,$t4,$t0
		#address 2 
		srl $s7,$a1,1
		add $t5,$t4,$s7
		#address 3
		sub $t6,$t2,$s7
		mul $t6,$t6,$s0
		add $t6,$t6,$t0
		add $t6,$t6,$s7
		#word addresses
		sll $t4,$t4,2
		sll $t5,$t5,2
		sll $t6,$t6,2
		#swap address 1 with address 2
		lw $t7,matrix($t5)
		lw $t8,matrix($t4)
		sw $t8,matrix($t5)
		sw $t7,matrix($t4)
		
		add $t9,$a3,$s7
		blt $t2,$t9,end
		#swap address 1 with address 3
		lw $t7,matrix($t6)
		lw $t8,matrix($t4)
		sw $t8,matrix($t6)
		sw $t7,matrix($t4)
		end: add $t2,$t2,1
		j ciclo2
		endciclo2:
	add $t0,$t0,1
	j ciclo1
	endciclo1: jr $ra

#get 2^n value
#
# $a0 -> n value
# $v0 -> result
get2NPower:
	li $v0,1
	sllv $v0,$v0,$a0
	jr $ra

#print the selected matrix
#
# $a0 -> matrix address
# $a1 -> matrix side
printMatrix:
	li $t6,1
	move $t0,$zero
	move $t3,$a0
	mul $t1,$a1,$a1
	sll $t1,$t1,2
	loop_writer:
	bne $t6,$a1,notreset
	move $t6,$zero
	notreset:
	li $v0,1
	add $t2,$t3,$t0
	
	lw $a0,($t2)
	syscall
	beqz  $t0,jump
	beq $t0,$t1,jump
	bnez $t6,jump
	li $v0,11
	li $a0,13
	syscall
	li $v0,11
	li $a0,10
	syscall
	j jump2
	jump:
	li $v0,11
	li $a0,32
	syscall
	jump2:
	addi $t0,$t0,4
	addi $t6,$t6,1
	blt $t0,$t1,loop_writer
	jr $ra


	


printMatrix2:
	move $t3,$zero
    	mul $t2,$a1,$a1
	sll $t2,$t2,2
    	move $t0,$a0
	loop2:
	li $v0,1
	add $t1,$t0,$t3
	lw $a0,($t1)
	syscall
	li $v0, 4
	la $a0, space
	syscall
	add $t7,$t2,-4
	beq $t3,$t7,end_loop
	#print \n
	srl $t5,$t3,2
	add $t5,$t5,1
	div $t4,$t5,$a1
	mfhi $t5
	beq $t5,$zero,print_newline
	end_print_newline:
	add $t3,$t3,4
	blt $t3,$t2,loop2
	end_loop:
	jr $ra	
	print_newline:
	li $v0,4
	la $a0,escapen
	syscall
	j end_print_newline
