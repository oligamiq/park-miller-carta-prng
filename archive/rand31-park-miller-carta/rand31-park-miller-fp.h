/*
 * Header for rand31-park-miller-fp.c
 */ 
                                /* Function declarations
                                 */
                                 
    long unsigned int rand31pm_next(void);
    void              rand31pm_seedi(long unsigned int);
    long unsigned int rand31pm_ranlui(void);  
    float             rand31pm_ranf(void);

                                /* The sole item of state for each generator:
                                 * a 32 bit integer.
                                 *
                                 * Initialise it to 1 in case the user doesn't
                                 * call seedi().  The range of allowable values
                                 * is 1 to 2^31-1.  A seed value of 0 will cause
                                 * the generation of all zeros.
                                 */
                                 
    long unsigned int seed31pm  = 1;    
        
    
