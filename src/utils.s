.data

.text

.globl drawPixel, exit

drawPixel:
	# assume $a0-2 stores x, y, and color respectively
	# uses t0-1
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
	
generatePlatforms:		

exit:
	li $v0, 10 # terminate the program gracefully
	syscall
