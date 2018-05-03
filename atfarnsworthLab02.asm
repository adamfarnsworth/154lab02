.data # Data declaration section
    #globals 1 word = 4 bytes, 2 words = 8 bytes -> 64 bits
    emptyArrayC: .space 8
    emptyArrayD: .space 8
    multiplyArr: .space 16
    aShiftArray: .space 16
    bShiftArray: .space 8
#23.8 = 0x4037CCCC CCCCCCCD
#1234.1234 = 0x4093487E 5C91D14E


    wordSet1: .word 0x4037CCCC, 0xCCCCCCCD
    wordSet2: .word 0x4093487E, 0x5C91D14E 
    # wordSet1: .word 0x4037B333, 0x33333333
    # wordSet2: .word 0x404C71EB, 0x851EB852
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

    sub     $t5, $t3, $t1                 # ^diff = B^ - A^

    addi	$t1, $s1, 0			          # t1 = A[1]
    addi	$t2, $s2, 0			          # t2 = A[2]
    addi	$t3, $s3, 0			          # t3 = B[1]
    addi	$t4, $s4, 0			          # t4 = B[2]

    addi	$t6, $s1, 0			          # t6 = A[1] #for overflow
    addi	$t7, $s2, 0			          # t7 = A[2]
    addi	$t8, $s3, 0			          # t8 = B[1]
    addi	$t9, $s4, 0			          # t9 = B[2]    
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

    li		$t0, 32
    sub		$t0, $t0, $t5		      # shift = 32 - exponent difference <<used to be 31
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
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
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

j multiplicationTime

BminusA:
# subtracting RHS of A[2] and B[2]
    sll     $t1, $t7, 16            #xx..xx00..00
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
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

j multiplicationTime

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
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
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

j multiplicationTime
  
multiplicationTime:
#___________________________________________________________________________
# Multiplication
#___________________________________________________________________________ 
# a0 = A[]
# a1 = B[]
# a2 = C[]
# a3 = D[]
# t0 = temp
# t1 = current word in A[1]
# t2 = current word in A[2]
# t3 = current word in B[1]
# t4 = current word in B[2]
# t5 = temp2
# t6 = 
# t7 = 
# t8 = 
# t9 = 
# s0 = 
# s1 = word A[1]
# s2 = word A[2]
# s3 = word B[1]
# s4 = word B[2]
# s5 = A[1-4]
# s6 = B[1-2]
# s7 = S[1-4]
#___________________________________________________________________________ 

#finding final exponent
    add		$t1, $zero, $s1	        # Current word in A[1]
    sll     $t1, $t1, 1             # getting rid of sign
    srl     $t1, $t1, 21            # 00..00xx..xx

    add		$t3, $zero, $s3	        # Current word in B[1]
    sll     $t3, $t3, 1             # getting rid of sign
    srl     $t3, $t3, 21            # 00..00xx..xx

    add     $t5, $t1, $t3           # adding exponents
    addi    $t5, $t5, 0             # 2x2... shifts exponent <<<this might be 1, not 0
    addi	$t0, $zero, 1023        # loading 1023
    sub     $t5, $t5, $t0           # final exponent is in $t5

#setting up exponent for D[1]
    sll     $t5, $t5, 20            # 0x..xx00..00

#finding if answer will be (+) or (-)     
    add		$t1, $zero, $s1	        # Current word in A[1]
    srl     $t1, $t1, 31            # 00..0000..0x
    
    add		$t3, $zero, $s3	        # Current word in B[1]
    srl     $t3, $t3, 31            # 00..0000..0x

    beq		$t1, $t3, answerIsPos	# answer is (+)
    addi    $t0, $zero, 1           # answer is (-)
    sll     $t0, $t0, 31            # x0..0000..00
    add     $t5, $t5, $t0           # sign and exponent ready to load into D[1]
    sw		$t5, 0($a3)		        # exponent and sign saved in D[1]
   
    j		multAdd				    # jump to multAdd  
answerIsPos:    
    sw		$t5, 0($a3)		        # exponent and sign saved in D[1]
       
multAdd:
# setting up variables
    la		$s5, aShiftArray	    # declairing A[1-4] 
    la		$s6, bShiftArray	    # declairing B[1-2] 
    la		$s7, multiplyArr	    # declairing S[1-4]            
#setting up A[1-4] from A[1-2]    
    addi	$t1, $s1, 0             # getting old A[1]
    sll     $t1, $t1, 12            # get rid of sign and exponents
    srl     $t1, $t1, 12            # ready to load
    sw      $t1, 8($s5)             # saving A[3]
    addi	$t1, $s2, 0             # getting old A[2]
    sw      $t1, 12($s5)            # saving A[4] 
#setting up new B[1-2]
    addi	$t1, $s3, 0             # getting old B[1]
    sll     $t1, $t1, 12            # get rid of sign and exponents
    srl     $t1, $t1, 12            # ready to load
    sw      $t1, 0($s6)             # saving new B[1]
    addi    $t1, $s4, 0             # getting old B[2]
    sw      $t1, 4($s6)             # saving new B[2]   

    addi    $s0, $zero, 0           # setting count to 0
