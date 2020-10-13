%% Message

%Example data for header
type = 0;
src = 5;
dst = 2;
net_id = 1;
len = frame_len_bytes-crc_len_bytes;

local_node_id = 2;

pad_first = 1000;


% To test random packets, uncomment lines below
[testMsg_ch0, headerPayloadCRCSymbols_ch0, header_payload_binary_ch0, crc_binary_ch0, header_payload_packed_ch0, transmittedBits_ch0] = generate_random_frame(seed, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[testMsg_ch1, headerPayloadCRCSymbols_ch1, header_payload_binary_ch1, crc_binary_ch1, header_payload_packed_ch1, transmittedBits_ch1] = generate_random_frame(seed+1, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[testMsg_ch2, headerPayloadCRCSymbols_ch2, header_payload_binary_ch2, crc_binary_ch2, header_payload_packed_ch2, transmittedBits_ch2] = generate_random_frame(seed+2, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
[testMsg_ch3, headerPayloadCRCSymbols_ch3, header_payload_binary_ch3, crc_binary_ch3, header_payload_packed_ch3, transmittedBits_ch3] = generate_random_frame(seed+3, bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);

% To test ASCII packets (including padding(, uncomment lines below
% testAsciiText = '3 May. Bistritz.-Left Munich at 8:35 P. M., on 1st May, arriving at Vienna early next morning; should have arrived at 6:46, but train was an hour late. Buda-Pesth seems a wonderful place, from the glimpse which I got of it from the train and the little I could walk through the streets. I feared to go very far from the station, as we had arrived late and would start as near the correct time as possible. The impression I had was that we were leaving the West and entering the East; the most western of splendid bridges over the Danube, which is here of noble width and depth, took us among the traditions of Turkish rule.\n\nWe left in pretty good time, and came after nightfall to Klausenburgh. Here I stopped for the night at the Hotel Royale. I had for dinner, or rather supper, a chicken done up some way with red pepper, which was very good but thirsty. (Mem., get recipe for Mina.) I asked the waiter, and he said it was called "paprika hendl," and that, as it was a national dish, I should be able to get it anywhere along the Carpathians. I found my smattering of German very useful here; indeed, I don''t know how I should be able to get on without it.\n\nHaving had some time at my disposal when in London, I had visited the British Museum, and made search among the books and maps in the library regarding Transylvania; it had struck me that some foreknowledge of the country could hardly fail to have some importance in dealing with a nobleman of that country. I find that the district he named is in the extreme east of the country, just on the borders of three states, Transylvania, Moldavia and Bukovina, in the midst of the Carpathian mountains; one of the wildest and least known portions of Europe. I was not able to light on any map or work giving the exact locality of the Castle Dracula, as there are no maps of this country as yet to compare with our own Ordnance Survey maps; but I found that Bistritz, the post town named by Count Dracula, is a fairly well-known place. I shall enter here some of my notes, as they may refresh my memory when I talk over my travels with Mina\n\nIn the population of Transylvania there are four distinct nationalities: Saxons in the South, and mixed with them the Wallachs, who are the descendants of the Dacians; Magyars in the West, and Szekelys in the East and North. I am going among the latter, who claim to be descended from Attila and the Huns. This may be so, for when the Magyars conquered the country in the eleventh century they found the Huns settled in it. I read that every known superstition in the world is gathered into the horseshoe of the Carpathians, as if it were the centre of some sort of imaginative whirlpool; if so my stay may be very interesting. (Mem., I must ask the Count all about them.\n\nI did not sleep well, though my bed was comfortable enough, for I had all sorts of queer dreams. There was a dog howling all night under my window, which may have had something to do with it; or it may have been the paprika, for I had to drink up all the water in my carafe, and was still thirsty. Towards morning I slept and was wakened by the continuous knocking at my door, so I guess I must have been sleeping soundly then. I had for breakfast more paprika, and a sort of porridge of maize flour which they said was "mamaliga," and egg-plant stuffed with forcemeat, a very excellent dish, which they call "impletata." (Mem., get recipe for this also.) I had to hurry breakfast, for the train started a little before eight, or rather it ought to have done so, for after rushing to the station at 7:30 I had to sit in the carriage for more than an hour before we began to move. It seems to me that the further east you go the more unpunctual are the trains. What ought they to be in China\n\nAll day long we seemed to dawdle through a country which was full of beauty of every kind. Sometimes we saw little towns or castles on the top of steep hills such as we see in old missals; sometimes we ran by rivers and streams which seemed from the wide stony margin on each side of them to be subject to great floods. It takes a lot of water, and running strong, to sweep the outside edge of a river clear. At every station there were groups of people, sometimes crowds, and in all sorts of attire. Some of them were just like the peasants at home or those I saw coming through France and Germany, with short jackets and round hats and home-made trousers; but others were very picturesque. The women looked pretty, except when you got near them, but they were very clumsy about the waist. They had all full white sleeves of some kind or other, and most of them had big belts with a lot of strips of something fluttering from them like the dresses in a ballet, but of course there were petticoats under them. The strangest figures we saw were the Slovaks, who were more barbarian than the rest, with their big cow-boy hats, great baggy dirty-white trousers, white linen shirts, and enormous heavy leather belts, nearly a foot wide, all studded over with brass nails. They wore high boots, with their trousers tucked into them, and had long black hair and heavy black moustaches. They are very picturesque, but do not look prepossessing. On the stage they would be set down at once as some old Oriental band of brigands. They are, however, I am told, very harmless and rather wanting in natural self-assertion\n\nIt was on the dark side of twilight when we got to Bistritz, which is a very interesting old place. Being practically on the frontier-for the Borgo Pass leads from it into Bukovina-it has had a very stormy existence, and it certainly shows marks of it. Fifty years ago a series of great fires took place, which made terrible havoc on five separate occasions. At the very beginning of the seventeenth century it underwent a siege of three weeks and lost 13,000 people, the casualties of war proper being assisted by famine and disease\n\nCount Dracula had directed me to go to the Golden Krone Hotel, which I found, to my great delight, to be thoroughly old-fashioned, for of course I wanted to see all I could of the ways of the country. I was evidently expected, for when I got near the door I faced a cheery-looking elderly woman in the usual peasant dress-white undergarment with long double apron, front, and back, of coloured stuff fitting almost too tight for modesty. When I came close she bowed and said, "The Herr Englishman?" "Yes," I said, "Jonathan Harker." She smiled, and gave some message to an elderly man in white shirt-sleeves, who had followed her to the door. He went, but immediately returned with a letter:\n\n"My Friend.-Welcome to the Carpathians. I am anxiously expecting you. Sleep well to-night. At three to-morrow the diligence will start for Bukovina; a place on it is kept for you. At the Borgo Pass my carriage will await you and will bring you to me. I trust that your journey from London has been a happy one, and that you will enjoy your stay in my beautiful land\n\n"Your friend\n\n"Dracula."\n\n';
% [testMsg_ch0, headerPayloadCRCSymbols_ch0, header_payload_binary_ch0, crc_binary_ch0, header_payload_packed_ch0, transmittedBits_ch0] = generate_frame(testAsciiText(1*payload_len_symbols*log2(radix)/8+1:length(testAsciiText)), bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
% 
% % [testMsg_ch0, headerPayloadCRCSymbols_ch0, header_payload_binary_ch0, crc_binary_ch0, header_payload_packed_ch0, transmittedBits_ch0] = generate_frame(testAsciiText(1:length(testAsciiText)), bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
% [testMsg_ch1, headerPayloadCRCSymbols_ch1, header_payload_binary_ch1, crc_binary_ch1, header_payload_packed_ch1, transmittedBits_ch1] = generate_frame(testAsciiText(1*payload_len_symbols*log2(radix)/8+1:length(testAsciiText)), bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
% [testMsg_ch2, headerPayloadCRCSymbols_ch2, header_payload_binary_ch2, crc_binary_ch2, header_payload_packed_ch2, transmittedBits_ch2] = generate_frame(testAsciiText(2*payload_len_symbols*log2(radix)/8+1:length(testAsciiText)), bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);
% [testMsg_ch3, headerPayloadCRCSymbols_ch3, header_payload_binary_ch3, crc_binary_ch3, header_payload_packed_ch3, transmittedBits_ch3] = generate_frame(testAsciiText(3*payload_len_symbols*log2(radix)/8+1:length(testAsciiText)), bitsPerSymbolHeader, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWordRx);

[simX_ch0, modX_ch0, zeroX_ch0] = createTestVectors(radix, testMsg_ch0, headerPayloadCRCSymbols_ch0, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
[simX_ch1, modX_ch1, zeroX_ch1] = createTestVectors(radix, testMsg_ch1, headerPayloadCRCSymbols_ch1, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
[simX_ch2, modX_ch2, zeroX_ch2] = createTestVectors(radix, testMsg_ch2, headerPayloadCRCSymbols_ch2, x_PRE, x_PRE_adj, header_len_bytes, bitsPerSymbolHeader, frame_len_bytes, bitsPerSymbol, after, pad_first);
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