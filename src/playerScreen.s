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
	jal playerSpriteInit
	j playScreenRun
playScreenEvents:
	j playScreenEventsDone
playScreenUpdate:
	j playScreenUpdateDone
playScreenDraw:
	la $t1, playerSpriteDraw # srote addr in t1
	jalr $s7, $t1 # store current addr in s7, jump to addr in t1
	j playScreenDrawDone
