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
	
	# the following are for playerSprite vars
	playerSpriteX: .word 30
	playerSpriteY: .word 34
	playerSpriteWidth: .word 6
	playerSpriteHeight: .word 6
	playerSpriteColorData: .space 144 # store 6*6*4 bytes of mem
	
.text

	.globl displayAddress, gameMode, newline
	.globl unitWidth, unitHeight, rowWidth, rowHeight
	.globl leftKey, rightKey
	.globl debugDone
	.globl playerSpriteX, playerSpriteY, playerSpriteWidth, playerSpriteHeight, playerSpriteColorData
	
