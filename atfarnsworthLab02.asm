.data # Data declaration section
    #globals 1 word = 4 bytes, 2 words = 8 bytes -> 64 bits
    emptyArrayC: .space 8
    emptyArrayD: .space 8
    wordSet1: .word 0x4037B333, 0x33333333
    wordSet2: .word 0x404C71EB, 0x851EB852
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
# t5 = exponent difference
# t6 = current word in A[1] with overflow
# t7 = current word in A[2] with overflow
# t8 = current word in B[1] with overflow
# t9 = current word in B[2] with overflow
# s0 = (+) or (-) final answer
# s1 = word A[1]
# s2 = word A[2]
# s3 = word B[1]
# s4 = word B[2]
# s5 = right side
# s6 = left side
main:

  la		$a0, wordSet1		      # A = first set of words
  la		$a1, wordSet2		      # B = second set of words
  la		$a2, emptyArrayC	      # declairing "C"
  la		$a3, emptyArrayD	      # declairing "D" 
  lw		$s1, 0($a0)		          # $s1 = A[1]
  lw		$s2, 4($a0)		          # $s2 = A[2]
  lw		$s3, 0($a1)		          # $s3 = B[1]
  lw		$s4, 4($a1)		          # $s4 = B[2]
  
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
# assinging exponent to C[1]
    sll     $t5, $s3, 1                   # get rid of sign bit
    srl     $t5, $t5, 21                  # 00..00xx..xx
    sll     $t5, $t5, 20                  # 0x..xx00..00
    sw		$t5, 0($a2)		              # C[1] = 0x..xx00..00 has exponent

    sub   $t5, $t3, $t1             # ^diff = B^ - A^

    addi	$t1, $s1, 0			          # t1 = A[1]
    addi	$t2, $s2, 0			          # t2 = A[2]
    addi	$t3, $s3, 0			          # t3 = B[1]
    addi	$t4, $s4, 0			          # t4 = B[2]

    addi	$t6, $s1, 0			          # t1 = A[1] #for overflow
    addi	$t7, $s2, 0			          # t2 = A[2]
    addi	$t8, $s3, 0			          # t3 = B[1]
    addi	$t9, $s4, 0			          # t4 = B[2]    
#removing |S|E10...E0|
    sll     $t1, $t1, 12              # xx..xx00..00
    srl     $t1, $t1, 12              # 00..00xx..xx
    sll     $t3, $t3, 12              # xx..xx00..00
    srl     $t3, $t3, 12              # 00..00xx..xx

    sll     $t6, $t6, 11              # xx..xx00..00 # keeping extra bit
    srl     $t6, $t6, 11              # 00..00xx..xx 
    sll     $t8, $t8, 12              # xx..xx00..00
    srl     $t8, $t8, 12              # 00..00xx..xx
# shifting to make exponents equal
    li		$t0, 32
    sub		$t0, $t0, $t5		      # shift = 32 - exponent difference
    sllv    $t0, $t1, $t0             # t0 = shifted for word 2
    srlv    $t1, $t1, $t5             # word 1 has been shifted
    srlv    $t2, $t2, $t5             # word 2 has been shifted
    add		$t2, $t0, $t2		      # word 2 now has shiffted bits from word 1 shift

    li		$t0, 31
    sub		$t0, $t0, $t5		      # shift = 31 - exponent difference
    sllv    $t0, $t6, $t0             # t0 = shifted for word 2
    srlv    $t6, $t6, $t5             # word 1 has been shifted
    srlv    $t7, $t7, $t5             # word 2 has been shifted
    add		$t7, $t0, $t7		      # word 2 now has shiffted bits from word 1 shift

    j		checkSign				            # check the sign
  
