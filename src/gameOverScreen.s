.data
	gameOverScreenColourData: .space 16384 # 32*32*4

.text

.globl gameOverScreenColourData
.globl gameOverScreenRun, gameOverScreenInit, gameOverScreenEvents

gameOverScreenRun:
	j gameOverScreenEvents
	gameOverScreenEventsDone:
		# sleep for 30ms
		li $v0, 32
		li $a0, 30
		syscall
		
		j gameOverScreenRun

gameOverScreenInit:
	li $v0, 31
	li $a0, 30 # pitch
	li $a1, 1000 # milliseconds duration
	li $a2, 80 # instrument
	li $a3, 100 # volume
	syscall

	la $t0, gameOverScreenColourData
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
	j gameOverScreenRun

gameOverScreenEvents:
	# get keystroke event
	lw $t0, 0xffff0000
	beq $t0, 1, gameOverEventFound
	j gameOverScreenEventsDone
	gameOverEventFound:
		lw $t1, 0xffff0004
		# check for s
		beq $t1, 0x73, restartFound
		j restartDone
		restartFound:
			j playScreenInit # reset to play screen
		restartDone:
	j gameOverScreenEventsDone
