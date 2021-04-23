// Engine_Thirtythree

// Inherit methods from CroneEngine
Engine_Thirtythree : CroneEngine {

    // Thirtythree specific v0.1.0
    var sampleBuffThirtythree;
    var playerThirtythree;
    // Thirtythree ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Thirtythree specific v0.0.1
        sampleBuffThirtythree = Array.fill(16, { arg i; 
            Buffer.new(context.server);
        });

        (0..16).do({arg i; 
            SynthDef("playerThirtythree"++i,{ 
                arg bufnum, amp=0, t_trig=0,t_trigtime=0, amp_crossfade=0,
                sampleStart=0,sampleEnd=1,samplePos=0,
                rate=1,rateSlew=0,bpm_sample=1,bpm_target=1,
                bitcrush=0,bitcrush_bits=24,bitcrush_rate=44100,
                scratch=0,strobe=0,vinyl=0,
                timestretch=0,timestretchSlowDown=1,timestretchWindowBeats=1,
                pan=0,lpf=20000,lpflag=0,hpf=10,hpflag=0;
    
                // vars
                var snd,pos,timestretchPos,timestretchWindow;
                rate = Lag.kr(rate,rateSlew);
                // scratch effect
                rate = (scratch<1*rate) + (scratch>0*LFTri.kr(bpm_target/60*2));

                pos = Phasor.ar(
                    trig:t_trig,
                    rate:BufRateScale.kr(bufnum)*rate,
                    start:((sampleStart*(rate>0))+(sampleEnd*(rate<0)))*BufFrames.kr(bufnum),
                    end:((sampleEnd*(rate>0))+(sampleStart*(rate<0)))*BufFrames.kr(bufnum),
                    resetPos:samplePos*BufFrames.kr(bufnum)
                );
                timestretchPos = Phasor.ar(
                    trig:t_trigtime,
                    rate:BufRateScale.kr(bufnum)*rate/timestretchSlowDown,
                    start:((sampleStart*(rate>0))+(sampleEnd*(rate<0)))*BufFrames.kr(bufnum),
                    end:((sampleEnd*(rate>0))+(sampleStart*(rate<0)))*BufFrames.kr(bufnum),
                    resetPos:pos
                );
                timestretchWindow = Phasor.ar(
                    trig:t_trig,
                    rate:BufRateScale.kr(bufnum)*rate,
                    start:timestretchPos,
                    end:timestretchPos+((60/bpm_target/timestretchWindowBeats)/BufDur.kr(bufnum)*BufFrames.kr(bufnum)),
                    resetPos:timestretchPos,
                );

                snd=BufRd.ar(2,bufnum,pos,
                    loop:1,
                    interpolation:1
                );
                timestretch=Lag.kr(timestretch,2);
                snd=((1-timestretch)*snd)+(timestretch*BufRd.ar(2,bufnum,
                    timestretchWindow,
                    loop:1,
                    interpolation:1
                ));

                snd = LPF.ar(snd,Lag.kr(lpf,lpflag));
                snd = HPF.ar(snd,Lag.kr(hpf,hpflag));
                // strobe
                snd = ((strobe<1)*snd)+((strobe>0)*snd*LFPulse.ar(60/bpm_target*16));
                // bitcrush
                bitcrush = VarLag.kr(bitcrush,1,warp:\cubed);
                snd = (snd*(1-bitcrush))+(bitcrush*Decimator.ar(snd,VarLag.kr(bitcrush_rate,1,warp:\cubed),VarLag.kr(bitcrush_bits,1,warp:\cubed)));

                // manual panning
                snd = Balance2.ar(snd[0],snd[1],
                    pan+SinOsc.kr(60/bpm_target*16,mul:strobe*0.5),
                    level:Lag.kr(amp,0.2)*Lag.kr(amp_crossfade,0.2)
                );

                Out.ar(0,snd)
            }).add; 
        });


        playerThirtythree = Array.fill(16,{arg i;
            Synth("playerThirtythree"++i, target:context.xg);
        });

        
        this.addCommand("tt_load","is", { arg msg;
            // lua is sending 1-index
            sampleBuffThirtythree[msg[1]-1].free;
            sampleBuffThirtythree[msg[1]-1] = Buffer.read(context.server,msg[2]);
            playerThirtythree[msg[1]-1].set(
                \bufnum,sampleBuffThirtythree[msg[1]-1],
            );
        });


        // ^ Thirtythree specific

    }

    free {
        // Thirtythree Specific v0.0.1
        (0..16).do({arg i; sampleBuffThirtythree[i].free});
        (0..16).do({arg i; playerThirtythree[i].free});
        // ^ Thirtythree specific
    }
}
