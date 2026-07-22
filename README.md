# Tony Hawk's Underground 2 Cheat Cracker

A GPU-accelerated utility for cracking cheat codes for Tony Hawk's Underground 2, written in C++ and CUDA.

## Background

This project started after some discoveries while reverse engineering Tony Hawk's Underground 2: Remix (the PSP port of the game). I was interested in how the game checked to see if a cheat code the user entered was valid, and found that unlike many other games, the game didn't just do a string comparison with a list of cheat code strings. Instead, it performs a series of repeated CRC32 calculations on the input cheat string **100,000** times, calculating a sort of hash for each cheat code.

Digging deeper, I was able to find a list of all available cheat "hashes" specified within one of the game's scripts. The hashes are present within the script `levels/mainmenu/mainmenu_scripts.qb`, which can be found by extracting the `datap.wad` game archive. To extract the archive, I used [a QuickBMS script](https://aluigi.altervista.org/bms/thps_hed_wad.bms), and to parse the script, I used [a decompiler I found online](http://thmods.com/forum/viewtopic.php?t=835). **Please note** that because those tools are not mine, I can make no guarantees about their safety!

In addition to the PSP cheat hashes, this script also contained a table of hashes for the other versions of the game (PS2, Xbox, and GameCube). I noticed that the number of cheats within these tables was much larger than the number of documented cheat codes for any of the versions of the game, and was naturally curious what these undocumented cheat codes could be. So, I made this utility to attempt to uncover the rest!

To crack these cheat code hashes, the project has evolved through three iterations:

1. **Python**: The initial implementation served as a proof of concept, but pure Python was far too slow to make large-scale dictionary cracking practical due to performing 100,000 CRC32 iterations per candidate word.
2. **Rust (Multi-threaded CPU)**: Re-implemented in Rust using Rayon for multi-core CPU parallelism, drastically improving performance over Python and enabling initial dictionary attacks.
3. **CUDA C++ (GPU Acceleration)**: Ported to CUDA C++ to run across thousands of GPU cores in parallel. This CUDA version provides **dramatic, orders-of-magnitude speedups** over both the Python and multi-threaded Rust CPU versions, reducing crack times for thousands of candidates down to sub-second durations.

## Findings (So Far)

Using this utility, I've managed to discover a number of previously undocumented cheat codes for various versions of Tony Hawk's Underground 2. Any cheats bolded & italicized were previously undocumented (as far as I can tell).

