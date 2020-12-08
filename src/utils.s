.data

.text

.globl drawPixel, getNextPoint, generatePlatforms, exit, getWowCoords, drawWow, clearWow, drawScore, drawPaused, clearPaused

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
	
drawWow:
	# assumes a0 contains X, a1 contains Y
	# uses t0-4
	# calculate addr
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	li $t1, 4 # store 4
	mul $t1, $t1, $a0 # multiply x*4
	add $t0, $t0, $t1 # add x*4 +rowWidth*y*4 + start of arr
	
	# start drawing
	lw $t1, wowTextChoice
	li $t3, 0
	beq $t1, $t3, setTextToWow
	addi $t3, $t3, 1
	beq $t1, $t3, setTextToOmg
	addi $t3, $t3, 1
	beq $t1, $t3, setTextToYay
	setTextToWow:
		la $t2, wowColourData
		j setTextDone
	setTextToOmg:
		la $t2, omgColourData
		j setTextDone
	setTextToYay:
		la $t2, yayColourData
		j setTextDone
	setTextDone:
	
	li $t1, 0 # store colourDataOffset
	li $t3, 0 # store yOffset
	wowDrawY:
		li $t4, 0 # store xOffset
		wowDrawX:
			add $t5, $t2, $t1 # calc colourData + colourDataOffset
			lw $t5, 0($t5) # get colour
			lw $t6, rowWidth
			mul $t6, $t6, $t3 # rowWidth*yOffset
			add $t6, $t6, $t4 # rowWidth*yOffset + xOffset
			mul $t6, $t6, 4 # (rowWidth*yOffset + xOffset)*4
			add $t6, $t6, $t0 # topLeft + (rowWidth*yOffset + xOffset)*4
			sw $t5, 0($t6) # store color
			
			addi $t1, $t1, 4 # increment colourDataOffset by 4
			addi $t4, $t4, 1 # increment xOffset
			bge $t4, 17, wowDrawXDone # terminate loop if xOffset >= 17
			j wowDrawX
		wowDrawXDone:
		addi $t3, $t3, 1 # increment yOffset
		bge $t3, 5, wowDrawYDone # terminate loop if yOffset >= 5
		j wowDrawY
	wowDrawYDone:
	jr $ra
	
clearWow:
	# assumes a0 contains X, a1 contains Y
	# uses t0-4
	# calculate addr
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	li $t1, 4 # store 4
	mul $t1, $t1, $a0 # multiply x*4
	add $t0, $t0, $t1 # add x*4 +rowWidth*y*4 + start of arr
	
	# start drawing
	li $t3, 0 # store yOffset
	lw $t5, bgColor
	wowDrawY2:
		li $t4, 0 # store xOffset
		wowDrawX2:
			lw $t6, rowWidth
			mul $t6, $t6, $t3 # rowWidth*yOffset
			add $t6, $t6, $t4 # rowWidth*yOffset + xOffset
			mul $t6, $t6, 4 # (rowWidth*yOffset + xOffset)*4
			add $t6, $t6, $t0 # topLeft + (rowWidth*yOffset + xOffset)*4
			sw $t5, 0($t6) # store color
			addi $t4, $t4, 1 # increment xOffset
			bge $t4, 17, wowDrawXDone2 # terminate loop if xOffset >= 17
			j wowDrawX2
		wowDrawXDone2:
		addi $t3, $t3, 1 # increment yOffset
		bge $t3, 5, wowDrawYDone2 # terminate loop if yOffset >= 5
		j wowDrawY2
	wowDrawYDone2:
	jr $ra

getWowCoords:
	# get random x,y
	li $v0, 42
	li $a1, 32
	syscall # get random X in a0
	addi $t1, $a0, 15 # center random X and store in t1
	li $v0, 42
	li $a1, 32
	syscall # get random Y in a0
	addi $a1, $a0, 15 # center random Y and store in a1
	move $a0, $t1 # store random X in a0
	jr $ra
	
drawScore:	
	lw $a0, rowWidth # store topLeftX
	addi $a0, $a0, -5
	li $a1, 2 # store topLeftY
	
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	addi $t0, $t0, 4
	
	lw $t1, cameraOffset # score
	scoreDrawStart:
		li $t2, 10
		div $t1, $t2
		mfhi $t2 # store digit = score % 10 in t2
		mflo $t1 # store newScore = score // 10 in t1
		
		# calculate topLeft coord
		mul $t3, $a0, 4
		add $a1, $t0, $t3 # add x*4 +rowWidth*y*4 + start of arr, store in a1
		
		# draw digit
		move $t3, $zero
		beq $t2, $t3, draw0
		addi $t3, $t3, 1
		beq $t2, $t3, draw1
		addi $t3, $t3, 1
		beq $t2, $t3, draw2
		addi $t3, $t3, 1
		beq $t2, $t3, draw3
		addi $t3, $t3, 1
		beq $t2, $t3, draw4
		addi $t3, $t3, 1
		beq $t2, $t3, draw5
		addi $t3, $t3, 1
		beq $t2, $t3, draw6
		addi $t3, $t3, 1
		beq $t2, $t3, draw7
		addi $t3, $t3, 1
		beq $t2, $t3, draw8
		addi $t3, $t3, 1
		beq $t2, $t3, draw9
		drawDigitDone:
		
		addi $a0, $a0, -4 # increment x by 5
		blez $t1, scoreDrawEnd
		j scoreDrawStart
	scoreDrawEnd:
	jr $s7

