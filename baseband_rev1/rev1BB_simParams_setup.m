%% Message

%Example data for header
type = 0;
src = 5;
dst = 2;
net_id = 1;
len = frame_len_bytes-crc_len_bytes;

local_node_id = 2;

pad_first = 1000;

[testMsg_ch0, headerPayloadCRCSymbols_ch0, header_payload_binary_ch0, crc_binary_ch0, header_payload_packed_ch0, transmittedBits_ch0] = generate_random_frame(seed, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[simX_ch0, modX_ch0, zeroX_ch0] = createTestVectors(radix, testMsg_ch0, headerPayloadCRCSymbols_ch0, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
[testMsg_ch1, headerPayloadCRCSymbols_ch1, header_payload_binary_ch1, crc_binary_ch1, header_payload_packed_ch1, transmittedBits_ch1] = generate_random_frame(seed+1, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[simX_ch1, modX_ch1, zeroX_ch1] = createTestVectors(radix, testMsg_ch1, headerPayloadCRCSymbols_ch1, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
[testMsg_ch2, headerPayloadCRCSymbols_ch2, header_payload_binary_ch2, crc_binary_ch2, header_payload_packed_ch2, transmittedBits_ch2] = generate_random_frame(seed+2, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[simX_ch2, modX_ch2, zeroX_ch2] = createTestVectors(radix, testMsg_ch2, headerPayloadCRCSymbols_ch2, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
[testMsg_ch3, headerPayloadCRCSymbols_ch3, header_payload_binary_ch3, crc_binary_ch3, header_payload_packed_ch3, transmittedBits_ch3] = generate_random_frame(seed+3, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[simX_ch3, modX_ch3, zeroX_ch3] = createTestVectors(radix, testMsg_ch3, headerPayloadCRCSymbols_ch3, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);

%% Imperfections

manChan = true; %Used for AWGN and Manual channels

%Declared so that rayleigh channel block is always happy even when not in
%use
chanDelays = [0];
chanAvgPathGainsdB = [0];

%For AWGN, will be overwritten by manual if used
manChanDelaysSymb = [0];
manChanPathGains=[1];
manChanDelays = manChanDelaysSymb*basePer;

if(strcmp(channelSpec, 'AWGN'))
    disp(['Channel: ', channelSpec]);
elseif(strcmp(channelSpec, 'Manual'))
    manChanDelaysSymb = manualChanDelaysSymb;
    manChanDelays = manChanDelaysSymb*basePer;
    manChanPathGains = manualChanPathGain;
    disp(['Channel: ', channelSpec]);
    disp(['Channel Delays (Symbols): ' mat2str(manChanDelaysSymb)]);
    disp(['Path Gains: ' mat2str(manChanPathGains)]);
else
    channelMdl = stdchan(overSamplePer, maxDopplerHz, channelSpec);
    chanDelays = channelMdl.PathDelays;
    chanDelaysSymb = chanDelays/basePer;
    chanAvgPathGainsdB = channelMdl.AvgPathGaindB;
    chanPathGains = channelMdl.PathGains;

    disp(['Channel: ' channelSpec]);
    disp(['Channel Delays (Symbols): ' mat2str(chanDelaysSymb)]);
    disp(['Average Path Gain (dB): ' mat2str(chanAvgPathGainsdB)]);
    disp('Rayleigh Fading');
    disp('Normalized Avg Total Path Gains = 0 dB');
    disp(['Max Doppler (Hz): ' num2str(maxDopplerHz)]);
    disp('Doppler Spectrum: Jakes');
    manChan = false;
end

%Create Channel FIR Filter
%Warning! Delays are rounded to sample periods.
pathDelaysSamplePer = manChanDelays*overSampleFreq;
maxSampleDelay = max(pathDelaysSamplePer);
pathGains = abs(manChanPathGains);
%Normalize Path Gains
% powerNorm = sum(pathGains.^2);
% pathGains = pathGains./sqrt(powerNorm);
%Fill Filter
channelFIR = zeros(1, round(maxSampleDelay)+1);
for pathID = 1:length(pathDelaysSamplePer)
    delayIndex = round(pathDelaysSamplePer(pathID))+1;
    pathTap = pathGains(pathID);
    channelFIR(delayIndex) = complex(pathTap);
end

disp(['CarrierFreqOffsetHz = ', num2str(freqOffsetHz)])

disp(['awgnSNRdB = ', num2str(awgnSNR)])

SymbolFreqOffsetHz = 1/((1+txTimingOffset)*overSamplePer) - 1/overSamplePer;
disp(['SymbolFreqOffsetHz = ', num2str(SymbolFreqOffsetHz)])

rng(awgnSeed);
txTimingPhase = rand(1)*channelizerUpDownSampling + 500;
rxPhaseOffset = rand(1)*360; %Random

if rxPhaseFixed
    rxPhaseOffset = 0; %Fixed
    txTimingPhase = channelizerUpDownSampling*overSample*4+1; %Fixed
end

%tx_rx_gain = 0.5882;
tx_rx_gain = 1;

tx_impare_i_scale = 1;
tx_impare_q_scale = 1;
%tx_impare_i_scale = 0.2822;
%tx_impare_q_scale = 0.2822;
%tx_impare_i_offset = 0.0084*tx_rx_gain;
%tx_impare_q_offset = 0.1851*tx_rx_gain;
tx_impare_i_offset = 0;
tx_impare_q_offset = 0;

rx_impare_i_scale = 1;
rx_impare_q_scale = 1;
%rx_impare_i_offset = 0.0198;
%rx_impare_q_offset = -4.5168e-04;
rx_impare_i_offset = 0;
rx_impare_q_offset = 0;

%post_cr_i_offset = -tx_impare_i_offset/tx_rx_gain;
%post_cr_q_offset = -tx_impare_q_offset/tx_rx_gain;

post_cr_i_offset = 0;
post_cr_q_offset = 0;

%rx_offset_correction_i = -rx_impare_i_offset;
%rx_offset_correction_q = -rx_impare_q_offset;

%rx_offset_correction_i = -0.3801;
%rx_offset_correction_q = -0.2840;

rx_offset_correction_i = 0;
rx_offset_correction_q = 0;

%rx_offset_correction_i = -0.39;
%rx_offset_correction_q = -0.27;