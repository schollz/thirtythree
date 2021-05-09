# thirtythree

a po-33 clone for norns+grid.

![image](https://user-images.githubusercontent.com/6550035/116799473-85c14780-aaae-11eb-8430-1987c69ce517.jpg)

https://vimeo.com/545281946


I love the po-33 and for a long time I've wanted something similar for norns (e.g. a micro-sampler/splicer + sequencer). I tried making something similar in [abacus](https://llllllll.co/t/abacus) but I didn't have a grid so the ux was very limited and ultimately gave me a bad flow. after making [amen](https://llllllll.co/t/amen) which is a great looper+fx for me, I realized that a lot of my work could be re-used to make a splicer+sequencer too. instead of designing a ux from scratch like I did for abacus, I decided to just copy the ux from the po-33 to have complete skill transferability between instruments (much like you would have between two pianos or two saxophones). however there are some key differences:

- thirtythree is based in the norns which has higher sound quality (48khz, 24bit, stereo samples (though higher is not always better))
- thirtythree fx are *sound*-specific instead of global (see `PARAMS` menu to toggle global fx in the po-33). 
- thirtythree fx *stack* (except looping fx) so multiple fx can be applied simultanouesly.
- in addition to recording from line-in, you can also load a file into any bank (see `PARAMS` menu to toggle this bheavior). 
- you have two choices of layouts (see the `PARAMS` menu) - the classic 5x5 type layout and a compressed 4x6 layout that lets you stamp more of the thirtythree apps across the grid. 
- you can chain up to four operators on a grid, and there is ~10 note polyphony shared across all of the operators.
- thirtythree doesn't save instantaneously like the po-33 does. you can save manually using the key combo (below) or wait for the auto-save to occur (which occurs after idling for ~3 seconds).
- thirtythree dumps can be shared via the [norns.online cloud](https://norns.online/share/thirtythree/).


## requirements

- norns
- monome grid or most midi grids

## documentation


[the official te guide](https://teenage.engineering/guides/po-33/en) for the po-33 explains the usage for this app as thirtythree follows all of the same key combos. basics:

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
- [ ] copy sound with <kbd>write</kbd>+</kbd>sound</kbd>+<kbd>1-16</kbd>
- [ ] copy slice with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>9-16</kbd>+<kbd>1-16</kbd>
- [x] add effects with <kbd>fx</kbd>+<kbd>1-16</kbd>
- [x] change swing with <kbd>bpm</kbd>+<kbd>K3</kbd>
- [x] change tempo tapping <kbd>bpm</kbd>
- [x] change tempo with <kbd>bpm</kbd>+<kbd>K3</kbd>
- [x] change master volume with <kbd>bpm</kbd>+<kbd>1-16</kbd>
- [x] parameter locking with <kbd>write</kbd>+(<kbd>K2</kbd> or <kbd>K3</kbd>)
- [x] chain pattern with <kbd>pattern</kbd>+<kbd>1-16</kbd>
- [x] copy pattern with <kbd>write</kbd>+<kbd>pattern</kbd>+<kbd>1-16</kbd>
- [x] clear entire pattern with <kbd>record</kbd>+<kbd>pattern</kbd>
- [ ] clear current sound pattern with <kbd>record</kbd>+<kbd>sound</kbd>+<kbd>pattern</kbd> (*new*)
- [x] backup data with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>play</kbd>
- [x] restore data with <kbd>write</kbd>+<kbd>sound</kbd>+<kbd>record</kbd>

when in the "trim" mode, you can use E2 or E3 to jog the endpoints. use E1 to zoom in to the last endpoint moved. in the tone or filter mode, you can adjust things with just E2 or E3.

here are the two possible layouts available to stamp the grid with:

![layouts](https://user-images.githubusercontent.com/6550035/116799476-8ce85580-aaae-11eb-9b38-2d9c2ea6f179.jpg)

### thirtythree effects

the fx are the same, except unison effects replaced by stereo auto-panning and a bitcrush. some fx stack (looping / scratching do not).

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

### saving / loading

thirtythree automatically saves your current state when you are idle - this is the "default" that will be loaded each time you open thirtythree (just like when you turn on a po-33). you can also use the key combo to save (see above).

in addition to automatic saving, you can save your current state to a separte file using `PSET > SAVE` and load with `PSET > LOAD`. 

thirtythree also optionally lets you share your work with others. first install and run `norns.online`:

```
;install https://github.com/schollz/norns.online
```

once you run that app and choose a username, you can then use thirtythree to upload+download shares. there will be a new menu `PARAMS > SHARE > upload/download` which you can use to share or backup your work to the cloud.

### known limitations/bugs

- backups will not restore if you move/delete the `~/dust/audio/thirtythree` audio folder, where all the audio data is stored.
- looping fx don't stack.
- sometimes there is race condition in the bpm, if you get wacko pattern stepping, restart. so far I haven't been able to reproduce consistently.
- using 6/8 beat fx might cause operators to get out of sync. if this happens, stop all the patterns and start them again and they should sync back up.


## thanks :pray:

thank you @license and @catfact for never ceasing to teach me a half dozen supercollider tricks in half as many lines of code. thanks to @proswell and [@CrazyEmporer893](https://www.instagram.com/crazyemperor893/) for beta testing. thanks to @eigen for the [p8 library](https://github.com/p3r7/p8) which was a jumping off point for the graphics and source of the [the manga](https://github.com/p3r7/p8/blob/main/manga_effect.lua). thanks to @glia for allow me to include [a yelidek kit](https://ifizu.bandcamp.com/album/yelidek) as the default drum kit.  thank you [@jredou_ko](https://www.instagram.com/jredou_ko/) for help with the graphics.


## install

install with 

```
;install https://github.com/schollz/thirtythree
```

the first time you run thirtythree it will update your norns with the [aubio library](https://aubio.org/) which is used to generate default onsets. this might take 10-15 seconds.

## todo

- [ ] show alert when chaining pattern / add to ui?

## license

MIT
