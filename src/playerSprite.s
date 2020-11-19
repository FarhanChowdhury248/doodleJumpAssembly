.data
	# location vars
	playerSpriteX: .word 30
	playerSpriteY: .word 34
	playerSpriteWidth: .word 6
	playerSpriteHeight: .word 6
	playerSpriteColorData: .space 144 # store 6*6*4 bytes of mem
.text

.globl playerSpriteInit, playerSpriteUpdate, playerSpriteDraw
.globl playerSpriteX, playerSpriteY, playerSpriteWidth, playerSpriteHeight, playerSpriteColorData

playerSpriteInit:
	jr $ra
playerSpriteUpdate:
	j playerSpriteDraw
playerSpriteDraw:	
	lw $t1, playerSpriteX
	lw $t2, playerSpriteY
	lw $t3, playerSpriteWidth
	lw $t4, playerSpriteHeight
	LOOPINIT1:
		lw $t7, playerSpriteHeight
		addi $t7, $t7, -1
	WHILE1:
		bltz $t7, LOOP1DONE
		LOOPINIT2:
			lw $v1, playerSpriteWidth
			addi $v1, $v1, -1
		WHILE2:			
			bltz $v1, LOOP2DONE
			la $t0, playerSpriteColorData
			lw $t1, playerSpriteX
			# find index in color data array
			li $t5, 0				# calculate index
			add $t5, $v1, $t5
			mult $t3, $t7
			mflo $t6
			add $t5, $t5, $t6			# t5 contains index	
			li $t6, 4
			mult $t5, $t6
			mflo $t5
			add $t0, $t0, $t5			# find address using index
			lw $a2, 0($t0)
			
			# calculate x,y
			move $s0, $t1
			add $a0, $s0, $v1
			move $s1, $t2
			add $a1, $s1, $t7
			
			# draw pixel
			jal drawPixel
			
			addi $v1, $v1, -1
			j WHILE2
		LOOP2DONE:
		addi $t7, $t7, -1
		j WHILE1
	LOOP1DONE:
	jr $s7
	
