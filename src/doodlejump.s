.data
	
.text
main:
	lw $t0, displayAddress	# $t0 stores the base address for display
	li $t1, 0xff0000	# $t1 stores the red colour code
	li $t2, 0x00ff00	# $t2 stores the green colour code
	li $t3, 0x0000ff	# $t3 stores the blue colour code
	
	sw $t1, 0($t0)	 # paint the first (top-left) unit red. 
	sw $t2, 4($t0)	 # paint the second unit on the first row green. Why $t0+4?
	sw $t3, 256($t0) # paint the first unit on the second row blue. Why +128?
	jal loadData
	j playScreenInit
	
	j exit
	
