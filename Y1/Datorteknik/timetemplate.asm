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
mytime:	.word 0x5957
timstr:	.asciiz "59:57" 
	.text
main:
	# print timstr
	la	$a0,timstr
	li	$v0,4
	syscall
	nop
	# wait a little
	li	$a0,2
	jal	delay
	nop
	# call tick
	la	$a0,mytime
	jal	tick
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
 	andi $a0,$a0,0x0F
	addi $t0,$0,10
	addi $v0,$a0,0x30
	jr $ra
	nop
delay:
	jr $ra
	nop
		
time2string:
	PUSH($s0)
	PUSH($s1)
	PUSH($ra)
	add     $s0,$0,$a0      # spara adressen till "timstr" fr�n $a0 till $s0 
    add     $s1,$0,$a1      # s0 inneh�ller information om den befintliga tiden
	
	andi    $t0,$s1,0xf000  #extrahera MSB --> [0x00005957 AND 0z0000f000 = 0x00005000]
	srl     $a0,$t0,12      #Shifta de extraherade bitarna till LSB posistion --> [0x00005000 >> 12 = 0x00000005]
	jal     hexasc      	# anropa hexasc
	nop
	sb      $v0, 0($s0)     # spara returv�rdet fr�n hexasc i timstr som a0 pekar p�

	andi    $t1,$s1,0x0f00  # extrahera bitar --> [0x00005957 AND 0x00000f00 = 0x00000900]
	srl     $a0,$t1,8       # Shifta de extraherade bitarna till LSB posistion --> [0x00000900 >> 8 = 0x00000009]
	jal     hexasc      	## n�dv�ndigt eftersom hexasc endast utf�r ber�kningar p� de 4 sista bitarna
	nop
	sb      $v0,1($s0)      # Spara returv�rdet fr�n hexasc i den adress som a0 pekar till 

	li      $t3,0x3A        #t3 = kolon i ASCII tabel
	sb      $t3,2($s0)


	andi    $t2,$s1,0x00f0  # extrahera bitar --> [0x00005957 AND 0z000000f0 = 0x00000050]
	srl     $a0,$t2,4		# Shifta de extraherade bitarna till LSB posistion --> [0x00000050 >> 4 = 0x00000005]
	jal     hexasc				## n�dv�ndigt eftersom hexasc endast utf�r ber�kningar p� de 4 sista bitarna
	nop
	sb      $v0,3($s0)		# Spara returv�rdet fr�n hexasc i den adress som a0 pekar till 


	move    $a0,$s1         # kopiera �ver den befintliga tiden fr�n $s1 till $a0
	jal     hexasc				## INTE n�dv�ndigt att extrahera LSB eftersom hexasc 
        							## endast utf�r ber�kningar p� de 4 sista bitarna
	nop
	sb      $v0, 4($s0)

	li      $t4,0x00        #l�gg till null i slutet av str�ngen
	sb      $t4,5($s0)
		
	POP     ($ra)
	POP     ($s1)
	POP     ($s0)

	jr       $ra
	nop