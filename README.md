# thirtythree

A po-33 clone for norns+grid

### differences between thirtythree and the po-33

- thirtythree is based in the norns which has higher sound quality (48khz, 24bit, stereo samples) if thats something you want.
- thirtythree effects are *not global* and only apply to the current sound. each sound has its own effect parameter locks too. also there are two new effects (replacing unisons).
- instead of recording, you can load a file into any bank (in `PARAMS` menu).
- you can have multiple backups and make them quickly (<1 sec), change backup # in the `PARAMS` menu.
- you have two choices of layouts - the classic 5x5 type layout and a compressed 4x6 layout that lets you stamp more of the thirtythree apps across the grid.

## po-33 basics

- [x] melodic (buttons 1-8) and drum splicing (buttons 9-16)
- [x] record with <kbd>record</kbd>+<kbd>1-16</kbd> (option to load files instead in parameters)
- [x] select sound with <kbd>sound</kbd>+<kbd>1-16</kbd>
- [x] write mode activated with <kb>write</kbd>
- [x] select pattern with <kbd>pattern</kbd>+<kbd>1-16</kbd>
- [x] play pattern with <kbd>play</kbd>
- [x] toggle parameters with <kbd>fx</kbd>
- [x] adjust tone (pitch+volume) with <kbd>E2</kbd> and <kbd>E3</kbd>
- [x] adjust filter (lp+hp) with <kbd>E2</kbd> and <kbd>E3</kbd>
- [x] adjust trim (start+end) with <kbd>E2</kbd> and <kbd>E3</kbd>
- [x] delete sound with <kbd>record</kbd>+<kbd>sound</kbd>
- [ ] copy slice with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>9-16</kbd>+<kbd>1-16</kbd>
- [x] add effects with <kbd>fx</kbd>+<kbd>1-16</kbd>
- [x] change swing with <kbd>bpm</kbd>+<kbd>K3</kbd>
- [x] change tempo tapping <kbd>bpm</kbd>
- [x] change tempo with <kbd>bpm</kbd>+<kbd>K3</kbd>
- [x] change master volume with <kbd>bpm</kbd>+<kbd>1-16</kbd>
- [x] parameter locking with <kbd>write</kbd>+(<kbd>K2</kbd> or <kbd>K3</kbd>)
- [x] chain pattern with <kbd>pattern</kbd>+<kbd>1-16</kbd>
- [x] copy pattern with <kbd>write</kbd>+<kbd>pattern</kbd>+<kbd>1-16</kbd>
- [x] clear pattern with <kbd>record</kbd>+<kbd>pattern</kbd>
- [x] backup data with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>play</kbd>
- [x] restore data with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>record</kbd>

## effects

1. loop 16
2. loop 12 
3. loop short
4. loop shorter 
5. ~~unison~~ autopan
6. ~~unison low~~ bitcrush
7. octave up
8. octave down
9. stutter 4
10. stutter 3 
11. scratch
12. scratch fast 
13. 6/8 quantize
14. retrigger pattern
15. reverse
16. none

## expect bugs

here are some that I know will be bugs:

- thirtythree doesn't store audio data in the backups - it only stores a reference to the file. (in future I want to have an option to store everything). so if you delete or move an audio file that is part of a backup, expect to see a bug. 
- looping fx don't stack with anything.