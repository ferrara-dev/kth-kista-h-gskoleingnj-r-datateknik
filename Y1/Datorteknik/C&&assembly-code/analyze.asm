  # analyze.asm
  # This file written 2015 by F Lundevall
  # Copyright abandoned - this file is in the public domain.
	
											# Assignment 1 #
	## change the program so that only every third character is printed. The program must still stop
    ## after "Z". The screenshot below shows the expected output:
    ### Question: Which lines of code had to be changed? Why?
    ### Answer : Line 19 had to be changed in order to print out every third charcter, in order for the program to after printing the letter Z, 
	### line 22 had to be changed, increasing the value loaded to t0 by 2
	.text
main:
	li	$s0,0x30
	
loop:
	move	$a0,$s0		# copy from s0 to a0
	
	li	$v0,11		# syscall with v0 = 11 will print out
	syscall			# one byte from a0 to the Run I/O window
	
	addi	$s0,$s0,3	# (1.1) H�jer konstanten till 3 --> s0 �kar med 3 f�r varje iteration
	
	li	$t0,0x5d        # (1.2) H�jer med 2 --> t0 �kar fr�n 91 till 93 s� att utskriften fortfarande slutar p� Z
	bne	$s0,$t0,loop
	nop			# delay slot filler (just in case)

stop:	j	stop		# loop forever here
	nop			# delay slot filler (just in case)

