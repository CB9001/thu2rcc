# Tony Hawk's Underground 2 Cheat Cracker

A GPU-accelerated utility for cracking cheat codes for Tony Hawk's Underground 2, written in C++ and CUDA.

## Background

This project started after some discoveries while reverse engineering Tony Hawk's Underground 2: Remix (the PSP port of the game). I was interested in how the game checked to see if a cheat code the user entered was valid, and found that unlike many other games, the game didn't just do a string comparison with a list of cheat code strings. Instead, it performs a series of repeated CRC32 calculations on the input cheat string **100,000** times, calculating a sort of hash for each cheat code.

Digging deeper, I was able to find a list of all available cheat "hashes" specified within one of the game's scripts. The hashes are present within the script `levels/mainmenu/mainmenu_scripts.qb`, which can be found by extracting the `datap.wad` game archive. To extract the archive, I used [a QuickBMS script](https://aluigi.altervista.org/bms/thps_hed_wad.bms), and to parse the script, I used [a decompiler I found online](http://thmods.com/forum/viewtopic.php?t=835). **Please note** that because those tools are not mine, I can make no guarantees about their safety!

In addition to the PSP cheat hashes, this script also contained a table of hashes for the other versions of the game (PS2, Xbox, and GameCube). I noticed that the number of cheats within these tables was much larger than the number of documented cheat codes for any of the versions of the game, and was naturally curious what these undocumented cheat codes could be. So, I made this utility to attempt to uncover the rest!

After discovering the initial set of cheats, I realized with the help of DCxDemo with [this comment](https://github.com/CB9001/thu2rcc/issues/3) that the same cheat hashing approach was used in numerous other games in the series. Games with cheats in the same hashing format include: Tony Hawk's Pro Skater 3, Tony Hawk's Pro Skater 4, Tony Hawk's Underground, Tony Hawk's Underground 2, and Tony Hawk's American Wasteland.

To crack these cheat code hashes, the project has evolved through three iterations:

1. **Python**: The initial implementation served as a proof of concept, but pure Python was far too slow to make large-scale dictionary cracking practical due to performing 100,000 CRC32 iterations per candidate word.
2. **Rust (Multi-threaded CPU)**: Re-implemented in Rust using Rayon for multi-core CPU parallelism, drastically improving performance over Python and enabling initial dictionary attacks.
3. **CUDA C++ (GPU Acceleration)**: Ported to CUDA C++ to run across thousands of GPU cores in parallel. This CUDA version provides **dramatic, orders-of-magnitude speedups** over both the Python and multi-threaded Rust CPU versions, reducing crack times for thousands of candidates down to sub-second durations.

## Findings (So Far)

Using this utility, I've managed to discover a number of previously undocumented cheat codes across multiple games in the series (Tony Hawk's Pro Skater 3, Tony Hawk's Pro Skater 4, Tony Hawk's Underground, Tony Hawk's Underground 2, and Tony Hawk's American Wasteland). Any cheats marked with 🟢 were previously undocumented (as far as I can tell).

