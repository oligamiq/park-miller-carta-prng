; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;
; Park-Miller-Carta Pseudo-Random Number Generator
;
; For Microchip.com dsPIC DSP microcontroller.
;
; Copyright public domain   Robin Whittle   2005 Sept 21
;                                       
; 31 bit pseudo-random number generator based on:
;
;   Lehmer (1951)
;   Lewis, Goodman & Miller (1969)
;   Park & Miller (1983)
;   
; implemented according to the optimisation suggested by David G. Carta
; in 1990 which uses 32 bit math and does not require division.  
; Park and Miller rejected Carta's approach in 1993.  Carta provided no 
; code examples.  Carta's approach produces identical results to Park 
; and Miller's code.
;
; Copyright public domain . . . *but*:
;
; * Please leave the comments intact so inquiring minds have a chance of 
; * understanding how this implementation works and chasing the 
; * references to see the strengths and limitations of this particular 
; * pseudo-random number generator.
;
; Output is a 31 bit unsigned integer.  The range of values output is
; 1 to 2,147,483,646 and the seed must be in this range too.  The
; output sequence repeats in a loop of this length = (2^31 - 2).
;
; The output stream has some predictable patterns.  For instance, after 
; a very low output, the next one or two outputs will be relatively low 
; (compared to the 2 billion range) because the multiplier is only 16,807.
; Linear congruential generators are not suitable for cryptography or 
; simulation work (such as Monte Carlo Method), but they are probably 
; fine for many uses where the output is sound or vision for human 
; perception.  
;
; The particular generator implemented here:
;
;   New-value = (old-value * 16807) mod 0x7FFFFFFF      
;
; is probably the best studied linear congruentual PRNG.  It is not the very
; best, but it is far from the worst.
;
; For the background on this implementation, and the Park Miller
; "Minimal Standard" linear congruential PRNG, please see:
;
;    http://www.firstpr.com.au/dsp/rand31/  
;
;    Stephen K. Park and Keith W. Miller 
;    Random Number Generators: Good Ones are Hard to Find
;    Communications of the ACM, Oct 1988, Vol 31 Number 10 1192-1201
;
;    David G. Carta
;    Two Fast Implementations of the "Minimal Standard" Random Number Generator
;    Communications of the ACM, Jan 1990, Vol 33 Number 1 87-88
;
;    George Marsaglia; Stephen J. Sullivan; Stephen K. Park, Keith W. Miller, 
;    Paul K. Stockmeyer
;    Remarks on Choosing and Implementing Random Number Generators 
;    Communications of the ACM, Jul 1993, Vol 36 Number 7 105-110
;
;    http://random.mat.sbg.ac.at has lots of material on PRNG quality. 
;
;
; The sequence of values this PRNG should produce includes:
; 
;      Result     Number of results after seed of 1
;
;       16807          1
;   282475249          2
;  1622650073          3
;   984943658          4
;  1144108930          5
;   470211272          6
;   101027544          7
;  1457850878          8
;  1458777923          9
;  2007237709         10
;
;   925166085       9998
;  1484786315       9999
;  1043618065      10000
;  1589873406      10001
;  2010798668      10002
;
;  1227283347    1000000
;  1808217256    2000000
;  1140279430    3000000
;   851767375    4000000
;  1885818104    5000000
;
;   168075678   99000000
;  1209575029  100000000
;   941596188  101000000
;
;
; Carta refers to two registers p (15 bits) and q (31 bits) which
; together hold the 46 bit multiplication product:
;
;         |                   |                   |                        |
;          4444 4444 3333 3333 3322 2222 2222 1111 1111 11            
;          7654 3210 9876 5432 1098 7654 3210 9876 5432 1098 7654 3210
;
;   q 31                        qqq qqqq qqqq qqqq qqqq qqqq qqqq qqqq
;   p 15     pp pppp pppp pppp p
;
; The maximum 46 bit result occurs 
; when the seed is at its highest
; allowable value: 0x7FFFFFFE.  
;
;    0x20D37FFF7CB2      
;
; which splits up like this     
;
;   q 31                        111 1111 1111 1111 0111 1100 1011 0010
;   p 15     10 0000 1101 0011 0
;          =  100 0001 1010 0110 
;
; In hex, these maxiumum values are:
;
;   q 31     7FFF7CB2  = 2^31 - (2 * 16807)
;   p 15         41A6  = 16807 - 1
;
;
; The task is to combine the two partial products p and q as if they were
; both parts of a 46 bit number, with the final result being modulo:
;
;                              0111 1111 1111 1111 1111 1111 1111 1111
;
; when we are actually only doing 32 bits at a time.  
;
; Here I explain David G. Carta's trick - in a different and much simpler 
; way than he does.
;
; We need to deal with the p bits "pp pppp pppp pppp p" shown above.  
; These bits carry weights of bits 45 to 31 in the multiplication product 
; of the usual Park Miller algorithm.
; 
; David Carta writes that in order to calculate mod(0x7FFFFFFF) of the
; complete multiplication product (taking into account the total value
; of p and q) we should simply add the bits of p into the bit positions 
; 14 to 0 of q and then do a mod(0x7FFFFFFF) on the result!  
;
;         |                   |                   |                        |
;          4444 4444 3333 3333 3322 2222 2222 1111 1111 11            
;          7654 3210 9876 5432 1098 7654 3210 9876 5432 1098 7654 3210
;
;     31                        qqq qqqq qqqq qqqq qqqq qqqq qqqq qqqq
;     15                   +                        ppp pppp pppp pppp
;                          =   Cxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
;                               
; Highest possible value,
; for q, with a value for
; p which would allow it:
;             
;                   7FFFFFFF    111 1111 1111 1111 1111 1111 1111 1111
;                +      41A5                        100 0001 1010 0101
;                = 8000041A4   1000 0000 0000 0000 0100 0001 1010 0100
;
; The result can't be larger than 2 * 0x7FFFFFFF = 0xFFFFFFFE.  So when we 
; do the modulus operation, we will have to subtract either nothing or just
; one 0x7FFFFFFF.  With this model of addition, the subtraction only 
; occurs very rarely.
;
; David Carta's explanation for why this produces the correct answer is too 
; long to repeat here.  Mine is easy to understand. 
;
; Lets define some labels:
;
;  Q = 31 bits 30 to 0. 
;  P = 15 bits 14 to 0.  
;
; If we were doing 46 bit math, the multiplication product (seed * 16807) 
; would be: 
;
;     Q
;  + (P * 0x80000000) 
;
; Observe that this is the same as:
;
;     Q
;  + (P * 0x7FFFFFFF) 
;  + (P * 0x00000001) 
;                                                                       
; However, we don't need or want a 46 bit result.  We only want that result
; mod(0x7FFFFFFF).  Therfore we can ignore the middle line above and use for 
; our result:
;       
;    Q
;  + P  
;
; dsPIC-specific details:
;
; Here is how we do the additions, and their carries.  This is somewhat 
; different from the detail of David Carta's approach, but we get the same 
; results.
;
; We generate the partial results lo and hi as shown below, with 
; two multiplies.  :
;
;    lo (31 bits) = seed low   (16 bits) * 16807 (15 bits)
;    hi (30 bits) = seed high  (15 bits) * 16807 (15 bits)
;
;         |                   |                   |                        |
;          4444 4444 3333 3333 3322 2222 2222 1111 1111 11            
;          7654 3210 9876 5432 1098 7654 3210 9876 5432 1098 7654 3210
;
;                             /         W1        |         W0        \
;  lo 31                       0xxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx            
;  hi 30   00xx xxxx xxxx xxxx xxxx xxxx xxxx xxxx
;         \         W3        |         W2        /  
;
; 16807 is 0x41A7.  The maximum results are for the maximum allowable
; seed value of 0x7FFFFFFE:
;       
;  lo = 0xFFFE * 0x41A7 = 0x41A67CB2
;  hi = 0x7FFF * 0x41A7 = 0x20D33E59    
;
;         |                   |                   |                        |
;          4444 4444 3333 3333 3322 2222 2222 1111 1111 11            
;          7654 3210 9876 5432 1098 7654 3210 9876 5432 1098 7654 3210
;
;  lo 31                       0100 0001 1010 0110 0111 1100 1011 0010            
;  hi 30   0010 0000 1101 0011 0011 1110 0101 1001
;
; Note these bits of hi:       ^^^^ ^^^^ ^^^^ ^^^^
; could be all 1s, or nearly
; all 1s, when the higher bits 
; have lower values than those
; above.
;   
; Now consider where the split is between p and q in David Carta's model:
;
;         |                   |                   |                        |
;          4444 4444 3333 3333 3322 2222 2222 1111 1111 11            
;          7654 3210 9876 5432 1098 7654 3210 9876 5432 1098 7654 3210
;
;                             /         W1        |         W0        \
;  lo 31                       0100 0001 1010 0110 0111 1100 1011 0010            
;  hi 30   0010 0000 1101 0011 0011 1110 0101 1001
;                               qqq qqqq qqqq qqqq qqqq qqqq qqqq qqqq
;            pp pppp pppp pppp p
;         \         W3        |         W2        /  
;
; According to David Carta's principle, we need to treat the p bits totally
; differently from the q bits.  They are beyond the 31 bit range of the 
; final result.  In our physical implementation, we have the 30 q bits and
; the lowest p bit in register pair "lo".  But we also have some q bits in 
; register pair "hi" along with the rest of the p bits.  We have two tasks:
;
; 1 - Add the q bits in "hi" into register pair "lo", starting at bit 16.
;     This can produce an overflow beyond this 32 bit register pair, into 
;     the Carry flag.  We must then treat that Carry bit as the same weight 
;     as the least significant p bit.  (Alternatively, do a mod(0x7FFFFFFF) 
;     operation on the result, which clears bit 31 and increments the 
;     register.  That increment has the same function as adding 1 to the p 
;     bits.
;
; 2 - Get the p bits and add them to register pair "lo", starting at bit 0.
;
; Doing it in this order is OK, but we have two potential carry situations.
; My approach does it in the opposite order.  First we add the p bits as 
; shown above (not including any carry from adding low "hi" bits to high 
; "lo" bits - we haven't done that yet) into the low end of "lo".  The 
; exact way we do this is a bit of a trick.  We Shift Left W2, to put its
; bit 15, which is a 'p' bit, into the Carry flag.  Then we Rotate Left
; with Carry W3.  This means that W3 contains all the 'p' bits, ready
; to add to register pair "lo".  W2 is still in a shifted state:
;
;   W2 = qqqq qqqq qqqq qqq0    
;
; but we will sort that out in a moment.
;
; We add the p bits in W3 to W0.  This may cause a carry, which needs to
; be propagated into W1.  We do in a moment.  Now, we restore W2 to:
;
;  W2 = 0qqq qqqq qqqq qqqq
;
; We need to add W2 into W1, and we also have the Carry bit to add - so
; 
;  W1 = W1 + W2 + Carry bit
;
; Then we are ready to do the mod(0x7FFFFFFF) operation which produces
; the final result.  
;
;
; This subroutine, on average uses 18 clock cycles including the 2 cycle 
; call and the 3 cycle return.  It could be rewritten to be faster as
; inline code, rather than a subroutine, and by using two Wx registers for 
; the seed, rather than the two file registers RAND31L and RAND31H.
; 
; dsPICs can run at 30 MHz, which means they can create well over a 
; million results a second.  Power consumption at 30 MHz 5 volts is 
; typically 730mW (145 mA for the 64 pin dsPIC30F6012) or 335mW 
; (67mA 28 pin dsPIC30F2010).  
;
; There must be two words of RAM:
;
;                                       ; 31 bit value, 16 bits in 
;                                       ; low word and 15 bits in 
;                                       ; high word.  Must be 
;                                       ; initialised to between 1 
;                                       ; and 0x7FFFFFFE inclusive.
;  RAND31L: .space 2                    ;
;  RAND31H: .space 2                    ;
;
; This subroutine uses the registers:
;
;    W0  = Constant 16807.      
;          Then lo bits 15 to 0.
;          Finally, returns the lower 16 bits of the new
;          pseudo-random number.
;
;    W1  = First, lo bits 30 to 16.
;          Then returns the upper 15 bits of the new
;          pseudo-random number.
;
; W3-W2  = hi 
;
; W12    = pointer to save a CPU cycle by making RAND31H/L
;          available for the multiply operations without
;          the two CPU cycles required for copying their
;          contents into registers.  See below for getting
;          rid of the use of this register and so making the
;          code require 1 more CPU cycle.
         
                                        ;
RAND31:                                 ; 
                                        ; W0 = 16807 = 7^5.
        mov     #16807, W0              ;
                                        ; W12 points to RAND31H to save
                                        ; a cycle loading the high and low
                                        ; parts of the seed.  Alternatively
                                        ; don't use W12 and instead use:
                                        ;
                                        ;                       ; Calculate hi.
                                        ; mov     RAND31H, W1   ;
                                        ; mul.uu  W0, W1, W2    ;
                                        ;                       ; Calculate lo.
                                        ; mov     RAND31L, W1   ; 
                                        ; mul.uu  W0, W1, W0    ;
                                        ;
        mov     #RAND31H, W12           ;
                                        ; Calculate hi.
        mul.uu  W0, [W12--], W2         ;
                                        ; Calculate lo.
        mul.uu  W0, [W12], W0           ;
                                        ;
                                        ; 
                                        ; W3-W2 = 00pp pppp pppp pppp  pqqq qqqq qqqq qqqq 
                                        ;
                                        ; We need to get W3 to the state of:
                                        ; 
                                        ;         0ppp pppp pppp pppp 
                                        ; 
                                        ; Shift left W2 to put its 'p' bit
                                        ; into the carry bit.
        sl      W2, W2                  ;
                                        ; W2 =   qqqq qqqq qqqq qqq0
                                        ;
                                        ; Now Rotate Left with Carry W3 to get
                                        ; that p bit into bit 0.
        rlc     W3, W3                  ;
                                        ; W3 =   0ppp pppp pppp pppp 
                                        ;
                                        ; Restore W2 with 0 in bit 15.
        lsr     W2, W2                  ;
                                        ; W2 =   0qqq qqqq qqqq qqqq
                                        ;
                                        ; Add with carry W3 into W0.  This may
                                        ; set the carry bit.  We must propagate 
                                        ; the carry bit into W1.
        addc    W0, W3, W0              ; 
                                        ;
                                        ; Propagate the carry into W1 with an
                                        ; addc whilst also adding in W2. This 
                                        ; may set bit 15, but it won't 
                                        ; overflow into the carry bit.
        addc    W2, W1, W1              ;
                                        ;
                                        ; We need to do a mod(0x7FFFFFF) on 
                                        ; this.
                                        ;
                                        ; (Note that this is really a test 
                                        ;  for < 0x7FFFFFFF rather than 
                                        ;  <= 0x7FFFFFFF.  However, the 
                                        ;  sequence contains numbers only up 
                                        ;  to 0x7FFFFFFE.)  
                                        ;       
                                        ; If this propagation of carry sets 
                                        ; bit 31 of lo (W1 bit 15) then the 
                                        ; result has exceeded 0x7FFFFFFF and 
                                        ; we need to subtract 0x7FFFFFFF by 
                                        ; clearing that bit (like subtracting 
                                        ; 0x8000000), and incrementing W1-W0.
                                        ;
                                        ; Detect this condition by the N flag
                                        ; which will be set if bit 15 of W1 is
                                        ; set.  75% of the time, the N flag 
                                        ; is clear, so we want to make that
                                        ; path of execution as short as .
                                        ; possible.  The way to do this is
                                        ; have one set of exit code here, and
                                        ; the same instructions following the 
                                        ; code which handles the overflow.
                                        ;
                                        ; 9 CPU cycles so far, not counting
                                        ; call instruction.
        bra     N, RAND31C              ;
                                        ; Store the result to RAND31H and
                                        ; RAND31L.  Leave results in W1 - W0 
                                        ; for the calling code to use.
        mov     W1, RAND31H             ;
        mov     W0, RAND31L             ;
        return                          ;
                                        ;
                                        ; 75% of the time, the N flag is 
                                        ; clear, so there is 1 cycle for the 
                                        ; bra instruction, 2 more for the 
                                        ; next two instructions and 3 cycles 
                                        ; for the return.
                                        ;
                                        ; 25% of the time, the N flag is 
                                        ; set, so the bra has 2 cycles, plus 
                                        ; 5 cycles for the first five 
                                        ; instructions at RAND31C plus 3 for
                                        ; the return.  
                                        ;
                                        ; On average, this is:
                                        ;
                                        ;    (0.75 * 6) + (0.25 * 10) 
                                        ; =   4.5       +  2.5
                                        ; =   7 cycles on average. 
                                        ;
                                        ; This is 16 cycles on average, plus
                                        ; 2 for the call = 18 CPU cycles 
                                        ; total subroutine call overhead.
                                        ;
RAND31C:                                ;
                                        ; Subtract 0x7FFFFFFF from the result
                                        ; by clearing bit 31 (like subtracting
                                        ; or adding 0x80000000) and then 
                                        ; adding 1.
        bclr    W1, #15                 ;
        inc     W0, W0                  ; 
        addc    #0, W1                  ;
                                        ; Store the result to RAND31H and
                                        ; RAND31L.  Leave results in W1 - W0 
                                        ; for the calling code to use.
        mov     W1, RAND31H             ;
        mov     W0, RAND31L             ;
        return                          ;
                                        ;
                                        ;
                                        ; --------------------------------