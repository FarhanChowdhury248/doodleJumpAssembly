.text

.globl loadData

loadData:
	# get colors we will use
	li $t1, 0xf2ff00			# $t1 stores yellow
	li $t2, 0x219300			# $t2 stores green
	li $t3, 0x914100			# $t3 stores brown
	li $t4, 0x000000			# $t4 stores black
	
	# load player data
	la $t0, playerSpriteColorData # get color data
	
	LOOPINIT:				# loop over entire array, store yellow in all
		li $v0, 35
	WHILE:
		bltz $v0, LOOPDONE
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $v0, $v0, -1
		j WHILE
	LOOPDONE:
	
	# load basicPlatformData
	la $t0, basicPlatforms # load addr of basicPlatforms arr
	sw $t0, basicPlatformsPointer # store it in the pointer
	
	la $t0, basicPlatformColorData # get addr of color data
	li $v0, 176
	loop2:
		add $v1, $v0, $t0 # v1 = addr(basicPlatformColorData) + offset
		sw $t3, 0($v1) # store brown in v1
		addi $v0, $v0, -4 # v0 -= 4 to go back by 4 bytes
		bltz $v0, loop2done # exit loop if done
		j loop2
	loop2done:
	
	jr $ra
