.data
	time: .word 0
	cameraOffset: .word 0
	one: .word 1
	nextMilestone: .word 300
	wowX: .word 0
	wowY: .word 0
	wowTimer: .word 0
	wowColourData: .space 340 # 5*17*4 # if 0
	omgColourData: .space 340 # if 1
	yayColourData: .space 340 # if 2
	wowTextChoice: .word 0
	pausedColourData: .space 1800 # 30*15*4
	isPaused: .word 0 # 0 if not paused, 1 if paused

.text
.globl time, cameraOffset, one, nextMilestone, wowColourData, omgColourData, yayColourData, wowTextChoice, pausedColourData
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
	
	li $v0, 33
	li $a0, 50 # pitch
	li $a1, 1000 # milliseconds duration
	li $a2, 80 # instrument
	li $a3, 100 # volume
	syscall
	
	li $v0, 31
	li $a0, 70 # pitch
	li $a1, 500 # milliseconds duration
	li $a2, 80 # instrument
	li $a3, 100 # volume
	syscall
	
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
	
	# store time
	li $v0, 30
	syscall
	sw $a0, time
	
	# reset camera offset
	sw $zero, cameraOffset
	
	# reset system vars
	li $v0, 100
	sw $v0, gravity
	li $v0, 300
	sw $v0, nextMilestone
	
	# reset text display vars
	sw $zero, wowTimer
	
	# set paused to 0
	sw $zero, isPaused
	
	jal playerSpriteInit # init player sprite
	j playScreenRun # run screen
playScreenEvents:
	# reset playerSprite physics vars
	sw $zero, playerSpriteVelX
	
	# get keystroke event
	lw $t0, 0xffff0000
	beq $t0, 1, eventFound
	j playScreenEventsDone
	eventFound:
		lw $t1, 0xffff0004
		# check for j
		beq $t1, 0x6a, jFound
		j jDone
		jFound:
			li $t0, -5 # player vel mag is 5 *********
			sw $t0, playerSpriteVelX # set player vel to -5
			j playScreenEventsDone
		jDone:
		# check for k
		beq $t1, 0x6b, kFound
		j kDone
		kFound:
			li $t0, 5 # player vel mag is 5 *********
			sw $t0, playerSpriteVelX # set player vel to 5
			j playScreenEventsDone
		kDone:
		# check for s
		beq $t1, 0x73, sFound
		j sDone
		sFound:
			j playScreenInit # reset screen
		sDone:
		# check for p
		beq $t1, 0x70, pFound
		j pDone
		pFound:
			# set isPaused to 0 if 1, 1 if 0
			lw $t0, isPaused
			mul $t0, $t0, -1
			addi $t0, $t0, 1
			sw $t0, isPaused
			la $t1, clearPaused # srote addr in t1
			jalr $s7, $t1 # store current addr in s7, jump to addr in t1
			j playScreenEventsDone
		pDone:

playScreenUpdate:
	lw $t1, isPaused
	beq $t1, 1, playScreenUpdateDone
	
	# check milestone
	lw $t1, nextMilestone
	lw $t2, cameraOffset
	sub $t2, $t1, $t2 # t1 = nextMilestone - cameraOffset
	bgtz $t2, updateMilestoneDone
	updateMilestone:
		li $v0, 4
		la $a0, debugMilestone
		syscall
		# update milestone
		sll $t1, $t1, 1
		li $v0, 42
		li $a1, 200
		syscall # get choice of text
		addi $a0, $a0, -100
		add $t1, $t1, $a0
		sw $t1, nextMilestone
		
		# increase gravity by 200
		lw $t1, gravity
		addi $t1, $t1, 100
		sw $t1, gravity
		
		# increase jump force by 900
		lw $t1, playerSpriteJump
		addi $t1, $t1, -450
		sw $t1, playerSpriteJump
		
		# set up wow
		li $t1, 60
		sw $t1, wowTimer
		jal getWowCoords
		sw $a0, wowX
		sw $a1, wowY
		
		li $v0, 42
		li $a1, 3
		syscall # get choice of text
		sw $a0, wowTextChoice
		li $v0, 1
		syscall
		
		li $v0, 31
		li $a0, 100 # pitch
		li $a1, 500 # milliseconds duration
		li $a2, 0 # instrument
		li $a3, 100 # volume
		syscall
	updateMilestoneDone:
	
	la $t1, basicPlatformClear
	jalr $s7, $t1
	la $t1, playerSpriteClear
	jalr $s7, $t1
	la $t1, playerSpriteUpdate
	jalr $s7, $t1
	la $t1, basicPlatformUpdate
	jalr $s7, $t1
	j playScreenUpdateDone

playScreenDraw:
	# draw on-screen notifs
	lw $t1, wowTimer
	blez $t1, wowDrawingClear
	wowDrawing:
		addi $t1, $t1, -1 # decrement timer
		sw $t1, wowTimer
		lw $a0, wowX # load coords
		lw $a1, wowY
		jal drawWow # draw
		j wowDone
	wowDrawingClear:
		lw $a0, wowX
		lw $a1, wowY
		jal clearWow
	wowDone:
	
	# draw score
	scoreClear:
	scoreDraw:
		la $t1, drawScore
		jalr $s7, $t1
	
	# draw player sprite		
	la $t1, playerSpriteDraw # srote addr in t1
	jalr $s7, $t1 # store current addr in s7, jump to addr in t1
	
	# draw platforms
	la $t1, basicPlatformDraw
	jalr $s7, $t1
	
	# draw paused if paused
	lw $t1, isPaused
	beqz $t1, drawingPauseTextDone
	drawingPauseText:
		la $t1, drawPaused # srote addr in t1
		jalr $s7, $t1 # store current addr in s7, jump to addr in t1
	drawingPauseTextDone:
	
	j playScreenDrawDone
