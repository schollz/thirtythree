    // Engine_Thirtythree

// Inherit methods from CroneEngine
Engine_Thirtythree : CroneEngine {

    // Thirtythree specific v0.1.0
    var sampleBuffThirtythree;
    var playerThirtythree;
    var fxBusBitcrush;
    var fxSynBitcrush;
    // var osfunThirtyThree;
    // Thirtythree ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Thirtythree specific v0.0.1

        fxBusBitcrush = Bus.audio(context.server, 2);

        context.server.sync;

        SynthDef("fxSynDefBitcrush",{
            arg inBus,bitcrush_bits=6,bitcrush_rate=4000;
            var snd = In.ar(inBus,2);
            snd = Decimator.ar(snd,bitcrush_rate,bitcrush_bits);
            Out.ar(0,snd);
        }).add;

        context.server.sync;

        fxSynBitcrush = Synth("fxSynDefBitcrush",[
            \inBus,fxBusBitcrush.index,
        ], context.xg);

        sampleBuffThirtythree = Array.fill(64, { arg i; 
            Buffer.new(context.server);
        });

        SynthDef("playerThirtythree",{ 
            arg bufnum, amp=0, ampLag=0,t_trig=0,t_trigtime=0,fadeout=0.05,
            sampleStart=0,sampleEnd=1,samplePos=0,
            rate=0,rateSlew=0,bpm_sample=1,bpm_target=1,
            fxSendBitcrush=0,fxOutBitcrush,
            fx_scratch=0,fx_strobe=0,vinyl=0,loop=0,
            pan=0,lpf=20000,lpflag=0,hpf=10,hpflag=0,lpf_resonance=1,hpf_resonance=1,
            use_envelope=1,fx_reverse=0,fx_autopan=0,fx_octaveup=0,fx_octavedown=0;

            // vars
            var snd,pos,timestretchPos,timestretchWindow,env;

            env=EnvGen.ar(
                Env.new(
                    levels: [0,1,1,0], 
                    times: [0.01,(sampleEnd-sampleStart)*(BufDur.kr(bufnum)/(BufRateScale.kr(bufnum)*rate))-fadeout-0.01-0.01,fadeout],
                    curve:\sine,
                ), 
                gate: t_trig,
            );

            // reverse effect
            rate = ((fx_reverse<1)*rate)+((fx_reverse>0)*rate.neg);

            // octave up
            rate = ((fx_octaveup<1)*rate)+((fx_octaveup>0)*rate*2);

            // octave down
            rate = ((fx_octavedown<1)*rate)+((fx_octavedown>0)*rate*0.5);

            // rate slew
            rate = Lag.kr(rate,rateSlew);

            // scratch effect
            rate = (fx_scratch<1*rate) + (fx_scratch>0*LFTri.kr(bpm_target/60*2));

            pos = Phasor.ar(
                trig:t_trig,
                rate:BufRateScale.kr(bufnum)*rate,
                start:((sampleStart*(rate>0))+(sampleEnd*(rate<0)))*BufFrames.kr(bufnum),
                end:((sampleEnd*(rate>0))+(sampleStart*(rate<0)))*BufFrames.kr(bufnum),
                resetPos:samplePos*BufFrames.kr(bufnum)
            );
            snd=BufRd.ar(2,bufnum,pos,
                loop:0,
                interpolation:1
            );
            snd = RLPF.ar(snd,Lag.kr(lpf,lpflag),lpf_resonance);
            snd = RHPF.ar(snd,Lag.kr(hpf,hpflag),hpf_resonance);

            // fx_strobe
            // snd = ((fx_strobe<1)*snd)+((fx_strobe>0)*snd*LFPulse.ar(bpm_target/60*2));

            // manual panning
            amp = Lag.kr(amp,ampLag)*(((use_envelope>0)*env)+(use_envelope<1));
            snd = Balance2.ar(snd[0],snd[1],
                pan+SinOsc.kr(60/bpm_target*16,mul:fx_autopan*0.5),
                level:amp,
            );

            Out.ar(fxOutBitcrush,snd*fxSendBitcrush);
            Out.ar(0,snd*(1-fxSendBitcrush))
        }).add; 

        context.server.sync;

        playerThirtythree = Array.fill(15,{arg i;
            // Synth("playerThirtythree"++i,[\fxOutBitcrush,fxBusBitcrush],target:context.xg);
            Synth("playerThirtythree",[\fxOutBitcrush,fxBusBitcrush.index],target:context.xg);
        });
        
        this.addCommand("tt_load","is", { arg msg;
            // lua is sending 1-index
            sampleBuffThirtythree[msg[1]-1].free;
            sampleBuffThirtythree[msg[1]-1] = Buffer.read(context.server,msg[2]);
        });

        this.addCommand("tt_play","iifffffffff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \t_trig,1,
                \bufnum,sampleBuffThirtythree[msg[2]-1],
                \amp,msg[3],
                \rate,msg[4],
                \samplePos,msg[5],
                \sampleStart,msg[5],
                \sampleEnd,msg[6],
                \lpf,msg[7],
                \lpf_resonance,msg[8],
                \lpflag,0,
                \hpf,msg[9],
                \hpf_resonance,msg[10],
                \hpflag,0,
                \use_envelope,1,
                // turn off effects
                \fx_strobe,0,
                \fx_scratch,0,
                \fx_reverse,0,
                \fx_octaveup,0,
                \fx_autopan,0,
                \fx_octavedown,0,
                \fxSendBitcrush,msg[11],
            );
        });

        this.addCommand("tt_amp","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \amp,msg[2],
                \ampLag,msg[3],
            );
        });

        this.addCommand("tt_rate","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \rate,msg[2],
                \rateSlew,msg[3],
            );
        });

        this.addCommand("tt_bpm","f", { arg msg; 
            (0..15).do({arg i; 
                playerThirtythree[i].set(
                    \bpm_target,msg[1],
                );
            }); 
        });

        this.addCommand("tt_lpf","ifff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \lpf,msg[2],
                \lpflag,msg[3],
                \hpf,20,
                \hpflag,msg[3],
                \lpf_resonance,msg[4],
                \hpf_resonance,1,
            );
        });
        
	   this.addCommand("tt_hpf","ifff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \lpf,20000,
                \lpflag,msg[3],
                \hpf,msg[2],
                \hpflag,msg[3],
                \hpf_resonance,msg[4],
                \lpf_resonance,1,
            );
        });

        this.addCommand("tt_fx_loop","iffff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \samplePos,msg[2],
                \sampleStart,msg[3],
                \sampleEnd,msg[4],
                \use_envelope,msg[5], // effectively used to turn on and off
            );
        });

        this.addCommand("tt_bitcrush","ifff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fxSendBitcrush,msg[2],
             );
            fxSynBitcrush.set(
                \bitcrush_bits,msg[3],
                \bitcrush_rate,msg[4],
             );
        });

        this.addCommand("tt_fx_reverse","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_reverse,msg[2],
            );
        });

        this.addCommand("tt_fx_octaveup","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_octaveup,msg[2],
            );
        });

        this.addCommand("tt_fx_octavedown","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_octavedown,msg[2],
            );
        });

        this.addCommand("tt_fx_timestretch","ifff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \timestretch,msg[2],
                \timestretchWindowBeats,msg[3],
                \timestretchSlowDown,msg[4],
            );
        });

        this.addCommand("tt_fx_autopan","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_autopan,msg[2],
            );
        });

        this.addCommand("tt_fx_scratch","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_scratch,msg[2],
            );
        });

        this.addCommand("tt_fx_strobe","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_strobe,msg[2],
            );
        });

        this.addCommand("tt_use_envelope","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \use_envelope,msg[2],
            );
        });

        // ^ Thirtythree specific

    }

    free {
        // Thirtythree Specific v0.0.1
        (0..64).do({arg i; sampleBuffThirtythree[i].free});
        (0..15).do({arg i; playerThirtythree[i].free});
        fxSynBitcrush.free;
        fxBusBitcrush.free;
        // osfunThirtyThree.free;
        // ^ Thirtythree specific
    }
}