A very special thanks to **[naomshi](https://github.com/naomshi)**, **[moddedBear](https://github.com/moddedBear)**, **[LudiCruz-Liam](https://github.com/LudiCruz-Liam)**, and **[violetvandal](https://github.com/violetvandal)** for finding additional codes and hashes which have been added to this list 😊

| Cheat                            | PS2              | PSP              | Xbox / PC        | Gamecube        |
|----------------------------------|------------------|------------------|------------------|-----------------|
| Always Special                   | likepaulie       |                  | likepaulie       | likepaulie      |
| Perfect Rail                     |                  | tightrope        |                  |                 |
| Perfect Skitch                   |                  |                  |                  |                 |
| Perfect Manual                   |                  |                  |                  |                 |
| Moon Gravity                     |                  | ***m00nraker***  |                  |                 |
| Unlock Pedestrian Group A        | ***cyberfans***  |                  | ***cyberfans***  | ***cyberfans*** |
| Unlock Pedestrian Group B        |                  |                  |                  |                 |
| Unlock Pedestrian Group C        | ***love2hate***  | ***hate2love***  | ***love2hate***  | ***love2hate*** |
| Unlock Pedestrian Group D        | ***fruitboot***  | ***gumdrops***   | ***fruitboot***  | ***fruitboot*** |
| Unlock Pedestrian Group E        |                  |                  |                  |                 |
| Unlock Pedestrian Group F        |                  | ***bratpak***    |                  |                 |
| Unlock Pedestrian Group G        |                  | ***evenmore***   | ***wdtboys***    |                 |
| Unlock Pedestrian Group H        |                  |                  |                  |                 |
| Unlock Shrek                     | ***greenguy***   | ***nevertold***  | ***farfaraway*** | ***greenguy***  |
| Unlock C.O.D. Soldier            | ***2infinity***  | ***dogtags***    | ***lockstock***  | ***foxhole***   |
| Unlock Phil Margera              | aprilsman        | ***tirejack***   | notvito          | xxlarge         |
| Unlock The Hand                  | ***5fingers***   | ***hangloose***  | ***dabird***     | ***5knuckles*** |
| Unlock Paulie Ryan               | ***mrmouth***    | ***spittle***    | 4wheeler         | ***whoopin***   |
| Unlock Nigel Beaverhausen        | sellout          | ***tigerthong*** | skullet          | ***britteeth*** |
| Unlock Steve-O                   |                  | ***jackazz***    | ***staplegun***  | ***wildman***   |
| Unlock Jesse James               | ***wcchoppers*** | ***mongarage***  | ***payups***     | ***outlaw***    |
| Unlock THPS1 Tony Hawk           | ***original1***  | birdman          | ***firstborn***  | ***retro1***    |
| Unlock Natas Kaupas              | oldskool         |                  | bedizzy          | unscrewed       |
| Unlock Nick Kang (PC Exclusive)  | N/A              | N/A              | ***nicknow***    | N/A             |
| Unlock Price (PC Exclusive)      | N/A              | N/A              | ***pricenow***   | N/A             |
| Unlock all Movies                | boxoffice        | ***playbill***   |                  | sikflick        |
| Unlock all Levels                | d3struct         | ***w0rldt0ur***  |                  | urown3d         |
| Unlock all Story Mode Characters | costars!         |                  | ***xtrahelp***   | wakpak          |
| Unlock all Cheat Codes           |                  |                  |                  |                 |
| Select Shift (Unknown Effect)    |                  |                  |                  |                 |
| SCE Patchtest (Unknown Effect)   |                  |                  | N/A              | N/A             |

## Prerequisites

* **NVIDIA GPU** with CUDA support
* **NVIDIA CUDA Toolkit** (includes `nvcc`)
* **Host C++ Compiler** (Microsoft Visual Studio MSVC `cl.exe` on Windows, or `g++` on Linux)

## Building

### Option 1: Using `nvcc` directly

On Windows (using PowerShell or Command Prompt):
```cmd
build.bat
```
or manually with `nvcc`:
```powershell
$env:Path = 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.38.33130\bin\Hostx64\x64;' + $env:Path
nvcc -O3 src/cheat_cracker.cu -o thu2rcc.exe
```

On Linux:
```bash
nvcc -O3 src/cheat_cracker.cu -o thu2rcc
```

### Option 2: Using CMake

```bash
mkdir build
cd build
cmake ..
cmake --build . --config Release
```

## Running

Run on the command line, passing two mandatory arguments for the list of cheat hashes and the wordlist to use like so: `thu2rcc <hash_list.txt> <wordlist.txt>`.

* **Hash List**: Each line within your hash list should represent a c1, c2 hash pair in *EXACTLY* `0x00c16f4b,0xaa6fae66` format (note the lowercase hex digits and consistent 8-character hex formatting). A list of cheat hashes taken from the PSP copy of the game is provided within [`data/cheat_hash_list.txt`](data/cheat_hash_list.txt). You can determine what cheat each hash corresponds to by referencing [`data/annotated_cheat_hashes.txt`](data/annotated_cheat_hashes.txt).
* **Wordlist**: Each line within your word list should be a candidate cheat code you'd like to check against the list of known hashes. A list of known cheat codes is provided within [`data/known_cheats.txt`](data/known_cheats.txt). Worth noting that all cheat codes must be >= 6 characters long, so it is recommended to remove candidate cheats shorter than 6 characters to avoid checking impossible cheats.

### Sample Execution

```console
> thu2rcc.exe .\data\complete_hash_list.txt .\data\some_wordlist.txt
Hash List: .\data\complete_hash_list.txt
Cheat List: .\data\some_wordlist.txt
Starting to crack using CUDA GPU acceleration...
Found a cheat! 5fingers (0xdb562768,0x9899aa08)
Took 75.5568 seconds (That's 0.0457 seconds per 1,000 hashes)
```

*Note: The sample stats shown above are based on running locally on an NVIDIA GeForce GTX 1060. Execution time will vary depending on your GPU architecture and size of the wordlist.*

## Contributing

I'm very interested to hear if anyone else is able to find further codes that work for the game. If you find more cheats that aren't yet in my table, let me know, and I'll be happy to add them and give you credit for your discovery! 😊
