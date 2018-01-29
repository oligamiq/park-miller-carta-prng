/* rand31-park-miller-carta-int.c          Version 1.00  2005 September 21
 *
 * Robin Whittle  rw@firstpr.com.au
 *
 * Double-precision floating point implementation of the Park Miller
 * "minimal standard" linear congruential pseudo-random number 
 * generator.
 *
 * This file and its .h file is intended to be used in other projects.
 *
 * The accompanying files rand31-park-miller-carta-int.c/h have a fast 
 * implementation of the Park Miller (1988) linear congruential 
 * pseudo-random number generator, using David G. Carta's optimisation
 * which needs only 32 bit integer math, and no division.
 *
 * A test program enables the speed of each approach to be tested by
 * making each one run through the entire pseudo-random sequence once:
 *
 *   rand31-park-miller-carta-c-test.c 
 *
 * On an 800MHz Pentium III, with GCC and no optimisations, the integer
 * version produced 13 million results a second, running in a simple
 * test loop, and the floating point version produced 3.6 million.
 * 
 * C++ versions are also available.
 *
 * References:
 *
 *    Stephen K. Park and Keith W. Miller 
 *    Random Number Generators: Good Ones are Hard to Find
 *    Communications of the ACM, Oct 1988, Vol 31 Number 10 1192-1201
 *
 *       Like the other two papers, this one is normally only available
 *       from the ACM site via subscription.  You should be able to
 *       access this paper electronically or in print at a university
 *       library.  You may also be able to find the .PDF wild on the
 *       Net.  Search for "p1192-park.pdf".  For instance:
 *
 *         http://www-scf.usc.edu/~csci105/links/p1192-park.pdf     
 *
 *    David F. Carta
 *    Two Fast Implementations of the "Minimal Standard" Random Number Generator
 *    Communications of the ACM, Jan 1990, Vol 33 Number 1 87-88  (p87-carta.pdf)
 *
 *    George Marsaglia; Stephen J. Sullivan; Stephen K. Park, Keith W. Miller, 
 *    Paul K. Stockmeyer
 *    Remarks on Choosing and Implementing Random Number Generators 
 *    Communications of the ACM, Jul 1993, Vol 36 Number 7 105-110 (p105-crawford.pdf)
 *
 * The following code is public domain.  If you use this code, I request that 
 * you keep the comments with it, to save some poor soul from having to figure 
 * out the history behind it.  If you use a PRNG, you should research its
 * pedigree.
 *
 * Copyright public domain  Robin Whittle 2005
 *
 * For a full explanation, latest updates and the history of these
 * algorithms, see:
 *   
 *    http://www.firstpr.com.au/dsp/rand31/
 *
 * When compiling into the test program I use:
 *
 *  gcc rand31-park-miller-carta-c-test.c  -o rand31-pmc-c-test -lm
 *
 * The -lm was necessary to stop the compiler complaining about fmod.
 * 
 */

#include "rand31-park-miller-fp.h"
#include <math.h>


                                    /* rand31pm_next()
                                     *
                                     * 31 bit Pseudo Random Number Generator 
                                     * based on Park Miller "Integer 
                                     * Version 1" - but done with double-
                                     * precision floating point so we are not 
                                     * concerned with the limits of integer 
                                     * operations.  This is not intended for 
                                     * fast operation - but maybe it is 
                                     * faster than the integer implementation
                                     * on some CPUs.
                                     *
                                     * Generate next pseudo random number.
                                     *                                  
                                     * Multiplier constant = 16807 = 7^5.  
                                     * This is 15 bits.
                                     *
                                     * Park and Miller in 1993 recommend
                                     * 48271, which they say produces a 
                                     * somewhat better quality of 
                                     * pseudo-random results.  
                                     */
                                    
    #define constapm 16807          
/*  #define constapm 48271  
 */
                                    /* Modulus constant = 2^31 - 1 =
                                     * 0x7FFFFFFFF.  Use .0 to deter compiler
                                     * from complaining about a very large 
                                     * integer constant.    
                                     */
    #define constmpm 2147483647.0       
                                            
                                     
                                            
long unsigned int rand31pm_next()
{
    double const a = constapm;
    double const m = constmpm;
                                    /* This is the linear congrentual 
                                     * generator:
                                     *  
                                     * Multiply the old seed by constant a 
                                     * and take the modulus of the result 
                                     * (the remainder of a division) by 
                                     * constant m.
                                     */
                                    
    return (seed31pm = (long)(fmod((seed31pm * a), m)) );
}



/*---------------------------------------------------------------------------*/

                                    /* rand31pm_seedi()
                                     *
                                     * Set the seed from a long unsigned 
                                     * integer.  If zero is used, then
                                     * the seed will be set to 1.
                                     */
                                                                        
void rand31pm_seedi(long unsigned int seedin)
{
    if (seedin == 0) seedin = 1;
    seed31pm = seedin;
}
                                    
                                    /* rand31pm_ranlui()
                                     *
                                     * Return next pseudo-random value as
                                     * a long unsigned integer.
                                     */
                                    
long unsigned int rand31pm_ranlui(void)  
{
    return rand31pm_next();
}

                                    /* rand31pm_ranf()
                                     *
                                     * Return next pseudo-random value as
                                     * a floating point value.
                                     */

float rand31pm_ranf(void)  
{
    return (rand31pm_next() / 2147483647.0 );
}




