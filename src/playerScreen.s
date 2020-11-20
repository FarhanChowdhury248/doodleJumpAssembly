.data


.text
.globl playScreenRun, playScreenInit, playScreenEvents, playScreenUpdate, playScreenDraw

playScreenRun:
	j playScreenEvents
	playScreenEventsDone:
		j playScreenUpdate
	playScreenUpdateDone:
		j playScreenDraw
	playScreenDrawDone:
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
	
	jal playerSpriteInit
	j playScreenRun
playScreenEvents:
	j playScreenEventsDone
playScreenUpdate:
	j playScreenUpdateDone
playScreenDraw:
	# draw player sprite		
	la $t1, playerSpriteDraw # srote addr in t1
	jalr $s7, $t1 # store current addr in s7, jump to addr in t1
	j playScreenDrawDone
