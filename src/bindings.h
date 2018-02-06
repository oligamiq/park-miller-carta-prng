#include <cstdint>
#include <cstdlib>

static const uint16_t CONSTAPMC = 16807;

static const unsigned long seed31pmc = 1;

// The `PRNG` struct is a re-implemention of the C library
struct PRNG;

extern "C" {

float next_unsigned_float(PRNG *ptr);

uint32_t next_unsigned_integer(PRNG *ptr);

void prng_destroy(PRNG *ptr);

PRNG *prng_new(uint32_t seed);

extern unsigned long rand31pmc_next();

extern float rand31pmc_ranf();

extern unsigned long rand31pmc_ranlui();

extern void rand31pmc_seedi(unsigned long arg1);

} // extern "C"
