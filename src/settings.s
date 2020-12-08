.data
	# the following are display settings
	displayAddress:	.word	0x10008000
	gameMode: .word 0 # 0 == startGame, 1 == playGame, 2 == endGame
	newline: .asciiz "\n"
	unitWidth: .word 8
	unitHeight: .word 8
	rowWidth: .word 64
	rowHeight: .word 64
	
	# the following are game settings
	bgColor: .word 0xE4F9F5			#1390C1
	gravity: .word 100
	
	# the following are 'boolean' values to keep track of what keys have been pressed
	leftKey: .word 0
	rightKey: .word 0
	
	# the following are debug messages
	debugDone: .asciiz "DONE\n"
	debugGameOver: .asciiz "Game Over\n"
	debugCollide: .asciiz "collided\n"
	debugHit: .asciiz "hit\n"
	debugMilestone: .asciiz "Milestone Reached!\n"
	
.text

	.globl displayAddress, gameMode, newline, unitWidth, unitHeight, rowWidth, rowHeight
	.globl bgColor, gravity
	.globl leftKey, rightKey
	.globl debugDone, debugGameOver, debugHit, debugMilestone#, debugCollide
	