startMultiplyAdd:
#checking if addition occurs
    lw      $t4, 4($s6)             # loading B[2]
    sll     $t4, $t4, 31            # x0..0000..00
    srl     $t4, $t4, 31            # 00..0000..0x
    beq		$t4, $zero, shiftAandB  # nothing to add

#____________
#      4
#____________
    lw      $t7, 12($s5)            # loading A[4]
    lw      $t9, 12($s7)            # loading S[4]  
# adding RHS of A[4] and S[4]
    sll     $t1, $t7, 16            #xx..xx00..00  
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
    add		$t4, $t1, $t2		    # rhs = A[4]rhs + S[4]rhs    
    srl     $t0, $t4, 16            # getting carry bit
# adding LHS of A[4] and S[4]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    add		$t3, $t1, $t2		    # lhs = A[4]lhs + B[4]lhs
    add		$t3, $t3, $t0		    # lhs = lhs + carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for S[4]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[4] + S[4]   
    sw		$t5, 12($s7)		    # S[4] = A[4] + S[4]

#____________
#      3
#____________
    lw      $t7, 8($s5)            # loading A[3]
    lw      $t9, 8($s7)            # loading S[3]  
# adding RHS of A[3] and S[3]
    sll     $t1, $t7, 16            #xx..xx00..00  
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
    add		$t4, $t1, $t2		    # rhs = A[3]rhs + S[3]rhs
    add		$t4, $t4, $t0		    # rhs = rhs + carry        
    srl     $t0, $t4, 16            # getting carry bit
# adding LHS of A[3] and S[3]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    add		$t3, $t1, $t2		    # lhs = A[3]lhs + S[3]lhs
    add		$t3, $t3, $t0		    # lhs = lhs + carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for S[3]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[3] + S[3]   
    sw		$t5, 8($s7)		        # S[3] = A[3] + S[3]
#____________
#      2
#____________   
    lw      $t7, 4($s5)            # loading A[2]
    lw      $t9, 4($s7)            # loading S[2]  
# adding RHS of A[2] and S[2]
    sll     $t1, $t7, 16            #xx..xx00..00  
    sll     $t2, $t9, 16            #xx..xx00..00
    srl     $t1, $t1, 16            #00..00xx..xx
    srl     $t2, $t2, 16            #00..00xx..xx
    add		$t4, $t1, $t2		    # rhs = A[2]rhs + S[2]rhs
    add		$t4, $t4, $t0		    # rhs = rhs + carry        
    srl     $t0, $t4, 16            # getting carry bit
# adding LHS of A[2] and S[2]
    srl     $t1, $t7, 16            #00..00xx..xx
    srl     $t2, $t9, 16            #00..00xx..xx
    add		$t3, $t1, $t2		    # lhs = A[2]lhs + S[2]lhs
    add		$t3, $t3, $t0		    # lhs = lhs + carry
    srl     $t0, $t3, 16            # getting carry bit
    sll     $t3, $t3, 16            #xx..xx00..00
# mergeing LHS and RHS for S[2]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[2] + S[2]   
    sw		$t5, 4($s7)		        # S[2] = A[2] + S[2]
#____________
#      1
#____________  
    lw      $t7, 0($s5)            # loading A[1]
    lw      $t9, 0($s7)            # loading S[1]  
# adding RHS of A[1] and S[1]
    sll     $t1, $t7, 16            # xx..xx00..00  
    sll     $t2, $t9, 16            # xx..xx00..00
    srl     $t1, $t1, 16            # 00..00xx..xx
    srl     $t2, $t2, 16            # 00..00xx..xx
    add		$t4, $t1, $t2		    # rhs = A[1]rhs + S[1]rhs
    add		$t4, $t4, $t0		    # rhs = rhs + carry        
    srl     $t0, $t4, 16            # getting carry bit
# adding LHS of A[1] and S[1]
    srl     $t1, $t7, 16            # 00..00xx..xx
    srl     $t2, $t9, 16            # 00..00xx..xx
    add		$t3, $t1, $t2		    # lhs = A[1]lhs + S[1]lhs
    add		$t3, $t3, $t0		    # lhs = lhs + carry
    srl     $t0, $t3, 16            # getting carry bit
    add     $t0, $zero, 0                                   # i got a feeling
    sll     $t3, $t3, 16            # xx..xx00..00
# mergeing LHS and RHS for S[1]
    add     $t5, $t3, $t4           # lhs + rhs ===> A[1] + S[1]   
    sw		$t5, 0($s7)		        # S[1] = A[1] + S[1]    

