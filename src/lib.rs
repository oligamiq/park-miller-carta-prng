pub mod archive;

const CONSTAPMC: u16 = 16807;

pub struct PRNG {
  seed: u64
}

impl PRNG {
  pub fn new(seed: u64) -> PRNG {
    PRNG {seed: seed}
  }

  pub fn next_unsigned_integer(&mut self) -> u64 {
    let hi: u64;
    let mut lo: u64;

    lo = CONSTAPMC as u64 * (self.seed & 0xFFFF);
    hi = CONSTAPMC as u64 * (self.seed >> 16);
    lo += (hi & 0x7FFF) << 16;
    lo += hi >> 15;
    if lo > 0x7FFFFFFF { lo -= 0x7FFFFFFF; }
    self.seed = lo;
    lo
  }

  pub fn next_unsigned_float(&mut self) -> f32 {
    self.next_unsigned_integer() as f32 / 2147483647.0
  }

  pub fn current_seed(&self) -> u64 {
    self.seed
  }
}

#[cfg(test)]
mod conformance_test {
  use archive::bindings::*;
  use PRNG;

  #[test]
  fn full_period_integer_check() {
      let mut prng = PRNG::new(1);
      unsafe { rand31pmc_seedi(1); }

      for _ in 1..2147483648 as u64 {
        assert_eq!(unsafe { rand31pmc_next() }, prng.next_unsigned_integer());
      }
  }
}
