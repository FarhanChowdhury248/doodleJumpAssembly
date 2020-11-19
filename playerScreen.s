.data

.globl playScreenRun, playScreenInit, playScreenEvents, playScreenUpdate, playScreenDraw

playScreenRun:
	jal playScreenInit
	jal playScreenEvents
	jal playScreenUpdate
	j exit
playScreenInit:
	li $v0, 4
	la $a0, debugDone
	syscall
	jr $ra
playScreenEvents:
	li $v0, 4
	la $a0, debugDone
	syscall
	jr $ra
playScreenUpdate:
	li $v0, 4
	la $a0, debugDone
	syscall
	jr $ra
playScreenDraw:
	li $v0, 4
	la $a0, debugDone
	syscall	
	jr $ra