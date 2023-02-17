use std::env;
use std::io;
use thu2rcc::crack_hashes;

fn print_help() {
    println!("Usage: thu2rcc <hash_list> <cheat_list>");
    println!("\thash_list: Each line in the hash list should represent a c1, c2 hash pair in '0x00c16f4b,0xaa6fae66' format");
    println!("\tcheat_list: Each line in the cheat list should be a candidate cheat code to check");
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() == 3 {
        let hash_list = &args[1];
        let cheat_list = &args[2];
        crack_hashes(cheat_list, hash_list);
    } else {
        print_help();
    }

    Ok(())
}