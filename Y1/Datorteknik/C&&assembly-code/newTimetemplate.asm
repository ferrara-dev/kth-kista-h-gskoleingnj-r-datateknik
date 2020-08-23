  # timetemplate.asm
  # Written 2015 by F Lundevall
  # Copyright abandonded - this file is in the public domain.

.macro	PUSH (%reg)
	addi	$sp,$sp,-4
	sw	%reg,0($sp)
.end_macro

.macro	POP (%reg)
	lw	%reg,0($sp)
	addi	$sp,$sp,4
.end_macro

	.data
	.align 2
mytime:	.word 0x0018
timstr:	.ascii "timer assignment\0" 
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	addi	$a0,$s0,1000  # set argument to 1000 ms
	jal	delay
	nop
	# call tick
	la	$a0,mytime # ladda upp adressen till den beffinliga tiden   ex. [59:57]
	jal	tick	   # funktionen tick uppdaterar den befinliga tiden ex. [59:57 --> 59:58]
	nop
	# call your function time2string
	la	$a0,timstr
	la	$t0,mytime
	lw	$a1,0($t0)
	jal	time2string
	nop
	
	# print a newline
	li	$a0,10
	li	$v0,11
	syscall
	nop
	# go back and do it all again
	j	main
	nop
# tick: update time pointed to by $a0
tick:	lw	$t0,0($a0)	# get time
	addiu	$t0,$t0,1	# increase
	andi	$t1,$t0,0xf	# check lowest digit
	sltiu	$t2,$t1,0xa	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x6	# adjust lowest digit
	andi	$t1,$t0,0xf0	# check next digit
	sltiu	$t2,$t1,0x60	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa0	# adjust digit
	andi	$t1,$t0,0xf00	# check minute digit
	sltiu	$t2,$t1,0xa00	# if digit < a, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0x600	# adjust digit
	andi	$t1,$t0,0xf000	# check last digit
	sltiu	$t2,$t1,0x6000	# if digit < 6, okay
	bnez	$t2,tiend
	nop
	addiu	$t0,$t0,0xa000	# adjust last digit
tiend:	sw	$t0,0($a0)	# save updated result
	jr	$ra		# return
	nop

  # you can write your code for subroutine "hexasc" below this line
  #
hexasc:
        andi    $a0,$a0,0xf     #only 4 least significant bits ignore(clear) other bits
        addi    $v0,$zero,0x30  #$v0 = 0x30 ('0' ASCII character)
        addi    $t0,$zero,0x9   #t0 = 0x9

        ble     $a0,$t0,L1      #branch to L1 if a0 <= t0
        nop
        addi    $v0,$v0,0x7     #v0 = v0 +0x7 (thier is 7 other characters from 0x39 to 0x41) thats why
        #0x7 is added to the v0 to ignore the gap and jump directly to 'A' in ASCII table

L1:
        add     $v0,$a0,$v0     #v0 = V0 +a0
        jr      $ra
        nop

delay:
 		li    $t1,10000  #(intitaly was t1=4711) ### 20000 iterationer genom den inre loopen <-> 1 ms (13 sekunder i programmet klockades till 13,1)
        PUSH    ($s0)
        PUSH    ($ra)
        addi    $s0, $0, 0   #i = 0
        move    $t0,$a0     #move the argument to t0
while:
        blez      $t0,done    #branch to done if ms > 0
        nop
        addi    $t0,$t0,-1      #decrement ms by 1
for:
        beq     $s0,$t1,done2
        nop
        addi    $s0,$s0,1
        j       for
        nop
done2:

        j       while
        nop
done:
        POP     ($ra)
        POP     ($s0)
        jr      $ra
        nop

		

time2string:
        PUSH    ($s0) # Adress pekare
        PUSH    ($s1) # Den befintliga tiden
        PUSH    ($s2) # Kontroll variabel f�r att bryta loopen
        PUSH	($s3) # variabel som anv�nds f�r att f� ut �nskad byte fr�n $s1 
        PUSH	($s4) # Kontroll variabel f�r att l�gga till kolon vid r�tt position i str�ngen
        PUSH	($s5) # Kontroll om sista siffra = 2
        PUSH    ($ra)
        
        add     $s0,$0,$a0      # spara adressen till "timstr" fr�n $a0 till $s0 
        add     $s1,$0,$a1      # information om den befintliga tiden kopieras fr�n $a1 till $s1
		li $s3,0xf000 			
		li $t7, 12
		addi $s4, $s0,2  # Om s0 pekar p� index 2 i str�ngen --> appendColon
		addi $s2, $s0,5  # Om s0 pekar p� index 5 i str�ngen --> endloop
		addi $t9, $s0,5
		timeLoop:
		beq $s0, $s2,endloop  # Om s0 pekar p� index 5 i str�ngen --> endloop
		nop
		
		and $a0,$s1,$s3			  # ta fram relevant nibble fr�n present time
		nop
		srav $a0,$a0,$t7          # shifta relevant nibble till LSB
		
		jal hexasc
		nop
		
		sb $v0, 0($s0)
		beq  $v0,2,check
		srl $s3,$s3,4			   # 
		addi $t7,$t7,-4			   # 

		addi $s0,$s0 1             # Flytta fram adress pekaren till n�sta byte
		beq $s4,$s0, appendColon   # Om s0 pekar p� index 2 i str�ngen --> appendColon
		nop
		
		beq  $s0,$t9,check
		nop
		
		j timeLoop
		nop
		
		check:
		beq $a0,2,appendTWO
		nop
		
		
		j timeLoop
		nop
		
		appendColon:
		li      $t3,0x3A        #t3 = kolon i ASCII tabel
		sb      $t3,0($s0)
		addi $s0,$s0 1
		j timeLoop
		nop
		
	
		appendTWO:
		li      $t3,0x54        #t3 = kolon i ASCII tabel
		sb      $t3,-1($s0)
		li      $t3,0x57      
		sb      $t3,0($s0)
		li		$t3, 0x4f
		addi $s0,$s0 1
		sb 		$t3,0($s0)
		addi $s0,$s0 1
		endloop:
        li      $t4,0x00        #l�gg till null i slutet av str�ngen
   		sb      $t4, 0($s0)
        POP     ($ra)
        POP		($s5)
        POP 	($s4)
        POP 	($s3)
  		POP     ($s2)
        POP     ($s1)
        POP     ($s0)

        jr       $ra
        nop
