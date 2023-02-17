use std::{
    fs::File,
    io::{prelude::*, BufReader},
    path::Path,
    time::SystemTime,
    collections::HashSet,
};
use colored::Colorize;
use rayon::prelude::*;

/// Calculates the hashes for a given cheat string
/// 
/// For example, `calc_hash("birdman")` will return (`0x07d8f451`, `0x0d442a0b`) (as u32s)
pub fn calc_hash(cheat_string: String) -> (u32, u32) {
    let mut obfuscated_cheat_string: [u8; 20] = [b'1', b'2', b'3', b'4', b'5', b'6', b'7', b'8', b'9', b'0', b'1', b'2', b'3', b'4', b'5', b'6', b'7', b'8', b'9', b'0'];
    let mut cheat_string_crc: i32 = !crc32fast::hash(cheat_string.as_bytes()) as i32;
    let mut accumulator: u32 = 0;
    let mut new_crc: i32;
    let mut new_crc_str: String;
    let mut new_crc_str_len: usize = 0;

    for i in 0..100_000 {
        // Re-uppercase obfuscated cheat string
        for i in new_crc_str_len..20 {
            if obfuscated_cheat_string[i] == 'x' as u8 {
                obfuscated_cheat_string[i] = 'X' as u8;
            }
        }

        new_crc = cheat_string_crc + i;
        new_crc_str = new_crc.to_string();
        new_crc_str_len = new_crc_str.len();
        
        let new_crc_bytes = new_crc_str.as_bytes();
        for (j, &b) in new_crc_bytes.iter().enumerate() {
            obfuscated_cheat_string[j] = b;
            accumulator += (b as u32) * 0x3ff;
        }

        obfuscated_cheat_string[new_crc_str_len] = b'X';

        for &char in &obfuscated_cheat_string[new_crc_str_len..] {
            accumulator += (char as u32) * 0x3ff;
        }

        // Lowercase obfuscated cheat string before hash is computed
        for i in new_crc_str_len..20 {
            if obfuscated_cheat_string[i] == 'X' as u8 {
                obfuscated_cheat_string[i] = 'x' as u8;
            }
        }

        cheat_string_crc = !crc32fast::hash(&obfuscated_cheat_string) as i32;
    }
    let c1 = !crc32fast::hash(&cheat_string.as_bytes()[cheat_string.len() / 3..]) ^ accumulator;
    let c2 = !crc32fast::hash(&obfuscated_cheat_string) ^ accumulator;

    return (c1, c2);
}

/// Checks a single candidate cheat code against a list of known cheat hashes
pub fn check_single_cheat(cheat: String, hash_set: &HashSet<String>) {
    // Calculate checksum for this cheat
    let (c1, c2) = calc_hash(cheat.to_string());
    let hash_string: String = format!("{:#010x},{:#010x}", c1, c2);

    // Check for matches...
    if hash_set.contains(&hash_string) {
        println!("Found a cheat! {} ({})", cheat.bold().green(), hash_string);
    }
}

/// Hashes a list of candidate cheat codes and checks them against a list of known cheat hashes
pub fn crack_hashes(cheat_list: &String, hash_list: &String) {
    println!("Cheat List: {}", cheat_list);
    println!("Hash List: {}", hash_list);

    // Build up hash set
    let hash_list_entries = lines_from_file(hash_list);
    let mut hash_set = HashSet::new();
    for hash in hash_list_entries {
        hash_set.insert(hash);
    }

    // Load candidate cheats
    let candidate_cheats = lines_from_file(cheat_list);

    // Establish global thread pool
    let num_cores: usize = std::thread::available_parallelism().unwrap().get();
    rayon::ThreadPoolBuilder::new().num_threads(num_cores).build_global().unwrap();

    println!("Starting to crack using {} cores", num_cores);
    
    let now = SystemTime::now();
    candidate_cheats.par_iter().for_each(|cheat| {
        check_single_cheat(cheat.to_string(), &hash_set);
    });

    // Print time info
    let elapsed_ms = now.elapsed().unwrap().as_millis();
    let time_per_thousand = elapsed_ms as f64 / candidate_cheats.len() as f64;
    println!("Took {:.4} seconds (That's {:.4} seconds per 1,000 hashes)", elapsed_ms as f64 / 1000.0, time_per_thousand);
}

/// Reads a file into a list of lines
/// 
/// Taken from https://stackoverflow.com/a/35820003
pub fn lines_from_file(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}