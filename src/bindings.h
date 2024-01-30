#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

constexpr static const unsigned long seed31pmc = 1;

/// The `PRNG` struct is a re-implemention of the C library
struct PRNG;

extern "C" {

extern unsigned long rand31pmc_next();

extern void rand31pmc_seedi(unsigned long arg1);

extern unsigned long rand31pmc_ranlui();

extern float rand31pmc_ranf();

PRNG *prng_new(uint32_t seed);

void prng_destroy(PRNG *ptr);

uint32_t next_unsigned_integer(PRNG *ptr);

float next_unsigned_float(PRNG *ptr);

} // extern "C"
