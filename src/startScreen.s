.data
	startScreenColourData: .space 16384 # 32*32*4

.text

.globl startScreenColourData
.globl startScreenRun, startScreenInit, startScreenEvents

startScreenRun:
	j startScreenEvents
	startScreenEventsDone:
		# sleep for 30ms
		li $v0, 32
		li $a0, 30
		syscall
		
		j startScreenRun
		
startScreenInit:
	la $t0, startScreenColourData
	lw $t1, displayAddress
	li $t2, 16380
	loop20:
		add $t3, $t0, $t2 # color addr
		add $t4, $t1, $t2 # store addr
		lw $v0, 0($t3) # get color
		sw $v0, 0($t4)
		addi $t2, $t2, -4
		bltz $t2, loop20done
		j loop20
	loop20done:
	j startScreenRun
startScreenEvents:
	# get keystroke event
	lw $t0, 0xffff0000
	beq $t0, 1, startEventFound
	j startScreenEventsDone
	startEventFound:
		lw $t1, 0xffff0004
		# check for s
		beq $t1, 0x73, gameStartFound
		j gameStartDone
		gameStartFound:
			j playScreenInit # reset to play screen
		gameStartDone:
	j startScreenEventsDone