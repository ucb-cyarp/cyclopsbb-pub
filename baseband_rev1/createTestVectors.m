function [simX, modX, zeroX] = createTestVectors(radix, testMsg, testTextTrunkRadix, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first)
%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)

if(radix == 2) %BPSK
    modType = 0;
elseif(radix == 4) %QPSK
    modType = 1;
elseif(radix == 16) %16QAM
    modType = 2;
else %256QAM
    modType = 3;
end

mod_imperfection = zeros(pad_first, 1);
testMsgFPGA = cat(1, mod_imperfection, testMsg);

preambleMask = zeros(length(x_PRE), 1);
headerMask = zeros(header_len_bytes*8/bitsPerSymbolHeader, 1);
packetMask = ones(frame_len_bytes*8/bitsPerSymbol, 1).*modType;
afterMask = zeros(length(after), 1);
modulationMask = cat(1, mod_imperfection, preambleMask, headerMask, packetMask, afterMask);
zeroMask =  cat(1, true(size(mod_imperfection)), false(size(preambleMask)), false(size(headerMask)), false(size(packetMask)), true(size(afterMask)));

simX.time = [];
simX.signals.values = cat(1, testMsgFPGA, testMsgFPGA);
simX.signals.dimensions = 1;

modX.time = [];
modX.signals.values = cat(1, modulationMask, modulationMask);
modX.signals.dimensions = 1;

zeroX.time = [];
zeroX.signals.values = cat(1, zeroMask, zeroMask, true(round(size(modulationMask)./2))); %Adding some additional zeros at the end
zeroX.signals.dimensions = 1;

dataDelay = length(cat(1, x_PRE_adj)) + 1 + 187+360+1;%delay in computing
idealX.time = [];
idealX.signals.values = cat(1, testTextTrunkRadix, after);
idealX.signals.dimensions = 1;