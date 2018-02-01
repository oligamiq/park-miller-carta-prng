//! # prng
//!
//! The `prng` crate is a re-implementation of [the original Park-Miller-Carta PRNG implemented by Robin Whittle](http://www.firstpr.com.au/dsp/rand31/).
//! The original code can be found in the `archive` directory.
//!
//! A new C API is re-exported, derived from the Rust version. It can be used from C and in other platforms, e.g Node.js.
//! The C API is also used when targeting asm.js/WebAssembly.
//! For more information, visit [the repository](https://github.com/kenOfYugen/park-miller-carta-prng).
//!
//! Use this library if you require an efficient Pseudo-Random Number Generator, not recommended for cryptography.
//!
//! Test compliance with the original code by executing `cargo t --release`

/// An FFI interface to the original C implementation.
pub mod archive;

const CONSTAPMC: u16 = 16807;

/// The `PRNG` struct is a re-implemention of the C library
pub struct PRNG {
    seed: u64,
}

impl PRNG {
    /// takes a `u64` seed, and sanitizes the input for `0`
    /// # Example
    /// ```
    /// use prng::PRNG;
    /// let mut prng = PRNG::new(1);
    /// ```
    pub fn new(seed: u64) -> PRNG {
        let sanitized_seed = match seed {
            0 => 1,
            _ => seed,
        };

        PRNG {
            seed: sanitized_seed,
        }
    }
    /// generates next integer
    /// # Example
    /// ```
    /// use prng::PRNG;
    /// let mut prng = PRNG::new(1);
    /// let random_integer = prng.next_unsigned_integer();
    /// assert_eq!(16807, random_integer);
    /// ```
    pub fn next_unsigned_integer(&mut self) -> u64 {
        let hi: u64;
        let mut lo: u64;

        lo = CONSTAPMC as u64 * (self.seed & 0xFFFF);
        hi = CONSTAPMC as u64 * (self.seed >> 16);
        lo += (hi & 0x7FFF) << 16;
        lo += hi >> 15;
        if lo > 0x7FFFFFFF {
            lo -= 0x7FFFFFFF;
        }
        self.seed = lo;
        lo
    }
    /// generates next float
    /// # Example
    /// ```
    /// use prng::PRNG;
    /// let mut prng = PRNG::new(1);
    /// let random_float = prng.next_unsigned_float();
    /// assert_eq!(0.000007826369, random_float);
    /// ```
    pub fn next_unsigned_float(&mut self) -> f32 {
        self.next_unsigned_integer() as f32 / 2147483647.0
    }
    /// returns the current seed
    /// # Example
    /// ```
    /// use prng::PRNG;
    /// let mut prng = PRNG::new(1);
    /// let current_seed = prng.current_seed();
    /// assert_eq!(1, current_seed);
    /// ```
    pub fn current_seed(&self) -> u64 {
        self.seed
    }
}

/// C API derived from the Rust re-implementation.
pub mod c_api;

#[cfg(all(test, not(debug_assertions)))]
mod conformance_test {
    use archive::bindings::*;
    use PRNG;

    #[test]
    fn full_period_integer_check() {
        let mut prng = PRNG::new(1);
        unsafe {
            rand31pmc_seedi(1);
        }

        for _ in 1..2147483648 as u64 {
            assert_eq!(unsafe { rand31pmc_next() }, prng.next_unsigned_integer());
        }
    }
}

#[cfg(test)]
mod thread_safe_demonstration {
    use std::{thread, time};
    use PRNG;

    #[test]
    fn test_a_few_random_u64s() {
        let expected_sequence: [u64; 10] = [
            16807, 282475249, 1622650073, 984943658, 1144108930, 470211272, 101027544, 1457850878,
            1458777923, 2007237709,
        ];

        let mut prng = PRNG::new(1);

        let ten_ms = time::Duration::from_millis(10);

        expected_sequence.iter().for_each(|number| {
            thread::sleep(ten_ms);
            let current_u64 = prng.next_unsigned_integer();
            assert_eq!(*number, current_u64);
        });
    }

    #[test]
    fn test_a_few_random_f32s() {
        let expected_sequence: [f32; 10] = [
            0.000007826369,
            0.1315378,
            0.75560534,
            0.45865014,
            0.53276724,
            0.21895918,
            0.047044616,
            0.6788647,
            0.67929643,
            0.9346929,
        ];

        let mut prng = PRNG::new(1);

        let ten_ms = time::Duration::from_millis(10);

        expected_sequence.iter().for_each(|number| {
            thread::sleep(ten_ms);
            let current_f32 = prng.next_unsigned_float();
            assert_eq!(*number, current_f32);
        });
    }
}
