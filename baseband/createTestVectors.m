%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)

dead_air_symbols = 10000;
purge_symbols = 100; % symbols to purge the transmitter pipeline at the end of the packet

%create a tail of 8 symbols. Used to keep power at expected lvl at end of
%frame.  For lower order modulation schemes, modulus is taken at
%transmitter.
pkt_tail = [12; 6; 1; 11; 5; 14; 0; 6];

dead_air = zeros(dead_air_symbols, 1);
tx_purge = zeros(purge_symbols, 1);
testMsgFPGA = cat(1, dead_air, testMsg, tx_purge);

%Modulation
%0 = Zeros (ie. transmit nothing)
%1 = BPSK
%2 = QPSK
%3 = 16QAM
%Recall that the preamble and header are always BPSK
modulation_type = cat(1, zeros(dead_air_symbols, 1), ones(length(xCTRL_PRE_adj)+length(header), 1), payload_modulation.*ones(length(payload), 1), zeros(purge_symbols, 1));

simX.time = [];
simX.signals.values = testMsgFPGA;
simX.signals.dimensions = 1;

modulation_typeX.time = [];
modulation_typeX.signals.values = modulation_type;
modulation_typeX.signals.dimensions = 1;