draw0:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0xe4f9f5
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0x40514e
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw1:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0xe4f9f5
	sw $t4, 8($a1)
	li $t4, 0xe4f9f5
	sw $t4, 256($a1)
	li $t4, 0x40514e
	sw $t4, 260($a1)
	li $t4, 0xe4f9f5
	sw $t4, 264($a1)
	li $t4, 0xe4f9f5
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0xe4f9f5
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0x40514e
	sw $t4, 772($a1)
	li $t4, 0xe4f9f5
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw2:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0xe4f9f5
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0x40514e
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0xe4f9f5
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw3:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0xe4f9f5
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw4:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0xe4f9f5
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0xe4f9f5
	sw $t4, 1024($a1)
	li $t4, 0xe4f9f5
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw5:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0xe4f9f5
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw6:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0xe4f9f5
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0x40514e
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw7:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0xe4f9f5
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0xe4f9f5
	sw $t4, 512($a1)
	li $t4, 0xe4f9f5
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0xe4f9f5
	sw $t4, 1024($a1)
	li $t4, 0xe4f9f5
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw8:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0x40514e
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

draw9:
	li $t4, 0x40514e
	sw $t4, 0($a1)
	li $t4, 0x40514e
	sw $t4, 4($a1)
	li $t4, 0x40514e
	sw $t4, 8($a1)
	li $t4, 0x40514e
	sw $t4, 256($a1)
	li $t4, 0xe4f9f5
	sw $t4, 260($a1)
	li $t4, 0x40514e
	sw $t4, 264($a1)
	li $t4, 0x40514e
	sw $t4, 512($a1)
	li $t4, 0x40514e
	sw $t4, 516($a1)
	li $t4, 0x40514e
	sw $t4, 520($a1)
	li $t4, 0xe4f9f5
	sw $t4, 768($a1)
	li $t4, 0xe4f9f5
	sw $t4, 772($a1)
	li $t4, 0x40514e
	sw $t4, 776($a1)
	li $t4, 0x40514e
	sw $t4, 1024($a1)
	li $t4, 0x40514e
	sw $t4, 1028($a1)
	li $t4, 0x40514e
	sw $t4, 1032($a1)
	j drawDigitDone

drawPaused:
	li $a0, 17
	li $a1, 10
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	li $t1, 4 # store 4
	mul $t1, $t1, $a0 # multiply x*4
	add $t0, $t0, $t1 # add x*4 +rowWidth*y*4 + start of arr
	
	la $t1, pausedColourData
	li $a1, 15
	loop31:
		li $a0, 30
		loop32:
			lw $t2, 0($t1)
			sw $t2, 0($t0)			
			
			addi $t1, $t1, 4
			addi $t0, $t0, 4
			addi $a0, $a0, -1
			beqz $a0, loop32Done
			j loop32
		loop32Done:
		addi $t0, $t0, 136 # increment displayAddr by 4*64 - 4
		addi $a1, $a1, -1
		beqz $a1, loop31Done
		j loop31
	loop31Done:
	
	jr $s7
	
clearPaused:
	li $a0, 17
	li $a1, 10
	lw $t1, rowWidth # get rowWidth
	mul $t1, $t1, $a1 # multiply rowWidth*y
	li $t0, 4 # store 4
	mul $t1, $t1, $t0 # multiply rowWidth*y*4
	lw $t0, displayAddress # get display addr
	add $t0, $t0, $t1 # add rowWidth*y*4 + start of arr
	li $t1, 4 # store 4
	mul $t1, $t1, $a0 # multiply x*4
	add $t0, $t0, $t1 # add x*4 +rowWidth*y*4 + start of arr
	
	li $a1, 15
	loop33:
		li $a0, 30
		loop34:
			lw $t2, bgColor
			sw $t2, 0($t0)			
			
			addi $t0, $t0, 4
			addi $a0, $a0, -1
			beqz $a0, loop34Done
			j loop34
		loop34Done:
		addi $t0, $t0, 136 # increment displayAddr by 4*64 - 4
		addi $a1, $a1, -1
		beqz $a1, loop33Done
		j loop33
	loop33Done:
	
	jr $s7

exit:
	li $v0, 10 # terminate the program gracefully
	syscall
