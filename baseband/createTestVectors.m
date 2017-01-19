%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)

pad_first = 2000;

mod_imperfection = zeros(pad_first, 1);
testMsgFPGA = cat(1, mod_imperfection, testMsg);

simX.time = [];
simX.signals.values = testMsgFPGA;
simX.signals.dimensions = 1;

dataDelay = length(cat(1, xCTRL_PRE_adj)) + 1 + 187+360+1;%delay in computing
idealX.time = [];
idealX.signals.values = cat(1, testTextTrunkBin, after);
idealX.signals.dimensions = 1;