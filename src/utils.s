.data

.text

.globl drawPixel, getNextPoint, generatePlatforms, exit

j generatePlatforms

drawPixel:
	# assume $a0-2 stores x, y, and color respectively
	# uses t0-1
	# returns None
	
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
	la $t0, basicPlatforms # get addr of start of arr
	addi $t1, $t0, 160 # mark the end of the arr   ************
	move $a0, $t0 # store valid addr in t0
	jal getNextPoint # v0 stores valid point, v1 == 0 if point unavailable
	beqz, $v1, loop6done # terminate if no valid point available
	move $t0, $v0 # move it to t0
	lw $t2, rowHeight # get height of display
	li $t3, -1
	mul $t2, $t2, $t3 # start at -rowHeight
	loop6:
		beqz $t2, loop6done
		lw $t3, rowWidth # start x at rowWidth
		loop7:
			beqz $t3, loop7done # terminate if rowWidth == 0
			addi $t3, $t3, -1 # decrement rowWidth to get true addr
			
			# get random number x s.t. 0 <= x < 1024		
			li $v0, 42
			li $a0, 0
			li $a1, 1024
			syscall # random int in $a0
			bnez $a0, noAdd # do not add 1023/1024 times, add 1/1024 times
			
			# if adding...
			sw $t3, 0($t0) # store x
			sw $t2, 1($t0) # store y
			move $a0, $t0
			jal getNextPoint # get next valid point
			beqz, $v1, loop6done # terminate if no valid point available
			move $t0, $a0 # store next valid point
			
			noAdd:
			j loop7
			
		loop7done:
		addi $t2, $t2, -1
		beqz $t2, loop6done
		j loop6
	loop6done:
	jr $s7

exit:
	li $v0, 10 # terminate the program gracefully
	syscall
