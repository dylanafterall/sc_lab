// wave
(
x = {
    var sig, lfo;
    // lfo is sine wave, oscillating between 0 and 0.2, starting at 0 (due to phase shift)
    lfo = SinOsc.kr(freq: 1/5, phase: 3pi/2, mul: 0.1, add: 0.1);
    sig = PinkNoise.ar * lfo;
    sig = sig ! 2;
}.play;
)
x.release(2);

// same wave
(
x = {
    var sig, lfo;
    // lfo is sine wave, oscillating between 0 and 0.2, starting at 0 (due to phase shift)
    lfo = SinOsc.kr(freq: 0.2, phase: 3pi/2).range(0, 0.2);
    sig = PinkNoise.ar * lfo;
    sig = sig ! 2;
}.play;
)
x.release(2);



// Env
(
e = Env.new(
    levels: [0, 1, 0.4, 0.4, 0],
    times: [1, 1, 4, 2],
    curve: [\sin, \exp, \cub, \wel]
);
e.plot;
)

// EnvGen
(
f = { |gate = 1|
    var sig, env;
    env = EnvGen.kr(
        envelope: Env.new(
            [0, 1, 0.4, 0.4, 0],
            [1, 1, 4, 2],
            [\sin, \exp, \cub, \wel],
            3
        ),
        gate: gate
        // doneAction: 2
    );
    sig = SinOsc.ar(350) * 0.3;
    sig = sig * env;
    sig = sig ! 2;
};
)

x = f.play;

x.set(\gate, 0); // fade to silence but do not free
x.set(\gate, 1); // reopen the gate to restart envelope

x.free;

// trigger arguments for envelope
(
x = { |t_gate = 0|
    var sig, env;
    env = EnvGen.kr(
        Env.new(
            [0, 1, 0],
            [0.02, 0.3],
            [0, -4],
        ),
        t_gate,
    );
    sig = SinOsc.ar(350) * 0.3;
    sig = sig * env;
    sig = sig ! 2;
}.play;
)

x.set(\t_gate, 1); // evaluate repeatedly
x.free; // free when finished

{SinOsc.ar(300, mul: 0.1)}.play;
{SinOsc.ar(300, mul: 0.1) ! 2}.play;


s.meter;
s.scope;
s.quit;

// multichannel
(
{
    var sig, mod;
    sig = SinOsc.ar([450, 800]);
    mod = SinOsc.kr([1, 9]).range(0, 1); // 450 in left speaker modulated at 1 Hz, 800 in right speaker modulated at 9 Hz
    sig = sig * mod;
    sig = sig * 0.2;
}.play;
)

// use of Pan2 to 'move' a single channel input signal
(
{
    var sig, pan;
    pan = SinOsc.kr(0.5) * 0.8;
    sig = PinkNoise.ar * 0.2;
    // when pan is -1 or 1, signal is p;resent in only one of two output channels. when pan is 0, is equally present in both
    // Pan2 should always receive a 1 channel input signal
    sig = Pan2.ar(sig, pan);
}.play;
)

// use of Splay - mixes a multichannel signal (in this case, 50 channels) to a two-channel format
// input channels are "placed" at equidistant points from left-to-right
// convenient option for hearing large mult-channel signals
(
{
    var sig, freq;
    freq = {exprand(200, 2000)} ! 50;
    sig = SinOsc.ar(freq) * 0.1;
    sig = Splay.ar(sig);
}.play;
)

// SynthDef
(
SynthDef(\test, {
    var sig;
    sig = SinOsc.ar([350, 450]);
    sig = sig * 0.15;
    Out.ar(0, sig);
}).add;
)

x = Synth(\test);
x.free;

// SynthDef with arguments
(
SynthDef.new(\test2, {
    arg freq = 350, amp = 0.2, atk = 0.1, dec = 0.3,
    slev = 0.4, rel = 1, gate = 1, out = 0;
    var sig, env;
    env = EnvGen.kr(
        Env.adsr(atk, dec, slev, rel),
        gate,
        doneAction: 2
    );
    sig = SinOsc.ar(freq + [0, 1]);
    sig = sig * env;
    sig = sig * amp;
    Out.ar(out, sig);
}).add;
)

x = Synth(\test2);
x.set(\freq, 450);
x.set(\amp, 0.5);
x.set(\gate, 0, \rel, 3);

x = Synth(\test2, [freq: 800, amp: 0.1, atk: 4, slev: 1]);
x.set(\gate, 0);

// generate and fade a tone cluster
(
// return an array of four synths, assigned to x
x = [205, 310, 525, 700].collect({ |f|
    Synth.new(\test2, [\freq, f, \amp, 0.1]);
});
)
// fade out each synth
x.do({ |n| n.set(\gate, 0, \rel, 5)});

// random SynthDef
(
SynthDef(\rand_ugen, {
    var sig = SinOsc.ar({ExpRand(200, 2000)} ! 30);
    sig = Splay.ar(sig) * 0.05;
    Out.ar(0, sig);
}).add;
)
Synth(\rand_ugen); // unique randomness for every synth instantiation

// polling a ugen
(
x = {
    var sig, freq;
    freq = SinOsc.kr(0.2).exprange(200, 800).poll(1);
    sig = SinOsc.ar(freq);
    sig = sig * 0.2;
    sig = sig ! 2;
}.play;
)

// tools
// Stethoscope, ServerMeters, Server GUI, Volume Slider, Node Tree, FreqScope
s.scope;
FreqScope.new;
s.volume.gui;
s.makeGui;
Platform.recordingsDir;
s.record;
s.stopRecording;
s.plotTree;
s.quit;