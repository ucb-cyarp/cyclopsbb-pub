%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)

pad_first = 1000;

mod_imperfection = zeros(pad_first, 1);
testMsgFPGA = cat(1, mod_imperfection, testMsg);

preambleMask = zeros(length(x_PRE_adj), 1);
headerMask = zeros(header_len_bytes*8/bitsPerSymbolHeader, 1);
packetMask = ones(payload_len_symbols, 1)*2;
modulationMask = cat(1, mod_imperfection, preambleMask, headerMask, packetMask);

simX.time = [];
simX.signals.values = testMsgFPGA;
simX.signals.dimensions = 1;

modX.time = [];
modX.signals.values = modulationMask;
modX.signals.dimensions = 1;

dataDelay = length(cat(1, x_PRE_adj)) + 1 + 187+360+1;%delay in computing
idealX.time = [];
idealX.signals.values = cat(1, testTextTrunkRadix, after);
idealX.signals.dimensions = 1;