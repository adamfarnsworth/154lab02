
# Double-precision floating-point arithmetic

## Task
Double-precision floating-point FADD and FMUL functions in
MIPS using only integer instructions and integer registers. You are not supposed to use
ANY floating-point instructions or registers.  

1. Assume that the data section of your code contains two integer arrays A and B, each
which is of size 2 words, and their addresses are given in registers a0 and a1. Register
a0 (or a1) points to the most significant byte of the most significant word of A (or B).
For example, if A is the 64-bit vector written from the most significant to the least
significant bytes as: A7A6A5A4 A3A2A1A0, then address in register a0 is the address
of the byte A7.  

8 8 8 8  
a0 → A7 A6 A5 A4  
A3 A2 A1 A0  

However, you will interpret these 8 bytes as a double-precision floating-point number.
The most significant bit of the most significant byte (i.e., A7) contains the sign bit
of the floating-point number, while the following bits are the 11-bit (biased) exponent
and 52-bit fraction.  In other words a0 contains the address of the (most significant) byte which contains
the following 8 bits: SE10 E9 E8 E7 E6 E5 E4 E3 E2 E1. The next 3 bytes (24 bits) in the top
word contain the bits E3 E2 E1 E0 F1F2F3 · · · F20. The next word (addressed by a0+4)
contains the remaining 32 bits of the fraction: F21F22F23 · · · F51F52. Therefore, the
value of the double-precision floating point number is  
(−1)S × 2^(E−1023) × (1.F1F2 · · · F52)  

2. Perform the double-precision floating-point addition operation A + B assuming A and
B are IEEE double-precision floating-point numbers. Place the resulting floating-point
number as a 2-word binary vector in the memory location C whose address is given in
a2, according to the representation above.  
3. Perform the double-precision floating-point multiplication operation A × B assuming
A and B are IEEE 754 double-precision floating-point numbers. Place the resulting
floating-point number as a 2-word binary vector in the memory location D whose
address is given in a3, according to the representation above.  
4. You are expected to implement Rounding with R and S bits for both addition and
multiplication operations. The usage of the S bit implies that the fractions that are
right in the middle are rounded down (implying S = 0) and those that are above the
middle are rounded up (implying S = 1). For example, 23.5000 is rounded down to
23.0 (because it means S was zero), while 23.5001 is rounded up to 24.0 (because it
means S was one). 

