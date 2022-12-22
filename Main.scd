s.boot;
s.queryAllNodes;
currentEnvironment.clear;

(
s.plotTree;
s.scope;
s.meter;
)

(
// Parameters
~numOuts = 2;
~bugVoices = 0;
~waterVoices = 0;
~reverbAmount = 0;

// Groups
~sourceGroup = Group.new;
~bugGroup = Group.new(~sourceGroup, \addToTail);
~waterGroup = Group.new(~sourceGroup, \addToTail);
~atmosGroup = Group.new(~sourceGroup, \addToTail);
~effectsGroup = Group.new(~sourceGroup, \addAfter);

// Main Procedure
Synth.new(\BugVoice, target: ~bugGroup);
Synth.new(\Atmos, target: ~atmosGroup);
Synth.new(\ReverbSend, target: ~effectsGroup);
)