aLargerThanB: # A^ > B^
# assinging exponent to C[1]
    sll     $t5, $s1, 1                   # get rid of sign bit
    srl     $t5, $t5, 21                  # 00..00xx..xx
    sll     $t5, $t5, 20                  # 0x..xx00..00
    sw		$t5, 0($a2)		              # C[1] = 0x..xx00..00 has exponent

    sub     $t5, $t1, $t3                 # ^diff = A^ - B^

    addi	$t1, $s1, 0			          # t1 = A[1]
    addi	$t2, $s2, 0			          # t2 = A[2]
    addi	$t3, $s3, 0			          # t3 = B[1]
    addi	$t4, $s4, 0			          # t4 = B[2]

    addi	$t6, $s1, 0			          # t1 = A[1] #for overflow
    addi	$t7, $s2, 0			          # t2 = A[2]
    addi	$t8, $s3, 0			          # t3 = B[1]
    addi	$t9, $s4, 0			          # t4 = B[2]  
#removing |S|E10...E0|
    sll     $t1, $t1, 12              # xx..xx00..00
    srl     $t1, $t1, 12              # 00..00xx..xx
    sll     $t3, $t3, 12              # xx..xx00..00
    srl     $t3, $t3, 12              # 00..00xx..xx

    sll     $t6, $t6, 12              # xx..xx00..00 
    srl     $t6, $t6, 12              # 00..00xx..xx 
    sll     $t8, $t8, 11              # xx..xx00..00 # keeping extra bit
    srl     $t8, $t8, 11              # 00..00xx..xx
# shifting to make exponents equal
    li		$t0, 32
    sub		$t0, $t0, $t5		      # shift = 32 - exponent difference
    sllv    $t0, $t3, $t0             # t0 = shifted for word 2
    srlv    $t3, $t3, $t5             # word 1 has been shifted
    srlv    $t4, $t4, $t5             # word 2 has been shifted
    add		$t4, $t0, $t4		      # word 2 now has shiffted bits from word 1 shift

    li		$t0, 31
    sub		$t0, $t0, $t5		      # shift = 31 - exponent difference
    sllv    $t0, $t8, $t0             # t0 = shifted for word 2
    srlv    $t8, $t8, $t5             # word 1 has been shifted
    srlv    $t9, $t9, $t5             # word 2 has been shifted
    add		$t9, $t0, $t9		      # word 2 now has shiffted bits from word 1 shift  

#___________________________________________________________________________
# finding if there is a difference in sign
#___________________________________________________________________________   
checkSign:
#getting carry bits
    srl   $t0, $s1, 31              # 0000...000x
    srl   $t5, $s3, 31              # 0000...000x

# checking if one of the values is negative
    bne		$t0, $t5, greaterValue	            # we have a "subraction" problem
    j		startAdd				            # both signs are the same
   
#___________________________________________________________________________
# Which value is greater  (sub only) 
# so we can find out if the final answer is (+) or (-)
#___________________________________________________________________________  
    
greaterValue:
    bgt     $t1, $t3, aGb	          # A[1] > B[1]
    bgt     $t3, $t1, bGa             # A[1] < B[1]
    beq		$t1, $t3, aEQb	          # A[1] == B[1]  
aGb:
    bgt     $t0, $t5, negBminusA	  # A is (-) A > B
    bgt     $t5, $t0, posAminusB      # B is (-) A > B
bGa:  
    bgt     $t0, $t5, posBminusA	  # A is (-) A < B
    bgt     $t5, $t0, negAminusB      # B is (-) A < B
aEQb:
    bgt     $t2, $t4, aGb	          # A[2] > B[2]
    bgt     $t4, $t2, bGa             # A[2] < B[2]
    #j      answerIsZero		      # A[2] == B[2] and final answer is 0       <<<<<<<<<<<<< edge case were final answer is 0, put a jump here
  
negBminusA:
    addi    $t0, $zero, 1		  # final answer is (-)
    sll     $t0, $t0, 31          # 10..0000..00  
    lw		$t5, 0($s1)		      # 0xx..xx00..00
    add		$t0, $t0, $t5		  # 1xx..xx00..00
    sw		$t0, 0($a2)		      # C[1] = 1xx..xx00..00
    j       BminusA               # -(B-A)

posAminusB:
                                  # final answer is (+) 
                                  # C[1] = 0xx..xx00..00    
    j		AminusB			      # +(A-B)
posBminusA:
                                  # final answer is (+) 
                                  # C[1] = 0xx..xx00..00    
    j		BminusA			      # +(B-A)
