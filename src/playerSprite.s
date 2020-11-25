.data
	# location vars
	playerSpriteX: .word 30
	playerSpriteY: .word 20000
	# property vars
	playerSpriteWidth: .word 6
	playerSpriteHeight: .word 6
	playerSpriteColorData: .space 144 # store 6*6*4 bytes of mem
	# physics vars
	playerSpriteVelX: .word 0
	playerSpriteVelY: .word 0
	playerSpriteAccX: .word 0
	playerSpriteAccY: .word 0
.text

.globl playerSpriteInit, playerSpriteUpdate, playerSpriteDraw, playerSpriteClear
.globl playerSpriteX, playerSpriteY
.globl playerSpriteWidth, playerSpriteHeight, playerSpriteColorData
.globl playerSpriteVelX, playerSpriteVelY, playerSpriteAccX, playerSpriteAccY

playerSpriteInit:
	li $v0, 30
	sw $v0, playerSpriteX
	li $v0, 20000
	sw $v0, playerSpriteY
	sw $zero, playerSpriteVelX
	sw $zero, playerSpriteVelY
	sw $zero, playerSpriteAccX
	sw $zero, playerSpriteAccY
	jr $ra
playerSpriteUpdate:
	# check collisions with platforms
	lw $t0, playerSpriteVelY
	bltz $t0, endOfCollisionCheck # don't collide if going upwward
	
	la $t0, basicPlatforms
	li $t1, 20 # store count *********
	loop8:
		# if (playerVel < 0 && 
		#     playerX + playerWidth > platformX && playerX < platformX + platformWidth &&
		#     playerY < platformY && playerY + playerHeight > platformY) 
		#	j endOfCollisionCheckPositive
		# if !(playerVel > 0 || 
		#      playerX + playerWidth < platformX || playerX > platformX + platformWidth ||
		#      playerY > platformY || playerY + playerHeight < platformY) 
		#	j endOfCollisionCheckPositive
		
		li $v0, 0 # store result
		
		# check vel
		lw $t2, playerSpriteVelY
		or $v0, $v0, $t2 # if playerVelY < 0, make v0 < 0
		
		# check horizontal
		lw $t2, 0($t0) # get platformX
		lw $t3, basicPlatformWidth # get platformWidth
		lw $t4, playerSpriteWidth # get playerWidth
		lw $t5, playerSpriteX # get playerX
		
		add $t6, $t5, $t4 # playerX + playerWidth
		sub $t6, $t6, $t2 # playerX + playerWidth - platformX
		addi $t6, $t6, -1
		or $v0, $v0, $t6 # if (playerX + playerWidth - platformX) < 0, make v0 < 0
		
		add $t6, $t2, $t3 # platformX + platformWidth
		sub $t6, $t6, $t5 # platformX + platformWidth - platformX
		addi $t6, $t6, -1
		or $v0, $v0, $t6 # if (platformX + platformWidth - platformX) < 0m make v0 < 0
		
		# check vertical
		lw $t2, 4($t0) # get platformY
		lw $t3, basicPlatformHeight # get platformHeight
		lw $t4, playerSpriteHeight # get playerHeight
		lw $t5, playerSpriteY # get playerY
		div $t5, $t5, 1000
		
		sub $t6, $t2, $t5 # platformY - playerY
		or $v0, $v0, $t6 # if platformY - player Y < 0 == platformY < playerY, make v0 < 0
		
		add $t6, $t5, $t4 # playerY + playerHeight
		sub $t6, $t6, $t2 # if playerY + playerHeight - platformY < 0 == playerY + playerHeight < platformY, make v0 < 0
		or $v0, $v0, $t6
		
		#add $t3, $t5, $t4, # playerY + playerHeight
		#sub $t3, $t3, $t2 # playerY + playerHeight - platformY
		
		#beqz $t3, yHits
		#j yHitsDone
		#yHits:
			bgtz $v0, endOfCollisionCheckPositive
		#yHitsDone:
		
		addi $t0, $t0, 8 # get next point
		addi $t1, $t1, -1 # decrement count
		beqz $t1, endOfCollisionCheck
		j loop8
	loop8done:
	endOfCollisionCheckPositive:
		li $v0, 4
		la $a0, debugHit
		syscall
		lw $t0, playerSpriteAccY
		addi $t0, $zero, -13000 # make player acc -5 *********
		sw $t0, playerSpriteAccY
	endOfCollisionCheck:
	
	# do physics for Y
	lw $t0, gravity # get gravity
	lw $t1, playerSpriteAccY
	add $t1, $t1, $t0 # t1 = ogAccY + gravity
	sw $t1, playerSpriteAccY
	lw $t0, playerSpriteVelY # get velocity
	add $t0, $t0, $t1 # t0 = ogVelY + accY
	lw $t1, playerSpriteY
	add $t1, $t1, $t0 # t1 = ogPosY + velY
	move $a1, $t1 # store posY in a1
	
	# scroll if posY < 0.4*height
	move $t0, $a1
	div $t0, $t0, 1000
	addi $t0, $t0, -15 # check how far player is above 0.2*rowHeight
	lw $t1, cameraOffset
	add $t0, $t0, $t1
	bgtz $t0, scrollDone # if lower than 0.4*rowHeight, skip scroll
	scroll:
		sub $t1, $t1, $t0
		sw $t1, cameraOffset
	scrollDone:
	
	# do physics for X
	lw $t0, playerSpriteVelX # get velocity
	lw $t1, playerSpriteX # get ogPosX
	add $t1, $t0, $t1 # t1 = ogPosX + velX
	move $a0, $t1 # store posX in a0
	
	# horizontal wrapping
	lw $t0, rowWidth # get width
	bge $a0, $t0, pwrapG
	j pwrapGDone
	pwrapG:
		sub $a0, $a0, $t0 # do x = x - width
	pwrapGDone:
	bltz $a0, pwrapL
	j pwrapLDone
	pwrapL:
		add $a0, $a0, $t0 # do x = x + width
	pwrapLDone:
	sw $a0, playerSpriteX # store posX
	sw $a1, playerSpriteY # store posY
	
	# check for hitting bottom
	lw $t0, playerSpriteY # get posY (top of sprite)
	div $t0, $t0, 1000
	lw $t1, playerSpriteHeight # get player height
	add $t0, $t0, $t1 # t0 now is bottom of sprite
	lw $t1, rowHeight # get screen height
	sub $t0, $t0, $t1 # playerY - screenHeight
	bgtz $t0, gameOver
	j gameOverDone
	gameOver:
		li $v0, 4
		la $a0, debugGameOver
		syscall
	gameOverDone:
	
	jr $s7

playerSpriteClear:
	lw $t1, playerSpriteX
	lw $t2, playerSpriteY
	lw $t3, playerSpriteWidth
	lw $t4, playerSpriteHeight
	
	# loop to clear previous drawing
	LOOPINIT3:
		lw $t7, playerSpriteHeight
		addi $t7, $t7, -1
		# store bgColor
		lw $a2, bgColor # a2 = bgColor
	WHILE3:
		bltz $t7, LOOP3DONE
		LOOPINIT4:
			lw $v1, playerSpriteWidth
			addi $v1, $v1, -1
		WHILE4:			
			bltz $v1, LOOP4DONE
			lw $t1, playerSpriteX
			
			# calculate x,y
			move $s0, $t1 # s0 = playerX
			add $a0, $s0, $v1 # a0 = playerX + xOffset
			move $s1, $t2 # s1 = playerY
			div $s1, $s1, 1000
			add $a1, $s1, $t7 # a1 = playerY + yOffset
			
			# draw pixel
			jal drawPixel
			
			addi $v1, $v1, -1
			j WHILE4
		LOOP4DONE:
		addi $t7, $t7, -1
		j WHILE3
	LOOP3DONE:
	jr $s7
	
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
			div $s1, $s1, 1000
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
	
