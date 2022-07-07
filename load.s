.text

.globl loadData

loadData:
	# load player data
	la $t0, playerSpriteColorData
	li $t1, 0xf2ff00			# $t1 stores yellow
	li $t2, 0x219300			# $t2 stores green
	li $t3, 0x914100			# $t3 stores brown
	li $t4, 0x000000			# $t4 stores black
	
	LOOPINIT:				# loop over entire array, store yellow
		li $v0, 35
	WHILE:
		bltz $v0, LOOPDONE
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $v0, $v0, -1
		j WHILE
	LOOPDONE:
	jr $ra