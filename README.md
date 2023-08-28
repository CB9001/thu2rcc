# Tony Hawk's Underground 2 Cheat Cracker

A simple utility for cracking cheat codes for Tony Hawk's Underground 2, written in Rust.

## Background

This project started after some discoveries while reverse engineering Tony Hawk's Underground 2: Remix (the PSP port of the game). I was interested in how the game checked to see if a cheat code the user entered was valid, and found that unlike many other games, the game didn't just do a string comparison with a list of cheat code strings. Instead, it performs a series of repeated CRC32 calculations on the input cheat string **100,000** times, calculating a sort of hash for each cheat code.

Digging deeper, I was able to find a list of all available cheat "hashes" specified within one of the game's scripts. The hashes are present within the script `levels/mainmenu/mainmenu_scripts.qb`, which can be found by extracting the `datap.wad` game archive. To extract the archive, I used [a QuickBMS script](https://aluigi.altervista.org/bms/thps_hed_wad.bms), and to parse the script, I used [a decompiler I found online](http://thmods.com/forum/viewtopic.php?t=835). **Please note** that because those tools are not mine, I can make no guarantees about their safety!

In addition to the PSP cheat hashes, this script also contained a table of hashes for the other versions of the game (PS2, Xbox, and GameCube). I noticed that the number of cheats within these tables was much larger than the number of documented cheat codes for any of the versions of the game, and was naturally curious what these undocumented cheat codes could be. So, I made this utility to attempt to uncover the rest!

To crack these cheat code hashes, I re-implemented the cheat hashing algorithm in Rust (I first wrote an implementation in Python, but it proved to be waaaay too slow to make it practical for cracking purposes).

## Findings (So Far)

Using this utility, I've managed to discover a number of previously undocumented cheat codes for various versions of Tony Hawk's Underground 2. Any cheats bolded & italicized were previously undocumented (as far as I can tell).

| Cheat                            | PS2             | PSP              | Xbox             | Gamecube        |
|----------------------------------|-----------------|------------------|------------------|-----------------|
| Always Special                   | likepaulie      |                  | likepaulie       | likepaulie      |
| Perfect Rail                     |                 | tightrope        |                  |                 |
| Perfect Skitch                   |                 |                  |                  |                 |
| Perfect Manual                   |                 |                  |                  |                 |
| Moon Gravity                     |                 | ***m00nraker***  |                  |                 |
| Unlock Pedestrian Group A        |                 |                  |                  |                 |
| Unlock Pedestrian Group B        |                 |                  |                  |                 |
| Unlock Pedestrian Group C        | ***love2hate*** | ***hate2love***  | ***love2hate***  | ***love2hate*** |
| Unlock Pedestrian Group D        | ***fruitboot*** | ***gumdrops***   | ***fruitboot***  | ***fruitboot*** |
| Unlock Pedestrian Group E        |                 |                  |                  |                 |
| Unlock Pedestrian Group F        |                 | ***bratpak***    |                  |                 |
| Unlock Pedestrian Group G        |                 | ***evenmore***   |                  |                 |
| Unlock Pedestrian Group H        |                 |                  |                  |                 |
| Unlock Shrek                     | ***greenguy***  | ***nevertold***  | ***farfaraway*** |                 |
| Unlock C.O.D. Soldier            | ***2infinity*** | ***dogtags***    | ***lockstock***  | ***foxhole***   |
| Unlock Phil Margera              | aprilsman       | ***tirejack***   | notvito          | xxlarge         |
| Unlock The Hand                  | ***5fingers***  | ***hangloose***  | ***dabird***     | ***5knuckles*** |
| Unlock Paulie Ryan               |                 | ***spittle***    | 4wheeler         |                 |
| Unlock Nigel Beaverhausen        | sellout         | ***tigerthong*** | skullet          |                 |
| Unlock Steve-O                   |                 | ***jackazz***    | ***staplegun***  | ***wildman***   |
| Unlock Jesse James               |                 |                  | ***payups***     | ***outlaw***    |
| Unlock THPS1 Tony Hawk           | ***original1*** | birdman          | ***firstborn***  | ***retro1***    |
| Unlock Natas Kaupas              | oldskool        |                  | bedizzy          | unscrewed       |
| Unlock all Movies                | boxoffice       | ***playbill***   |                  | sikflick        |
| Unlock all Levels                | d3struct        | ***w0rldt0ur***  |                  | urown3d         |
| Unlock all Story Mode Characters | costars!        |                  |                  | wakpak          |
| Unlock all Cheat Codes           |                 |                  |                  |                 |
| Select Shift (Unknown Effect)    |                 |                  |                  |                 |
| SCE Patchtest (Unknown Effect)   |                 |                  | N/A              | N/A             |

## Building

Build using `cargo build -r`. The resulting executable will be placed within `target/release`.

## Running

Run on the command line, passing two mandatory arguments for the list of cheat hashes and the wordlist to use like so: `thu2rcc <hash_list.txt> <wordlist.txt>`.

* **Hash List**: Each line within your hash list should should represent a c1, c2 hash pair in *EXACTLY* `0x00c16f4b,0xaa6fae66` format (note the lowercase hex digits and the consistent 4-byte formatting). A list of cheat hashes taken from the PSP copy of the game is provided within [`data/cheat_hash_list.txt`](data/cheat_hash_list.txt). You can determine what cheat each hash corresponds to by referencing [`data/annotated_cheat_hashes.txt`](data/annotated_cheat_hashes.txt).
* **Wordlist**: Each line within your word list should be a candidate cheat code you'd like to check against the list of known hashes. A list of known cheat codes is provided within [`data/known_cheats.txt`](data/known_cheats.txt). Worth noting that all cheat codes must be >=  6 characters long, so might be worth removing any candidate cheats shorter than this before running the program to avoid checking for impossible cheats.

### Sample Execution

```console
> thu2rcc.exe data\cheat_hash_list.txt data\some_wordlist.txt
Cheat List: data\some_wordlist.txt
Hash List: data\cheat_hash_list.txt
Starting to crack using 4 cores
Found a cheat! birdman (0x07d8f451,0x0d442a0b)
Found a cheat! retro1 (0x7e32e340,0x37a7146c)
Took 92.9150 seconds (That's 6.5636 seconds per 1,000 hashes)
```

*Note that execution time will vary greatly depending on your machine (number of cores, what other processes are running, etc.)*

## Contributing

I'm very interested to hear if anyone else is able to find further codes that work for the game. If you find more cheats that aren't yet in my table, let me know, and I'll be happy to add them and give you credit for your discovery!

This project was my first attempt at learning and writing Rust. As such, I'm positive that there are improvements that can be made to make my code run faster - I'm super open to feedback and criticism on the code 😊

I'd imagine there's also a GPU accelerated approach to cracking these hashes that could provide a great deal of speedup, but that exceeds my current expertise, so let me know if you have ideas on how a GPU assisted version of this utility might look!
