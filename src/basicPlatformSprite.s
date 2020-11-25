.data
	# location vars
	basicPlatformWidth: .word 15
	basicPlatformHeight: .word 3
	basicPlatformColorData: .space 180 # store 15*3*4 bytes of mem
	basicPlatforms: .space 160 # store two words 20 times (up to 20 platforms of x,y coords)
	
.text

.globl basicPlatformWidth, basicPlatformHeight, basicPlatformColorData, basicPlatforms
.globl basicPlatformInit, basicPlatformUpdate, basicPlatformDraw, basicPlatformClear

basicPlatformInit:
	jr $ra
basicPlatformUpdate:
basicPlatformClear:
	la $s0, basicPlatforms # get pointer to arr
	la $s1, basicPlatformColorData # get color data
	lw $a2, bgColor
	
	li $s2, 20 # store count  **********
	move $v0, $s0
	loop11:
		li $t2, 2 # yOffset starts at 2
		addi $v1, $v0, 4 # v1 is addr to ogY
		lw $t4, 0($v0) # t4 stores xLoc
		lw $t5, 0($v1) # t5 stores yLoc
		beqz $t4, XIsZero # v0 is addr to ogX
		j loop9
		XIsZero:
			beqz $t5, loop9Done
		loop9:
			li $t3, 14 # xOffset starts at 14
			loop10:
			
				# calculate x = ogX + xOffset, y = ogY + yOffset
				add $a0, $t4, $t3 # store ogX + xOffset in a0
				add $a1, $t5, $t2 # store ogY + yOffset in a1
				
				# draw pixel
				jal drawPixel
				
				addi $t3, $t3, -1
				bltz $t3, loop10Done
				j loop10
			loop10Done:
			addi $t2, $t2, -1 # decrement yOffset
			bltz $t2, loop9Done # end loop if yOffset is 0
			j loop9
		loop9Done:
		addi $s2, $s2, -1 # decrement count
		addi $v0, $v0, 8 # increase pointer
		bgtz $s2, loop11 # if count > 0, repeat loop
	loop11Done:
		
	jr $s7
basicPlatformDraw:
	la $s0, basicPlatforms # get pointer to arr
	la $s1, basicPlatformColorData # get color data
	
	li $s2, 20 # store count  **********
	move $v0, $s0
	loop3:
		li $t2, 2 # yOffset starts at 2
		addi $v1, $v0, 4 # v1 is addr to ogY
		lw $t4, 0($v0) # t4 stores xLoc
		lw $t5, 0($v1) # t5 stores yLoc
		beqz $t4, XIsZero2 # v0 is addr to ogX
		j loop4
		XIsZero2:
			beqz $t5, loop4Done
		loop4:
			li $t3, 14 # xOffset starts at 14
			loop5:
			
				# calculate x = ogX + xOffset, y = ogY + yOffset
				add $a0, $t4, $t3 # store ogX + xOffset in a0
				add $a1, $t5, $t2 # store ogY + yOffset in a1
				
				# calculate index and get next color info
				add $t6, $zero, $t3 # store xOffset
				li $t7, 15
				mul $t7, $t7, $t2 # t7 = 15*yOffset
				add $t6, $t6, $t7 # store xOffset + 15*yOffset
				li $t7, 4
				mul $t6, $t6, $t7 # store (xOffset + 15*yOffset)*4
				add $t6, $t6, $s1 # store idx = arrStart + (xOffset + 15*yOffset)*4
				lw $a2, 0($t6) # get color data from idx and store in a2
				
				# draw pixel
				jal drawPixel
				
				addi $t3, $t3, -1
				bltz $t3, loop5Done
				j loop5
			loop5Done:
			addi $t2, $t2, -1 # decrement yOffset
			bltz $t2, loop4Done # end loop if yOffset is 0
			j loop4
		loop4Done:
		addi $s2, $s2, -1 # decrement count
		addi $v0, $v0, 8 # increase pointer
		bgtz $s2, loop3 # if count > 0, repeat loop
	loop3Done:
		
	jr $s7
	
