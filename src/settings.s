.data
	displayAddress:	.word	0x10008000
	gameMode: .word 0 # 0 == startGame, 1 == playGame, 2 == endGame
	newline: .asciiz "\n"
	
	# the following are game display vars
	unitWidth: .word 8
	unitHeight: .word 8
	rowWidth: .word 64
	rowHeight: .word 64
	
	# the following are 'boolean' values to keep track of what keys have been pressed
	leftKey: .word 0
	rightKey: .word 0
	
	# the following are debug messages
	debugDone: .asciiz "DONE\n"
	
.text

	.globl displayAddress, gameMode, newline
	.globl unitWidth, unitHeight, rowWidth, rowHeight
	.globl leftKey, rightKey
	.globl debugDone
	