shiftAandB:
# shift A[1-4] and B[1-2], itterate count, repeat startMultiplyAdd
#____________
#   A[1-4]
#____________  
    lw      $t1, 12($s5)            # loading A[4]
    srl     $t5, $t1, 31            # 00..0000..0c
    sll     $t1, $t1, 1             # xx..xxxx..x0
    sw      $t1, 12($s5)            # saving shifted A[4]
    addi    $t0, $t5, 0             # saving carry bit

    lw      $t1, 8($s5)             # loading A[3]
    srl     $t5, $t1, 31            # 00..0000..0x
    sll     $t1, $t1, 1             # xx..xxxx..x0
    add     $t1, $t1, $t0           # xx..xxxx..xc
    sw      $t1, 8($s5)             # saving shifted A[3]
    addi    $t0, $t5, 0             # saving carry bit

    lw      $t1, 4($s5)             # loading A[2]
    srl     $t5, $t1, 31            # 00..0000..0x
    sll     $t1, $t1, 1             # xx..xxxx..x0
    add     $t1, $t1, $t0           # xx..xxxx..xc
    sw      $t1, 4($s5)             # saving shifted A[2]   
    addi    $t0, $t5, 0             # saving carry bit

    lw      $t1, 0($s5)             # loading A[1]
    srl     $t5, $t1, 31            # 00..0000..0x
    sll     $t1, $t1, 1             # xx..xxxx..x0
    add     $t1, $t1, $t0           # xx..xxxx..xc
    sw      $t1, 0($s5)             # saving shifted A[1]   
    addi    $t0, $t5, 0             # saving carry bit    
#____________
#   B[1-2]
#____________ 
    lw      $t1, 0($s6)             # loading B[1]
    sll     $t5, $t1, 31            # c0..0000..00
    srl     $t1, $t1, 1             # 0x..xxxx..xx
    sw      $t1, 0($s6)             # saving shifted B[1]
    addi    $t0, $t5, 0             # saving carry bit

    lw      $t1, 4($s6)             # loading B[2]
    srl     $t1, $t1, 1             # 0x..xxxx..xx
    add     $t1, $t1, $t0           # cx..xxxx..xx
    sw      $t1, 4($s6)             # saving shifted B[2]
    addi    $t0, $t5, 0             # saving carry bit    

# itterating counter
    addi    $s0, $s0, 1                 # count++
    addi    $t0, $zero, 52              # count ittereates 52 times
    bne		$t0, $s0, startMultiplyAdd	# repeat untill multiplicaiton is done

#___________________________________________________________________________
# Saving to D[1-2]
#___________________________________________________________________________ 
    lw      $t1, 0($s7)                 # loading S[1]
    srl     $t2, $t1, 8                 # 00..0000..0x
    beq     $t2, $zero, shiftEight      # shifting eight
# shifting 9
    sll     $t1, $t1, 23                # xx..xx00..00  getting 9 from S[1]
    lw      $t2, 4($s7)                 # loading S[2]
    sll     $t0, $t2, 23                # xx..xx00..00  saving 9 from S[2]
    srl     $t0, $t0, 3                 # 00..xx00..00  shifting for the 12    
    srl     $t2, $t2, 9                 # 00..00xx..xx  making space for the 9
    add     $t2, $t2, $t1               # S[1] empty    loading the 9 from S[1]
# dealing with the 12 bit shift along with tracking the 9 bit    
    sll     $t3, $t2, 20                # xx..xx00..00
    srl     $t3, $t3, 29                # 00..00xx..xx
    sll     $t3, $t3, 29                # xx..0000..00
    add     $t3, $t3, $t0               # got the 12
j finishHim

shiftEight:
# shifting 8
    sll     $t1, $t1, 24                # xx..xx00..00  getting 8 from S[1]
    lw      $t2, 4($s7)                 # loading S[2]
    sll     $t0, $t2, 24                # xx..xx00..00  saving 9 from S[2]
    srl     $t0, $t0, 4                 # 00..xx00..00  shifting for the 12    
    srl     $t2, $t2, 8                 # 00..00xx..xx  making space for the 8
    add     $t2, $t2, $t1               # S[1] empty    loading the 8 from S[1]
# dealing with the 12 bit shift along with tracking the 8 bit    
    sll     $t3, $t2, 20                # xx..xx00..00
    srl     $t3, $t3, 28                # 00..00xx..xx
    sll     $t3, $t3, 28                # xx..0000..00
    add     $t3, $t3, $t0               # got the 12    

finishHim:
    srl     $t2, $t2, 12                #made room for the exponent and sign
    lw      $t0, 0($a3)
    add     $t2, $t2, $t0
    sw      $t2, 0($a3)                 # F1...F20 into D[1]



    lw      $t4, 8($s7)                 # loading S[3]
    srl     $t4, $t4, 12                # final shift
    add     $t4, $t4, $t3               # ready to save
    sw      $t4, 4($a3)                 # F21...f52 into D[2]



    # lw      $t1, 0($s7)         # loading S[1]
    # sll     $t0, $t1, 20        # xx..xx00..00
    # srl     $t1, $t1, 12        # 00..00xx..xx
    # sw      $t1, 0($a3)         # F1...F20 into D[1]

    # lw      $t1, 4($s7)         # loading S[2]
    # srl     $t1, $t1, 12        # 00..00xx..xx
    # add     $t1, $t1, $t0       # shifted bit are ready to go
    # sw      $t1, 4($a3)         # F21...f52 into D[2]



    
    

exit:
    li $v0, 10
    syscall


   
    
    


