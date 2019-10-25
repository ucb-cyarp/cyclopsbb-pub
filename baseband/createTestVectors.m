%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)

if(radix == 2) %BPSK
    modType = 0;
elseif(radix == 4) %QPSK
    modType = 1;
else %16QAM
    modType = 2;
end

pad_first = 1000;

mod_imperfection = zeros(pad_first, 1);
testMsgFPGA = cat(1, mod_imperfection, testMsg);

preambleMask = zeros(length(x_PRE), 1);
headerMask = zeros(header_len_bytes*8/bitsPerSymbolHeader, 1);
packetMask = ones(frame_len_bytes*8/bitsPerSymbol, 1).*modType;
modulationMask = cat(1, mod_imperfection, preambleMask, headerMask, packetMask);

simX.time = [];
simX.signals.values = cat(1, testMsgFPGA, zeros(round(size(testMsgFPGA)./2)), testMsgFPGA);
simX.signals.dimensions = 1;

modX.time = [];
modX.signals.values = cat(1, modulationMask, zeros(round(size(modulationMask)./2)), modulationMask);
modX.signals.dimensions = 1;

dataDelay = length(cat(1, x_PRE_adj)) + 1 + 187+360+1;%delay in computing
idealX.time = [];
idealX.signals.values = cat(1, testTextTrunkRadix, after);
idealX.signals.dimensions = 1;