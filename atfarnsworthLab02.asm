  .data # Data declaration section
    #globals
    emptyArrayC: .space 8 #1 word = 4 bytes, 2 words = 8 bytes -> 64 bits
    emptyArrayD: .space 8 #1 word = 4 bytes, 2 words = 8 bytes -> 64 bits   
    wordSet1: .word 0, 0, 0, 0, 0, 0, 0, 0xffffffff
    wordSet2: .word 0, 0, 0, 0, 0, 0, 0, 0xffffffff
.text # Assembly language instructions

# a0 = A[]
# a1 = B[]
# a2 = C[]
# a3 = D[]
# t0 = temp
# t1 = exponent difference
# t4 = current word in A[i]
# t5 = current word in B[i]
# s0 = word A[1]
# s1 = word A[2]
# s3 = word B[1]
# s4 = word B[2]

# s6 = exponent difference

main:

  la		$a0, wordSet1		        # A = first set of words
  la		$a1, wordSet2		        # B = second set of words
  la		$a2, emptyArrayC	      # declairing "C"
  la		$a3, emptyArrayD	      # declairing "D" 

  #____________________________________
  # finding smaller exponent
  #____________________________________
    

findExponent:
#loading the first word in A and B
    lw		$t4, 0($a0)		            # $t4 = A[i]
    lw		$t5, 0($a1)		            # $t5 = B[i]

# make the word represent the exponent
    sll   $t4, $t4, 1               # eleminate sign bit from A
    srl   $t4, $t4, 21              # 00..00xx..xx
    sll   $t5, $t5, 1               # eleminate sign bit from B
    srl   $t5, $t5, 21              # 00..00xx..xx

# checking which exponent is larger
    bge		$t4, $t5, AlargerThanB	  # if A^ >= B^ then target

# A^ < B^
  sub   $s6, $t5, $t4             # ^diff = B^ - A^
  j		checkSign				            # jump to checkSign
  
# A^ > B^
AlargerThanB:
  sub   $s6, $t4, $t5             # ^diff = B^ - A^
  
checkSign:



   
    
    


