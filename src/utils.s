.data

.text

.globl drawPixel, getNextPoint, generatePlatforms, exit

j generatePlatforms

drawPixel:
	# assume $a0-2 stores x, y, and color respectively
	# uses t0-1
	# returns None
	
	# add cameraOffset
	lw $t0, cameraOffset
	add $a1, $a1, $t0
	
	# horizontal wrapping
	lw $t0, rowWidth # get width
	bge $a0, $t0, wrapG
	j wrapGDone
	wrapG:
		jr $ra
	wrapGDone:
	bltz $a0, wrapL
	j wrapLDone
	wrapL:
		jr $ra
	wrapLDone:
	
	# do coloring
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	li $t1, 4 # store 4
	mul $t1, $t1, $a0 # multiply x*4
	add $t0, $t0, $t1 # add x*4 +rowWidth*y*4 + start of arr
	sw $a2, 0($t0) # color
	jr $ra
	
getNextPoint:
	# assumes $a0 stores point addr to start from
	# uses a0, a1, v0
	# returns addr for point in v0, validAddr in v1
	la $a1, basicPlatforms # get start of arr
	addi $a1, $a1, 160 # store end of arr ************
	li $v1, 1 # mark that end hasn't been reached yet
	loop5:
		sub $v0, $a0, $a1 # v0 = curLoc - end of arr
		blez $v0, loop5Predone # end loop if hit end of arr
		lw $v0, 0($a0) # get x
		bnez $v0, loop5done # if x != 0, we are done
		lw $v0, 1($a0) # get y
		bnez $v0, loop5done # else if y != 0, we are done
		addi $a0, $a0, 2 # if x == 0 && y == 0, we are not done, iterate
		j loop5
	loop5Predone:
		li $v1, 0 # record if reached end of arr
	loop5done:
		move $v0, $a0 # return addr
	jr $ra
	
generatePlatforms:
	jr $s7

exit:
	li $v0, 10 # terminate the program gracefully
	syscall
