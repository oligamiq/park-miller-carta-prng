/* rand31-park-miller-carta-c-test.c          Version 1.00  2005 September 19
 *
 * Compile with the GCC C compiler:
 * 
 *   * Compile with GCC:   
 * 
 *  gcc rand31-park-miller-carta-c-test.c  -o rand31-pmc-c-test -lm
 *
 *  (On my system I needed the -lm incantation to make the compiler 
 *   work with fmod(), which is used in the floating point implementation.)
 *
 * This cycles the integer generator through an entire sequence of 2^31-1 
 * results, printing a few of them to the console.  See instructions in the 
 * printf text below.
 *
 * This program can also be used to cycle either generator through its
 * entire sequence, in a tight loop looking for a result of 1, so that
 * the speed of operation can be calculated from the total time elapsed.
 *
 * Here is a shell script to log the start and end times to a file:
 *
 *    OUTFILE=rand31-pmc-c-test-timing.txt 
 *    echo Begin test Park-Miller-Carta integer generator >> $OUTFILE
 *    date >> $OUTFILE
 *    ./rand31-pmc-c-test PMC
 *    date >> $OUTFILE
 *    echo Begin test Park-Miller floating point generator >> $OUTFILE
 *    date >> $OUTFILE
 *    ./rand31-pmc-c-test PM
 *    date >> $OUTFILE
 */

#include <stdio.h>
#include "rand31-park-miller-carta-int.c"
#include "rand31-park-miller-fp.c"

main (int argc, char *argv[])
{
                                    /* 32 bit unsigned integer
                                     * to store new pseudo-random number.
                                     */
    long unsigned int test1, test2;

    long unsigned int loopcount;
    
                                    /* Set the seed of each generator to 1.
                                     */
    rand31pmc_seedi(1);
    rand31pm_seedi(1);
    
    
    printf("\nCycling through the entire sequence of a Park Miller PRNG using a multiplier of\n");
    printf(  "16807 and a modulus of 2^31 - 1.  Faster, 32 bit math, no division implementation\n");
    printf(  "by Robin Whittle http://www.firstpr.com.au/dsp/rand31/ based on David G. Carta's\n");
    printf(  "1990 paper.\n");
    printf(  "\n");
    printf(  "Run with a command line option PMC to benchmark the speed of running just the generator\n");
    printf(  "in a tight loop, for its entire 2,147,483,646 word sequence length, without display code.\n");
    printf(  "This takes around 165 seconds on an 800MHz Pentium III.\n\n");
    printf(  "To test the speed of a standard Park Miller generator, written in floating point,\n");
    printf(  "run with the command line option PM.\n\n");
        
    
                                    /* Command line = PMC
                                     *
                                     * Do a fast loop with the Park-Miller-Carta
                                     * generator for the entire sequence without 
                                     * display.  
                                     */
    if (   (argc == 2)
         &&( strncmp(argv[1], "PMC") == 0 )
       )
    
                                    /*****************************************/
    {
        printf("\nBegin benchmark run of full sequence of 2,147,483,646 "); 
        printf(  "pseudorandom numbers with integer Park-Miller-Carta generator.\n"); 
        
        while (rand31pmc_ranlui() != 1);
        
        printf("\nDone.\n"); 
    }
                                    /*****************************************/
    
    else

    if (   (argc == 2)
         &&( strncmp(argv[1], "PM") == 0 )
       )
    
                                    /*****************************************/
    {
        printf("\nBegin benchmark run of full sequence of 2,147,483,646 "); 
        printf(  "pseudorandom numbers with floating point Park-Miller generator.\n"); 
        
        while (rand31pm_ranlui() != 1);
        
        printf("\nDone.\n"); 
    }
                                    /*****************************************/

    
    else

                                    /*****************************************/
    {
                                    /* Run the loop so it goes just a few 
                                     * more than the full 2^32 - 1 = 
                                     * 2,147,483,646 cycles.
                                     *
                                     * We regard the decimal constant below:
                                     * 
                                     *    2147483655.0  
                                     * 
                                     * as an unsigned integer.  Since it is
                                     * above 2^31 (the limit of a signed 32 bit
                                     * integer) the compiler would issue a 
                                     * warning.  By placing ".0" after it, 
                                     * the compiler sees it as a floating
                                     * point constant is generates no warning.
                                     * We make it into an unsigned integer 
                                     * with "(unsigned)".
                                     */
        rand31pmc_seedi(1);
    
        for(loopcount = 1; loopcount < (unsigned)2147483655.0; loopcount++)
        {
                                    // Get a new value from the generator.
            test1 = rand31pmc_ranlui(); 
        
            if(loopcount ==       9997)
            {
                printf("\nFor a = 16807, the 10000th value after a seed of 1 should be 1043618065\n");
                printf(  "as predicted by Park and Miller, 1988, page 1195.\n\n");
            }
            else
                                    // Display:
                                    // 
                                    //     The first 10 results.
                                    //  or The last 15 or so results.
                                    //  or Results 9998 to 10002.
                                    //  or Every millionth pair of results.

            if(   (loopcount     <=                   10)
                ||(loopcount     >= (unsigned)2147483640)
                ||(   (loopcount >=                 9998)
                    &&(loopcount <=                10002) 
                  ) 
                ||((loopcount % 1000000) == 0)
              )
            {
                printf("%u     loopcount = %u\n", test1, loopcount);
            }
        
        } 
                                    /*****************************************/
    
    }
    return 0;
}
