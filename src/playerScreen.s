.data
	time: .word 0

.text
.globl playScreenRun, playScreenInit, playScreenEvents, playScreenUpdate, playScreenDraw

playScreenRun:
	j playScreenEvents
	playScreenEventsDone:
		j playScreenUpdate
	playScreenUpdateDone:
		j playScreenDraw
	playScreenDrawDone:
		# sleep for 30ms
		li $v0, 32
		li $a0, 30
		syscall
		
		j playScreenRun

playScreenInit:
	li $v0, 4
	la $a0, debugDone
	syscall
	
	# fill background
	addi $t0, $zero, 4095 # store 64*64-1
	lw $t2, displayAddress # get display addr
	lw $t3, bgColor # get bgColor
	loop1: # loop through all bitmap vals
		li $t1, 4 # store 4
		mul $t1, $t1, $t0 # mult 4*(t0)
		add $t1, $t1, $t2 # do displayAddr+4*(t0)
		sw $t3, 0($t1) # store bgColor in displayAddr+4*(t0)
		addi $t0, $t0, -1 # (t0)--
		bltz $t0, loop1done
		j loop1
	loop1done:
	
	# add initial platforms
	la $t0, basicPlatforms
	li $t1, 30
	li $t2, 45
	sw $t1, 0($t0)
	sw $t2, 4($t0) # add a platform at (30, 45)
	li $t1, 60
	li $t2, 4
	sw $t2, 8($t0)
	sw $t1, 12($t0) # add a platform at (4, 60)
	li $t1, 20
	li $t2, 4
	sw $t2, 16($t0)
	sw $t1, 20($t0) # add a platform at (4, 20)
	li $t1, 10
	li $t2, 55
	sw $t2, 24($t0)
	sw $t1, 28($t0) # add a platform at (55, 10)
	
	
	# store time
	li $v0, 30
	syscall
	sw $a0, time
	
	jal playerSpriteInit # init player sprite
	j playScreenRun # run screen
playScreenEvents:
	j playScreenEventsDone
playScreenUpdate:
	j playScreenUpdateDone
playScreenDraw:
	# draw player sprite		
	la $t1, playerSpriteDraw # srote addr in t1
	jalr $s7, $t1 # store current addr in s7, jump to addr in t1
	
	la $t1, basicPlatformDraw
	jalr $s7, $t1
	
	la $t1, generatePlatforms
	jalr $s7, $t1
	
	j playScreenDrawDone
