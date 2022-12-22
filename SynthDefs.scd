// Buffers
~bugBuffer = Buffer.readChannel(s, thisProcess.nowExecutingPath.dirname +/+ "sounds/STE.wav", channels: [0]);

(
~waterBuffer = 0;
// Busses
~reverbBus = Bus.audio(s, 2);
~waterBus = Bus.audio(s, 2);
~bugBus = Bus.audio(s,2);
~atmosBus = Bus.audio(s,2);
~mixBus = Bus.audio(s, 2);

// Synth Defs
SynthDef(\BugVoice, {
	arg out,
	    pan = -1.0,
	    reverbSend = 0.0,
	    bpfRange = 100.0, bpfOffset = 12500.0, bpfLFORate = 10.0, bpfQ = 1.1,
	    lpfRange = 1000.0, lpfOffset = 10900.0, lpfLFORate = 0.09,
        grainRate = 10, grainDuration = 0.5, grainPosition = 0.3489, grainPositionRange = 0.02,
	    chorusVoices = 10, chorusOffset = 0.01 , chorusRange = 0.02,
	    echoMaxDelay = 1.0, echoTime 0.260, echoDecay = 0.3
	var startPos,
	    bpfLFO, lpfLFO,
	    outSig,
	    bufferSig,
	    filterSig, delaySig, chorusSig, echoSig;

	startPos = Rand(0.0, ~bugBuffer.numFrames);

	// Modulators
	bpfLFO = SinOsc.kr(bpfLFORate, Rand(0.0, 1.0)) * bpfRange + bpfOffset;
	lpfLFO = SinOsc.kr(lpfLFORate, Rand(0.0, 1.0)) * lpfRange + lpfOffset;

	// Source
	bufferSig = GrainBuf.ar(
		2,
		Impulse.ar(grainRate + LFNoise0.kr(10)),
		grainDuration,
		~bugBuffer,
		1,
		grainPosition + LFNoise0.kr(10,chorusRange)
	);

	// Signal Chain
	filterSig = LPF.ar(BPF.ar(bufferSig, bpfLFO, bpfQ), lpfLFO);
	chorusSig = Mix.fill(
		10,
		{
			DelayC.ar(filterSig, 1, LFNoise1.kr(5, chorusOffset, chorusRange)) * 0.1;
	    }
	);
	echoSig = CombN.ar(chorusSig, echoMaxDelay, echoTime, echoDecay);

	outSig = Pan2.ar(echoSig, pan);
	Out.ar(~reverbBus, outSig * reverbSend);
	Out.ar(out, outSig);
}).add;

SynthDef(\WaterVoice, {
	arg out,
	    reverbSend = 0.0;
	var outSig,
	    pan;
	pan = Rand(-1.0, 1.0);

	outSig = Pan2.ar(Saw.ar(), pan);
	Out.ar(~reverbBus, outSig * reverbSend);
	Out.ar(out, outSig);
}).add;

SynthDef(\Atmos, {
	arg out = ~atmosBus,
	    reverbSend = 0.0,
	    mainLFORate = 0.05,
	    bassFreq = 30, bassLFOAmount = 5.0,
	    noiseLFOAmount = -0.125,
	    clicksDensity = 2.0, clicksCutoff = 12000.0,
	    filterCutoff = 102.0, filterQ = 0.125,
	    chorusVoices = 10, chorusOffset = 0.01, chorusRange = 0.02,
	    echoMaxDelay = 1.0, echoTime = 0.260, echoDecay = 0.3;
	var mainLFO,
	    outSig,
	    bassSig, noiseSig,
	    filterSig, clicksSig, chorusSig, echoSig;

	// Modulators
	mainLFO = SinOsc.kr(mainLFORate);

	// Sources
	bassSig = SinOsc.ar(bassFreq + (mainLFO * bassLFOAmount)) * 0.5;
	noiseSig = WhiteNoise.ar() * (0.25 + (mainLFO * noiseLFOAmount));
	clicksSig = HPF.ar(Dust.ar(clicksDensity), clicksCutoff) * 0.25;

	// Signal Chain
	filterSig = RLPF.ar(bassSig + noiseSig, filterCutoff, filterQ);
	chorusSig = Mix.fill(
		10,
		{
			DelayC.ar(filterSig + clicksSig, 1, LFNoise1.kr(5, chorusOffset, chorusRange)) * 0.1;
	    }
	);
	echoSig = CombN.ar(chorusSig, echoMaxDelay, echoTime, echoDecay);

	outSig = Pan2.ar(echoSig, 0.0);
	Out.ar(~reverbBus, outSig * reverbSend);
	Out.ar(out, outSig);
}).add;

// Sends
SynthDef(\ReverbSend, {
	arg out;
	Out.ar(out, FreeVerb.ar(In.ar(~reverbBus, 2), mix: 1.0));
}).add;

// OSC Defs
OSCdef.new(
	\XYSlider, {
		arg msg, time, addr, recvPort;
		msg[0].postln;
	},
	'/main/xy1'
);
)