A very special thanks to **[naomshi](https://github.com/naomshi)**, **[moddedBear](https://github.com/moddedBear)**, **[LudiCruz-Liam](https://github.com/LudiCruz-Liam)**, and **[violetvandal](https://github.com/violetvandal)** for finding additional codes and hashes which have been added to these lists 😊

### Tony Hawk's Pro Skater 3

| CheatScript                  | PC / PS2  | Xbox       | Gamecube  |
|------------------------------|-----------|------------|-----------|
| unlock_all_cheats            | backdoor  | 🟢 time2fly |           |
| cheat_give_everything        |           |            |           |
| cheat_give_levels            | roadtrip  | 🟢 sk84free |           |
| cheat_give_skaters           | yohomies  | teamfreak  | freakshow |
| cheat_give_neversoft_skaters | weeatdirt | weeatdirt  | weeatdirt |
| cleargame                    |           | stiffcomp  |           |
| AllDecks                     |           | neverboard |           |
| AllStats                     | pumpmeup  | juice4me   | maxmeout  |
| cheat_unlockmovies           | peepshow  | rollit     | popcorn   |
| cheat_unlockdoomguy          | idkfa     |            |           |
| cheat_give_rig               |           | 🟢 rigitup  |           |
| cheat_give_skaterX           |           | 🟢 bonedout |           |

### Tony Hawk's Pro Skater 4

| CheatScript                 | PS2         | Xbox        | Gamecube   |
|-----------------------------|-------------|-------------|------------|
| unlock_all_cheats           |             |             |            |
| cheat_unlock_always_special | doasuper    | i'myellow   | g0lden     |
| cheat_unlock_perfect_rail   | ssbsts      | belikeeric  |            |
| cheat_unlock_perfect_skitch |             | bumperrub   |            |
| cheat_unlock_stats_13       | 🟢 4nitwits  | 4p0sers     |            |
| cheat_unlock_perfect_manual | mullenpower |             | 2wheelin   |
| cheat_unlock_moon_grav      | superfly    | moon$hot    | giantsteps |
| cheat_unlock_matrix         | nospoon     | fbiagent    | mrandersen |
| cheat_unlock_inline         |             |             |            |
| give_50_stat_points         |             |             | 🟢 50reps   |
| cheat_unlockmovies          | 🟢 cutcutcut |             |            |
| unlock_all_cheat_codes      |             | 🟢 moronsrus |            |
| cheat_give_skaters          | homielist   | 🟢 homiesrus |            |
| cheat_reallygivelevels      |             |             |            |
| GoPro                       |             |             |            |
| cheat_give_jenna            | (o)(o)      | (o)(o)      | (o)(o)     |

### Tony Hawk's Underground

| CheatScript                 | PS2          | Xbox         | Gamecube     |
|-----------------------------|--------------|--------------|--------------|
| cheat_unlock_always_special | 🟢 superduper | 🟢 superduper | 🟢 superduper |
| cheat_unlock_perfect_rail   | letitslide   | letitslide   | letitslide   |
| cheat_unlock_perfect_skitch | rearrider    | rearrider    | rearrider    |
| cheat_unlock_perfect_manual |              |              |              |
| cheat_unlock_moon_grav      | getitup      | getitup      | getitup      |
| cheat_unlock_pedgroup1      |              |              |              |
| cheat_unlock_pedgroup2      |              |              |              |
| cheat_unlock_pedgroup3      | 🟢 machomen   | 🟢 machomen   | 🟢 machomen   |
| cheat_unlock_pedgroup4      |              |              |              |
| cheat_unlock_pedgroup5      | 🟢 goodolboys | 🟢 goodolboys | 🟢 goodolboys |
| cheat_unlock_pedgroup6      | 🟢 minwage    | 🟢 minwage    | 🟢 minwage    |
| cheat_unlock_pedgroup7      |              |              |              |
| cheat_unlock_pedgroup8      | 🟢 sputnik    | 🟢 sputnik    | 🟢 sputnik    |
| cheat_unlock_pedgroup9      |              |              |              |
| cheat_select_shift          |              |              |              |
| unlock_all_cheat_codes      |              |              |              |
| unlock_all_sponsors         |              | sellout      | 🟢 keepitreal |
| cheat_unlockmovies          | digivid      | 🟢 super8mm   | 🟢 fish-eye   |
| unlock_all_cutscenes        |              |              |              |
| cheat_reallygivelevels      | 🟢 boltcutter | 🟢 lockpik    | 🟢 hacksaw    |
| cheat_give_im               |              | 🟢 marvelous  | 🟢 wongchu    |
| cheat_give_kiss             |              |              |              |
| cheat_give_thud             |              | 🟢 argh!!     | nooo!!       |
| unlock_all_cheats           |              | 🟢 cap&ball   |              |

### Tony Hawk's Underground 2

| CheatScript                 | PS2          | PSP          | Xbox / PC    | Gamecube    |
|-----------------------------|--------------|--------------|--------------|-------------|
| cheat_unlock_always_special | likepaulie   |              | likepaulie   | likepaulie  |
| cheat_unlock_perfect_rail   |              | tightrope    |              |             |
| cheat_unlock_perfect_skitch |              |              |              |             |
| cheat_unlock_perfect_manual |              |              |              |             |
| cheat_unlock_moon_grav      |              | 🟢 m00nraker  |              |             |
| cheat_unlock_pedgroup1      | 🟢 cyberfans  |              | 🟢 cyberfans  | 🟢 cyberfans |
| cheat_unlock_pedgroup2      |              |              |              |             |
| cheat_unlock_pedgroup3      | 🟢 love2hate  | 🟢 hate2love  | 🟢 love2hate  | 🟢 love2hate |
| cheat_unlock_pedgroup4      | 🟢 fruitboot  | 🟢 gumdrops   | 🟢 fruitboot  | 🟢 fruitboot |
| cheat_unlock_pedgroup5      |              |              |              |             |
| cheat_unlock_pedgroup6      | 🟢 wdtboys    | 🟢 bratpak    | 🟢 wdtboys    | 🟢 wdtboys   |
| cheat_unlock_pedgroup7      |              | 🟢 evenmore   |              |             |
| cheat_unlock_pedgroup8      |              |              |              |             |
| cheat_give_shrek            | 🟢 greenguy   | 🟢 nevertold  | 🟢 farfaraway | 🟢 greenguy  |
| cheat_give_soldier          | 🟢 2infinity  | 🟢 dogtags    | 🟢 lockstock  | 🟢 foxhole   |
| cheat_give_phil             | aprilsman    | 🟢 tirejack   | notvito      | xxlarge     |
| cheat_give_hand             | 🟢 5fingers   | 🟢 hangloose  | 🟢 dabird     | 🟢 5knuckles |
| cheat_give_paulie           | 🟢 mrmouth    | 🟢 spittle    | 4wheeler     | 🟢 whoopin   |
| cheat_give_nigel            | sellout      | 🟢 tigerthong | skullet      | 🟢 britteeth |
| cheat_give_steveo           |              | 🟢 jackazz    | 🟢 staplegun  | 🟢 wildman   |
| cheat_give_jesse            | 🟢 wcchoppers | 🟢 mongarage  | 🟢 payups     | 🟢 outlaw    |
| cheat_give_thps             | 🟢 original1  | birdman      | 🟢 firstborn  | 🟢 retro1    |
| cheat_give_natas            | oldskool     |              | bedizzy      | unscrewed   |
| cheat_unlockmovies          | boxoffice    | 🟢 playbill   |              | sikflick    |
| cheat_reallygivelevels      | d3struct     | 🟢 w0rldt0ur  |              | urown3d     |
| cheat_give_story_skaters    | costars!     |              | 🟢 xtrahelp   | wakpak      |
| unlock_all_cheats           |              |              |              |             |
| cheat_select_shift          |              |              |              |             |
| unlock_PC_secret_character1 |              |              | 🟢 nicknow    |             |
| unlock_PC_secret_character2 |              |              | 🟢 pricenow   |             |
| cheat_sce_patchtest         |              |              |              |             |

### Tony Hawk's American Wasteland

| CheatScript                 | PS2          | Xbox          | Gamecube     |
|-----------------------------|--------------|---------------|--------------|
| cheat_unlock_always_special | uronfire     | uronfire      | uronfire     |
| cheat_unlock_perfect_rail   | grindxpert   | grindxpert    | grindxpert   |
| cheat_unlock_perfect_skitch | h!tchar!de   | h!tchar!de    | h!tchar!de   |
| cheat_unlock_perfect_manual | 2wheels!     | 2wheels!      | 2wheels!     |
| cheat_unlock_moon_grav      | 2them00n     | 2them00n      | 2them00n     |
| cheat_unlock_pedgroupa      | 🟢 larocks    | 🟢 larocks     | 🟢 larocks    |
| cheat_unlock_pedgroupb      | 🟢 cityangels | 🟢 cityangels  | 🟢 cityangels |
| cheat_unlock_pedgroupc      |              |               |              |
| cheat_unlock_pedgroupd      | 🟢 lostangels | 🟢 lostangels  | 🟢 lostangels |
| cheat_unlock_robotony       | 🟢 hawk_2020  | 🟢 futurebird  |              |
| cheat_unlock_mindy          |              |               |              |
| cheat_unlock_liljohn        |              |               | hip2dhop     |
| cheat_unlock_iggy           |              | 🟢 snakepipe   |              |
| cheat_unlock_ellis          | sirius-dj    | 🟢 jayman      | 🟢 fact!on    |
| cheat_unlock_jimbo          | 🟢 art!st!c   |               |              |
| cheat_unlock_murphy         |              |               |              |
| cheat_unlock_mega           | 🟢 oilrigger  | 🟢 oilrigger   | 🟢 oilrigger  |
| cheat_unlock_billiejoe      | 🟢 gr33nd@y   | 🟢 gr33nd@y    | 🟢 gr33nd@y   |
| cheat_unlock_boone          | 🟢 faceplant  | 🟢 faceplant   | 🟢 faceplant  |
| cheat_unlock_hoffman        |              |               |              |
| cheat_unlock_careless       |              |               |              |
| cheat_unlock_clover         | 🟢 lloydd     | 🟢 lloydd      | 🟢 lloydd     |
| cheat_unlock_butterfinger1  |              |               |              |
| cheat_unlock_butterfinger2  |              |               |              |
| cheat_unlock_butterfinger3  |              |               |              |
| cheat_unlockmovies          |              |               |              |
| cheat_reallygivelevels      |              | 🟢 takemethere |              |
| unlock_all_cheats           |              | 🟢 h@rdc0re    | 🟢 w@stel@nd  |
| cheat_select_shift          |              |               |              |

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
