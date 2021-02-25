#![no_main]
#![no_std]
#![feature(test)]

use core::panic::PanicInfo;

#[panic_handler]
fn panic(_panic: &PanicInfo<'_>) -> ! {
    loop {}
}

extern "C" {
    fn putchar(char: u8);
}

#[inline(never)]
fn print_s(s: &str) {
    for char in s.bytes() {
        unsafe { putchar(char) }
    }
}

#[no_mangle]
extern "C" fn _start() {
    let x = core::hint::black_box(true);
    if x {
        print_s("Hello world")
    } else {
        print_s("not that")
    };
}
