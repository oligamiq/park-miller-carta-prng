#[allow(unused_assignments)]

/// C API for interfacing with the Rust implementation.
///
/// Be mindful of the `unsafe` functions.
pub mod c_api {
    use PRNG;
    use std::ptr;

    #[no_mangle]
    pub extern "C" fn prng_new(seed: u64) -> *mut PRNG {
        Box::into_raw(Box::new(PRNG::new(seed)))
    }

    #[no_mangle]
    pub unsafe extern "C" fn prng_destroy(mut ptr: *mut PRNG) {
        if ptr.is_null() {
            return;
        }
        Box::from_raw(ptr);
        ptr = ptr::null_mut();
    }

    #[no_mangle]
    pub unsafe extern "C" fn next_unsigned_integer(ptr: *mut PRNG) -> u64 {
        let prng = {
            assert!(!ptr.is_null());
            &mut *ptr
        };

        prng.next_unsigned_integer()
    }
    #[no_mangle]
    pub unsafe extern "C" fn next_unsigned_float(ptr: *mut PRNG) -> f32 {
        let prng = {
            assert!(!ptr.is_null());
            &mut *ptr
        };

        prng.next_unsigned_float()
    }
}
