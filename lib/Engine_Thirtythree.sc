    // Engine_Thirtythree

// Inherit methods from CroneEngine
Engine_Thirtythree : CroneEngine {

    // Thirtythree specific v0.1.0
    var sampleBuffThirtythree;
    var playerThirtythree;
    var fxBusBitcrush;
    var fxSynBitcrush;
    var pitchToRate;
    var osfun;
    // var osfunThirtyThree;
    // Thirtythree ^

    *new { arg context, doneCallback;
        ^super.new(context, doneCallback);
    }

    alloc {
        // Thirtythree specific v0.0.1
        pitchToRate = [0.0625,0.066666666666667,0.0703125,0.075,0.078125,0.083333333333333,0.087890625,0.09375,0.1,0.10416666666667,0.11111111111111,0.1171875,0.125,0.13333333333333,0.140625,0.15,0.15625,0.16666666666667,0.17578125,0.1875,0.2,0.20833333333333,0.22222222222222,0.234375,0.25,0.26666666666667,0.28125,0.3,0.3125,0.33333333333333,0.3515625,0.375,0.4,0.41666666666667,0.44444444444444,0.46875,0.5,0.53333333333333,0.5625,0.6,0.625,0.66666666666667,0.703125,0.75,0.8,0.83333333333333,0.88888888888889,0.9375,1.0,1.0666666666667,1.125,1.2,1.25,1.3333333333333,1.40625,1.5,1.6,1.6666666666667,1.7777777777778,1.875,2.0,2.1333333333333,2.25,2.4,2.5,2.6666666666667,2.8125,3.0,3.2,3.3333333333333,3.5555555555556,3.75,4.0,4.2666666666667,4.5,4.8,5.0,5.3333333333333,5.625,6.0,6.4,6.6666666666667,7.1111111111111,7.5,8.0,8.5333333333333,9.0,9.6,10.0,10.666666666667,11.25,12.0,12.8,13.333333333333,14.222222222222,15.0,16.0];
        fxBusBitcrush = Bus.audio(context.server, 2);

        context.server.sync;

        SynthDef("fxSynDefBitcrush",{
            arg inBus,bitcrush_bits=8,bitcrush_rate=10000;
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
            arg bufnum, amp=0, playerNum, ampLag=0, t_trig=0,fadeout=0.05,
            pitchBase=0,pitchAdj=0,
            sampleStart=0,sampleEnd=1,samplePos=0,
            rate=0,rateSlew=0,bpm_sample=1,bpm_target=1,
            fxSendBitcrush=0,fxOutBitcrush,
            fxloop_trig,fxloop_beats=1,
            fx_scratch=0,fx_scratch_beats=1,
            fx_stutter=0,fx_stutter_beats=1/16,vinyl=0,loop=0,
            pan=0,lpf=20000,lpflag=0,hpf=10,hpflag=0,lpf_resonance=1,hpf_resonance=1,
            use_envelope=1,env_trig=0,
	        fx_reverse=0,fx_autopan=0,fx_octaveup=0,fx_octavedown=0;

            // vars
            var snd,pos,pos2,sampleStart2,sampleEnd2,env,bFrames;

            // pitch 
            // rate = rate*pitchToRate[48+Index.kr(pitchBase.asInteger+pitchAdj.asInteger];
            rate = rate*Index.kr(
                LocalBuf.newFrom(pitchToRate),
                48+pitchBase+pitchAdj,
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
            rate = (fx_scratch<1*rate) + (fx_scratch>0*SinOsc.kr(bpm_target/60/fx_scratch_beats));

            // final rate 
            rate = BufRateScale.kr(bufnum)*rate;

            bFrames = BufFrames.kr(bufnum);

            env=EnvGen.ar(
                Env.new(
                    levels: [0,1,1,0], 
                    times: [0.005,(sampleEnd-sampleStart)*(bFrames/48000/rate.abs)-fadeout-0.005,fadeout],
                    curve:\sine,
                ), 
                gate: t_trig,
            );

            pos = Phasor.ar(
                trig:t_trig,
                rate:rate,
                start:((sampleStart*(rate>0))+(sampleEnd*(rate<0)))*bFrames,
                end:((sampleEnd*(rate>0))+(sampleStart*(rate<0)))*bFrames,
                resetPos:samplePos*bFrames
            );

            sampleStart2 = Gate.kr(pos,1-fxloop_trig);
            sampleEnd2 = (sampleStart2+ArrayMin.kr([60/bpm_target/(1/48000/Gate.kr(rate.abs,1-fxloop_trig))*fxloop_beats,bFrames]).at(0));
            pos2=Phasor.ar(
                trig:fxloop_trig,
                rate:rate,
                start:((sampleStart2*(rate>0))+(sampleEnd2*(rate<0))),
                end:((sampleEnd2*(rate>0))+(sampleStart2*(rate<0))),
                resetPos:sampleStart2
            );
            fxloop_trig=Lag.kr(fxloop_trig,0.2);
            snd=(BufRd.ar(2,bufnum,
                pos,
                loop:0,
                interpolation:4
            )*(1-fxloop_trig))+(BufRd.ar(2,bufnum,
                pos2,
                loop:0,
                interpolation:1
            )*fxloop_trig);
            snd = RLPF.ar(snd,Lag.kr(lpf,lpflag),lpf_resonance);
            snd = RHPF.ar(snd,Lag.kr(hpf,hpflag),hpf_resonance);

            // fx_stutter
            // snd = ((fx_stutter<1)*snd)+((fx_stutter>0)*snd*(SinOsc.ar(bpm_target/60/fx_stutter_beats).range(0,1)));
            fx_stutter = Lag.kr(fx_stutter,0.1);
            snd = snd*((1-fx_stutter)+(fx_stutter*(SinOsc.ar(bpm_target/60/fx_stutter_beats).range(0,1))));

            // manual panning
            amp = Lag.kr(amp,ampLag)*(((use_envelope>0)*env)+(use_envelope<1));
            snd = Balance2.ar(snd[0],snd[1],
                pan+SinOsc.kr(bpm_target/60/2,mul:fx_autopan*0.8),
                level:amp,
            );

            SendTrig.kr(Trig.kr(A2K.kr(1-amp.sign)),playerNum,1);  

            Out.ar(fxOutBitcrush,snd*fxSendBitcrush);
            Out.ar(0,snd*(1-fxSendBitcrush))
        }).add; 

        context.server.sync;

        playerThirtythree = Array.fill(12,{arg i;
            // Synth("playerThirtythree"++i,[\fxOutBitcrush,fxBusBitcrush],target:context.xg);
            Synth("playerThirtythree",[\fxOutBitcrush,fxBusBitcrush.index,\playerNum,i],target:context.xg);
        });

        osfun = OSCFunc({ 
            arg msg, time; 
            [time, msg].postln; 
            // send lua the 1-index version of the voice
            NetAddr("127.0.0.1", 10111).sendMsg("voicedone",1,msg[2]+1);  
        },'/tr', context.server.addr);
        
        this.addCommand("tt_load","is", { arg msg;
            // lua is sending 1-index
            sampleBuffThirtythree[msg[1]-1].free;
            sampleBuffThirtythree[msg[1]-1] = Buffer.read(context.server,msg[2]);
        });

        this.addCommand("tt_play","iifiifffffffffffff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \t_trig,1,
                \bufnum,sampleBuffThirtythree[msg[2]-1],
                \amp,msg[3],
                \ampLag,0,
                \rate,1,
                \rateSlew,0,
                \pitchBase,msg[4],
                \pitchAdj,msg[5],
                \samplePos,msg[6],
                \sampleStart,msg[6],
                \sampleEnd,msg[7],
                \lpf,msg[8],
                \lpf_resonance,msg[9],
                \lpflag,0,
                \hpf,msg[10],
                \hpf_resonance,msg[11],
                \hpflag,0,
                \use_envelope,1,
                // turn off effects
                \fxSendBitcrush,msg[12],
                \fx_stutter,msg[13],
                \fx_stutter_beats,msg[14],
                \fx_autopan,msg[15],
                \fx_reverse,msg[16],
                \fx_octaveup,msg[17],
                \fx_octavedown,msg[18],
                \fx_scratch,0,
                \fxloop_trig,0,
            );
        });

	   this.addCommand("tt_update","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \t_trig,1,
                \samplePos,msg[2],
                \sampleStart,msg[2],
                \sampleEnd,msg[3],
            );
	
    	});

        this.addCommand("tt_amp","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \amp,msg[2],
                \ampLag,msg[3],
            );
        });

        this.addCommand("tt_pitch","iif", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \pitchAdj,msg[2],
                \rateSlew,msg[3],
            );
        });

        this.addCommand("tt_bpm","f", { arg msg; 
            (0..12).do({arg i; 
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

        this.addCommand("tt_fx_loop","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fxloop_trig,msg[2],
                \use_envelope,1-msg[2],
                \fxloop_beats,msg[3],
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
                \rateSlew,1,
            );
        });

        this.addCommand("tt_fx_octavedown","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_octavedown,msg[2],
                \rateSlew,1,
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

        this.addCommand("tt_fx_scratch","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_scratch,msg[2],
                \fx_scratch_beats,msg[3],
                \fxloop_trig,msg[2],
                \use_envelope,1-msg[2],
                \fxloop_beats,1,
            );
        });

        this.addCommand("tt_fx_stutter","iff", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \fx_stutter,msg[2],
                \fx_stutter_beats,msg[3],
            );
        });

        this.addCommand("tt_use_envelope","if", { arg msg;
            // lua is sending 1-index
            playerThirtythree[msg[1]-1].set(
                \use_envelope,msg[2],
            );
        });

        this.addCommand("tt_onset","s", { arg msg;
            var filename=msg[1].asString;
            fork {
                var server = Server(\nrt2,
                    options: ServerOptions.new
                    .numOutputBusChannels_(2)
                    .numInputBusChannels_(2)
                );
                var resultbuf, resultpath, oscpath, score, dur, sf, cond, size, data;
                var fname;

                filename.postln;
                // get duration
                sf = SoundFile.openRead(filename);
                dur = sf.duration;
                sf.close;
                dur.postln;

                "generating".postln;

                resultpath = PathName.tmp +/+ UniqueID.next ++ ".aiff";
                oscpath = PathName.tmp +/+ UniqueID.next ++ ".osc";

                score = Score([
                    [0, (resultbuf = Buffer.new(server, 1000, 1, 0)).allocMsg],
                    [0, [\d_recv, SynthDef(\onsets, {
                        var sig = SoundIn.ar(0), // will come from NRT input file
                        // fft = FFT(LocalBuf(512, 1), sig),
                        // trig = Onsets.kr(fft),
                        trig = Coyote.kr(sig),
                        // count the triggers: this is the index to save the data into resultbuf
                        i = PulseCount.kr(trig),
                        // count time in seconds
                        timer = Sweep.ar(1);
                        // 'i' must be audio-rate for BufWr.ar
                        BufWr.ar(timer, resultbuf, K2A.ar(i), loop: 0);
                        BufWr.kr(i, resultbuf, DC.kr(0), 0);  // # of points in index 0
                    }).asBytes]],
                    [0, Synth.basicNew(\onsets, server, 1000).newMsg],
                    [dur, resultbuf.writeMsg(resultpath, headerFormat: "AIFF", sampleFormat: "float")]
                ]);

                cond = Condition.new;

                // osc file path, output path, input path - input is soundfile to analyze
                score.recordNRT(oscpath, "/dev/null", sf.path, sampleRate: sf.sampleRate,
                    options: ServerOptions.new
                        .verbosity_(-1)
                        .numInputBusChannels_(sf.numChannels)
                        .numOutputBusChannels_(sf.numChannels)
                        .sampleRate_(sf.sampleRate),
                    action: { cond.unhang }  // this re-awakens the process after NRT is finished
                );
                cond.hang;  // wait for completion

                resultpath.postln;
                sf = SoundFile.openRead(resultpath);
                // get the size: one frame at the start
                sf.readData(size = FloatArray.newClear(1));
                size = size[0];
                // now the rest of the data
                sf.readData(data = FloatArray.newClear(size));
                sf.close;

                File.delete(oscpath);
                File.delete(resultpath);
                server.remove;

                data.postln;  // these are your onsets!
                NetAddr("127.0.0.1", 10111).sendMsg("onsets",filename,dur,data.asString);  
            };
        });

        // ^ Thirtythree specific

    }

    free {
        // Thirtythree Specific v0.0.1
        (0..64).do({arg i; sampleBuffThirtythree[i].free});
        (0..12).do({arg i; playerThirtythree[i].free});
        fxSynBitcrush.free;
        fxBusBitcrush.free;
        pitchToRate.free;
        osfun.free;
        // osfunThirtyThree.free;
        // ^ Thirtythree specific
    }
}
