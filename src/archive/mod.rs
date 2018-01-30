#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

mod bindings;

pub mod unsafe_ffi {
  use std::os::raw::c_ulong;
  use archive::bindings::{seed31pmc, rand31pmc_seedi, rand31pmc_next, rand31pmc_ranf};

  pub struct PRNG<'a> { seed: &'a c_ulong }

  impl<'a> PRNG<'a> {
      pub unsafe fn new(seed: c_ulong) -> PRNG<'a> {
        rand31pmc_seedi(seed);
        PRNG { seed: &seed31pmc }
      }

      pub unsafe fn next_unsigned_integer(&self) -> c_ulong {
        rand31pmc_next()
      }

      pub unsafe fn next_float(&self) -> f32 {
        rand31pmc_ranf()
      }
  }
}

#[cfg(test)]
mod safe_interface_unsafe_ffi_test_data_race {
  use archive::unsafe_ffi::PRNG;
  use std::{thread, time};

  #[test]
  #[ignore]
  #[should_panic(expected = "assertion failed")]
  fn test_a_few_random_u64s() {
    let expected_sequence: [u64; 10] = [
      16807,
      282475249,
      1622650073,
      984943658,
      1144108930,
      470211272,
      101027544,
      1457850878,
      1458777923,
      2007237709,
    ];

    let prng = unsafe {PRNG::new(1)};
    let ten_ms = time::Duration::from_millis(10);
    
    expected_sequence.iter()
      .for_each(|number| {
        thread::sleep(ten_ms);
        let current_u64 = unsafe {prng.next_unsigned_integer()};
        assert_eq!(*number, current_u64);
      });
  }

  #[test]
  #[ignore]
  #[should_panic(expected = "assertion failed")]
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

    let prng = unsafe { PRNG::new(1) };

    let ten_ms = time::Duration::from_millis(10);

    expected_sequence.iter()
      .for_each(|number| {
        thread::sleep(ten_ms);
        let current_f32 = unsafe {prng.next_float()};
        assert_eq!(*number, current_f32);
      });
  }
}

#[cfg(test)]
mod c_ffi_data_race {
  use std::{thread, time};
  use archive::bindings::*;

  #[test]
  #[ignore]
  #[should_panic(expected = "assertion failed")]
  fn test_a_few_random_u64s() {
    let expected_sequence: [u64; 10] = [
      16807,
      282475249,
      1622650073,
      984943658,
      1144108930,
      470211272,
      101027544,
      1457850878,
      1458777923,
      2007237709,
    ];

    unsafe { rand31pmc_seedi(1); }

    let ten_ms = time::Duration::from_millis(10);

    expected_sequence.iter()
      .for_each(|number| {
        thread::sleep(ten_ms);
        let current_u64 = unsafe {rand31pmc_next()};
        assert_eq!(*number, current_u64);
      });
  }

  #[test]
  #[ignore]
  #[should_panic(expected = "assertion failed")]
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

    unsafe { rand31pmc_seedi(1); }

    let ten_ms = time::Duration::from_millis(10);

    expected_sequence.iter()
      .for_each(|number| {
        thread::sleep(ten_ms);
        let current_f32 = unsafe {rand31pmc_ranf()};
        assert_eq!(*number, current_f32);
      });
  }
}