negAminusB:
    addi    $t0, $zero, 1		  # final answer is (-)
    sll     $t0, $t0, 31          # 10..0000..00  
    lw		$t5, 0($s1)		      # 0xx..xx00..00
    add		$t0, $t0, $t5		  # 1xx..xx00..00
    sw		$t0, 0($a2)		      # C[1] = 1xx..xx00..00
    j		AminusB			      # -(A-B)

#___________________________________________________________________________
# Subtraction
#___________________________________________________________________________
# t0 = carry
# t1 = A l/r
# t2 = B l/r
# t3 = final L
# t4 = final R
# t5 = L+R
# t6 = A[1]
# t7 = A[2]
# t8 = B[1]
# t9 = B[2]
#___________________________________________________________________________     

AminusB: 
# subtracting RHS of A[2] and B[2]
    sll     $t1, $t7, 16            #xx..xx00..00
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    sub		$t4, $t1, $t2		    # rhs = A[2]rhs - B[2]rhs
    srl     $t0, $t4, 16            # getting carry bit
# subtracting LHS of A[2] and B[2]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    sub		$t3, $t1, $t2		    # lhs = A[2]lhs - B[2]lhs
    sub		$t3, $t3, $t0		    # lhs = lhs - carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for C[2]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[2] - B[2]
    sw		$t5, 4($a2)		        # C[2] = A[2] - B[2]
# subtracing A[1] and B[1]
    sub     $t5, $t6, $t8           # A[1] - B[1]
    sub     $t5, $t5, $t0           # - carry
    lw		$t0, 0($a2)		        # get C[1]
    add     $t0, $t0, $t5           # adding values for C[1]
    sw		$t0, 0($a2)		        # loading value ==> C[1]

j exit

BminusA:
# subtracting RHS of A[2] and B[2]
    sll     $t1, $t7, 16            #xx..xx00..00
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    sub		$t4, $t2, $t1		    # rhs = B[2]rhs - A[2]rhs
    srl     $t0, $t4, 16            # getting carry bit
# subtracting LHS of A[2] and B[2]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    sub		$t3, $t2, $t1		    # lhs = B[2]lhs - A[2]lhs
    sub		$t3, $t3, $t0		    # lhs = lhs - carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for C[2]
    add     $t5, $t3, $t4           # lhs + rhs ===> B[2] - A[2]
    sw		$t5, 4($a2)		        # C[2] = B[2] - A[2]
# subtracing A[1] and B[1]
    sub     $t5, $t8, $t6           # B[1] - A[1]
    sub     $t5, $t5, $t0           # - carry
    lw		$t0, 0($a2)		        # get C[1]
    add     $t0, $t0, $t5           # adding values for C[1]
    sw		$t0, 0($a2)		        # loading value ==> C[1]

j exit

#___________________________________________________________________________
# Addition
#___________________________________________________________________________  
# t0 = carry
# t1 = A l/r
# t2 = B l/r
# t3 = final L
# t4 = final R
# t5 = L+R
# t6 = A[1]
# t7 = A[2]
# t8 = B[1]
# t9 = B[2]
#___________________________________________________________________________  
startAdd:
# adding RHS of A[2] and B[2]
    sll     $t1, $t7, 16            #xx..xx00..00
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    add		$t4, $t1, $t2		    # rhs = A[2]rhs + B[2]rhs
    srl     $t0, $t4, 16            # getting carry bit
# adding LHS of A[2] and B[2]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    add		$t3, $t1, $t2		    # lhs = A[2]lhs + B[2]lhs
    add		$t3, $t3, $t0		    # lhs = lhs + carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for C[2]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[2] + B[2]
    sw		$t5, 4($a2)		        # C[2] = A[2] + B[2]
# adding A[1] and B[1]
    add     $t5, $t6, $t8           # A[1] + B[1]
    add     $t5, $t5, $t0           # + carry
    lw		$t0, 0($a2)		        # get C[1]
    add     $t0, $t0, $t5           # adding values for C[1]
    sw		$t0, 0($a2)		        # loading value ==> C[1]

j exit
  

exit:
    li $v0, 10
    syscall


   
    
    


