  .data # Data declaration section
    #globals
    emptyArrayC: .space 8 #1 word = 4 bytes, 2 words = 8 bytes -> 64 bits
    emptyArrayD: .space 8 #1 word = 4 bytes, 2 words = 8 bytes -> 64 bits   
    wordSet1: .word 1, 2
    wordSet2: .word 3, 4
.text # Assembly language instructions

# a0 = A[]
# a1 = B[]
# a2 = C[]
# a3 = D[]
# t0 = temp
# t1 = current word in A[1]
# t2 = current word in A[2]
# t3 = current word in B[1]
# t4 = current word in B[2]
# t6 = exponent difference
# s0 = (+) or (-) final answer
# s1 = word A[1]
# s2 = word A[2]
# s3 = word B[1]
# s4 = word B[2]

main:

  la		$a0, wordSet1		        # A = first set of words
  la		$a1, wordSet2		        # B = second set of words
  la		$a2, emptyArrayC	      # declairing "C"
  la		$a3, emptyArrayD	      # declairing "D" 
  lw		$s1, 0($a0)		          # $s1 = A[1]
  lw		$s2, 1($a0)		          # $s2 = A[2]
  lw		$s3, 0($a1)		          # $s3 = B[1]
  lw		$s4, 1($a1)		          # $s4 = B[2]
  
#___________________________________________________________________________
# finding smaller exponent 
# and preparing for which value is greater
#___________________________________________________________________________ 

findExponent:

# make the word represent the exponent
    sll   $t1, $s1, 1               # eleminate sign bit from A[1]
    srl   $t1, $t1, 21              # 00..00xx..xx
    sll   $t3, $s3, 1               # eleminate sign bit from B[1]
    srl   $t3, $t3, 21              # 00..00xx..xx

# checking which exponent is larger
    bge		$t1, $t3, aLargerThanB	  # if A^ >= B^ then target

# A^ < B^
    sub   $t6, $t3, $t1             # ^diff = B^ - A^

    addi	$t1, $s1, 0			          # t1 = A[1]
    addi	$t2, $s2, 0			          # t2 = A[2]
    addi	$t3, $s3, 0			          # t3 = B[1]
    addi	$t4, $s4, 0			          # t4 = B[2]
#removing |S|E10...E0|
    sll   $t1, $t1, 12              # xx..xx00..00
    srl   $t1, $t1, 12              # 00..00xx..xx
    sll   $t3, $t3, 12              # xx..xx00..00
    srl   $t3, $t3, 12              # 00..00xx..xx
# shifting to make exponents equal
    li		$t0, 32
    sub		$t0, $t0, $t6		          # shift = 32 - exponent difference
    sllv  $t0, $t1, $t0             # t0 = shifted for word 2
    sllv  $t1, $t1, $t6             # word 1 has been shifted
    sllv  $t2, $t2, $t6             # word 2 has been shifted
    add		$t2, $t0, $t2		          # word 2 now has shiffted bits from word 1 shift

    j		checkSign				            # check the sign
  
aLargerThanB:
# A^ > B^   
    sub   $t6, $t1, $t3             # ^diff = A^ - B^

    addi	$t1, $s1, 0			          # t1 = A[1]
    addi	$t2, $s2, 0			          # t2 = A[2]
    addi	$t3, $s3, 0			          # t3 = B[1]
    addi	$t4, $s4, 0			          # t4 = B[2]
    #removing |S|E10...E0|
    sll   $t1, $t1, 12              # xx..xx00..00
    srl   $t1, $t1, 12              # 00..00xx..xx
    sll   $t3, $t3, 12              # xx..xx00..00
    srl   $t3, $t3, 12              # 00..00xx..xx
# shifting to make exponents equal
    li		$t0, 32
    sub		$t0, $t0, $t6		          # shift = 32 - exponent difference
    sllv  $t0, $t3, $t0             # t0 = shifted for word 2
    sllv  $t3, $t3, $t6             # word 1 has been shifted
    sllv  $t4, $t4, $t6             # word 2 has been shifted
    add		$t4, $t0, $t4		          # word 2 now has shiffted bits from word 1 shift  

#___________________________________________________________________________
# finding if there is a difference in sign
#___________________________________________________________________________   
checkSign:
#getting carry bits
    srl   $t7, $s1, 31              # 0000...000x
    srl   $t8, $s3, 31              # 0000...000x

# checking if one of the values is negative
    bne		$t7, $t8, greaterValue	  # we have a "subraction" problem
    j		startAdd				            # both signs are the same
   
#___________________________________________________________________________
# Which value is greater  (sub only) 
# so we can find out if the final answer is (+) or (-)
#___________________________________________________________________________  
    
greaterValue:
  bgt		$t1, $t3, aGb	      # A[1] > B[1]
  bgt   $t3, $t1, bGa       # A[1] < B[1]
  j aVSbSign                # A[1] == B[1]
aGb:  
  move 	$t0, $zero		      # $t0 = $zero
  j aVSbSign
bGa:  
  addi 	$t0, $zero, 1		    # $t0 = 1 
  j aVSbSign
checkWordTwo:
  bgt		$t2, $t4, aGb	      # A[2] > B[2]
  bgt   $t4, $t2, bGa       # A[2] < B[2]
  addi 	$t0, $zero, 1		    # A[2] == B[2] and final answer is 0       <<<<<<<<<<<<< edge case were final answer is 0, put a jump here

aVSbSign:
  bgt		$t7, $t8, negA	          # A is (-)
#B is (-)
  bne		$t0, $zero, finalNeg	    # A<B and B is (-) then finalNeg
  j		finalPos				            # jump to finalPos
  
negA:
  beq		$t0, $zero, finalNeg	    # A>B and A is (-) then finalNeg
finalPos:
  addi	$s0, $zero, 0			        # final answer is (+)
  j startAdd
finalNeg:
  addi	$s0, $zero, 1			        # final answer is (-)


# todo: add subraction by adding a carry bit to the one that needs it

#___________________________________________________________________________
# Addition
#___________________________________________________________________________  
startAdd:
# make the word represent the exponent
    sll   $t1, $s1, 1               # eleminate sign bit from A[1]
    srl   $t1, $t1, 21              # 00..00xx..xx
    sll   $t3, $s3, 1               # eleminate sign bit from B[1]
    srl   $t3, $t3, 21              # 00..00xx..xx

# checking which exponent is larger
    bge		$t1, $t3, aLargerThanB	  # if A^ >= B^ then target

  




   
    
    


