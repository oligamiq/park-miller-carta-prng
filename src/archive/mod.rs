#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

pub mod bindings;


#[cfg(test)]
mod data_race {
  use std::{thread, time};
  use archive::bindings::*;

  #[test]
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

    let race = expected_sequence.iter()
      .map(|number| {
        thread::sleep(ten_ms);
        let current_u64 = unsafe {rand31pmc_next()};
        *number == current_u64
      }).any(|result| result == false);

    assert!(race);
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

    unsafe { rand31pmc_seedi(1); }

    let ten_ms = time::Duration::from_millis(10);

    let race = expected_sequence.iter()
      .map(|number| {
        thread::sleep(ten_ms);
        let current_f32 = unsafe {rand31pmc_ranf()};
        *number == current_f32
      }).any(|result| result == false);

    assert!(race);
  }
}