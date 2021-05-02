# thirtythree

![image](https://user-images.githubusercontent.com/6550035/116799473-85c14780-aaae-11eb-8430-1987c69ce517.jpg)

A po-33 clone for norns+grid

I love the po-33 and for a long time I've wanted something similar for norns (e.g. a micro-sampler/splicer + sequencer). I tried making something similar in [abacus](https://llllllll.co/t/abacus) but I didn't have a grid so the ux was very limited and ultimately gave me a bad flow. after making [amen](https://llllllll.co/t/amen) which is a great looper+fx for me, I realized that a lot of my work could be re-used to make a splicer+sequencer. instead of designing a ux from scratch like I did for abacus, I decided to just copy the ux from the po-33. I don't like copying when it comes to art - of which the po-33 might belong. but in this case I feel the po-33 is more instrument than art and I feel warranted to do the copy to have total and complete skill transferability between instruments.

## requirements

- norns
- monome grid or most midi grids

## documentation

### differences between po-33 and thirtythree.

- thirtythree is based in the norns which has higher sound quality (48khz, 24bit, stereo samples). 
- thirtythree fx are sound-specific (see `PARAMS` menu to toggle to be global). 
- thirtythree fx *stack* (except looping fx) so multiple fx can be applied simultanouesly.
- in addition to recording from line-in, you can also load a file into any bank (see `PARAMS` menu). 
- you can have multiple backups change backup # in the `PARAMS` menu. 
- you have two choices of layouts (see nrloe) - the classic 5x5 type layout and a compressed 4x6 layout that lets you stamp more of the thirtythree apps across the grid. 
- you can chain up to four operators on a grid, and there is ~12 note polyphony shared across all of the operators.

### po-33 basics

[the official guide](https://teenage.engineering/guides/po-33/en) for the po-33 explains the usage for this app. basics:

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

when in the "trim" mode, you can use E2 or E3 to jog the endpoints. use E1 to zoom in to the last endpoint moved.

here are the two possible layouts available to stamp the grid with:

![layouts](https://user-images.githubusercontent.com/6550035/116799476-8ce85580-aaae-11eb-9b38-2d9c2ea6f179.jpg)

### thirtythree effects

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

### known limitations/bugs

- backups will not restore if you move/delete the original audio. backups store a reference to the audio file and not the actual audio data (stretch goal to fix this).
- looping fx don't stack.
- sometimes there is race condition in the bpm, if you get wacko pattern stepping, restart. so far I haven't been able to reproduce consistently.
- using 6/8 beat fx might cause operators to get out of sync. operators will try to stay in sync, but if this happens, stop all the patterns and start them again.


## todo

- [ ] save when idle
- [ ] show pattern id
- [ ] show alert when chaining pattern
- [ ] allow togggling number of operators