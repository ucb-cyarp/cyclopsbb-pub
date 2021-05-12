%berCalcPoint Calculates BER (for header & payload) as well as tracking
%packets that failed to decode for a single configuration point of the
%radio/simulation.  This version relies on the simulation being conducted
%seperatly and the results/parameters of the 

function [totalHeaderBer, totalPayloadBer, evmHeader, evmHeaderTR, evmPayload, evmPayloadTR, ...
          packetDecodeCompleteFailure, packetDecodeFailureDueToModulationFieldCorruption, ...
          payloadBitErrors, payloadBits, payloadErrorVector, payloadErrorVectorTR, payloadRMS] = ...
    berCalcPointParSim(data_recieved_packed, symbols_recieved, symbols_afterTR_recieved, ... %These should be cell arrays
                       expected_packed_data, expected_symbols, ...
                       numChannels, packetsPerChannel, ...
                       header_len_bytes, crc_len_bytes, frame_len_bytes, ...
                       bitsPerSymbolHeader, bitsPerSymbol, ...
                       radixHeader, radix, overSample, bitsPerSymbolMax, channelizerUpDownSampling, awgnSNR, ...
                       calcEVM)

% header_len_bytes gives the header length in bytes
% payload_len_bytes gives the payload length
% crc_len_bytes gives the CRC length in bytes
% frame_len_bytes gives the payload + crc length in bytes

if header_len_bytes ~= 8
    error('Header length is unexpected');
end 

%% Run Sim
% We will assume that the sim has already been run and that a series of 
% arrays will be provided by the calling script.  This is now a function


%% Compute Ideal Vectors
                
%Create expected constallation points
headerSymbols = header_len_bytes*8/bitsPerSymbolHeader;
payloadCRCSymbols = frame_len_bytes*8/bitsPerSymbol;

if packetsPerChannel*(headerSymbols+payloadCRCSymbols) ~= length(expected_symbols{1})
   error('Disagreement between expected number of symbols and length');
end
% if packetsPerChannel*(headerSymbols+payloadCRCSymbols) ~= length(expected_symbols{1}) || ...
%    packetsPerChannel*(headerSymbols+payloadCRCSymbols) ~= length(expected_symbols{2}) || ...
%    packetsPerChannel*(headerSymbols+payloadCRCSymbols) ~= length(expected_symbols{3}) || ...
%    packetsPerChannel*(headerSymbols+payloadCRCSymbols) ~= length(expected_symbols{4})
%    
%    error('Disagreement between expected number of symbols and length');
% end

expected_const_pts = {zeros(headerSymbols+payloadCRCSymbols, 1)};
% expected_const_pts = {zeros(headerSymbols+payloadCRCSymbols, 1), ...
%                       zeros(headerSymbols+payloadCRCSymbols, 1), ...
%                       zeros(headerSymbols+payloadCRCSymbols, 1), ...
%                       zeros(headerSymbols+payloadCRCSymbols, 1)};

for chan=0:(numChannels-1)
    for pkt = 0:(packetsPerChannel-1)
        baseInd = 1 + pkt*(headerSymbols+payloadCRCSymbols);

        %Modulate header
        if radixHeader == 2
            expected_const_pts{chan+1}(baseInd:(baseInd+headerSymbols-1)) = pskmod(expected_symbols{chan+1}(baseInd:(baseInd+headerSymbols-1)), 2);
        elseif radixHeader == 4
            expected_const_pts{chan+1}(baseInd:(baseInd+headerSymbols-1)) = pskmod(expected_symbols{chan+1}(baseInd:(baseInd+headerSymbols-1)), 4, pi/4, 'gray');
        else
            expected_const_pts{chan+1}(baseInd:(baseInd+headerSymbols-1)) = qammod(expected_symbols{chan+1}(baseInd:(baseInd+headerSymbols-1)), radixHeader, 'gray', 'InputType','integer','UnitAveragePower',true);
        end

        %Modulate payload+CRC
        if radix == 2
            expected_const_pts{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)) = pskmod(expected_symbols{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)), 2);
        elseif radix == 4
            expected_const_pts{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)) = pskmod(expected_symbols{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)), 4, pi/4, 'gray');
        else
            expected_const_pts{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)) = qammod(expected_symbols{chan+1}((baseInd+headerSymbols):(baseInd+headerSymbols+payloadCRCSymbols-1)), radix, 'gray', 'InputType','integer','UnitAveragePower',true);
        end
    end
end

%Find max and rms average values for header and payload constallations
%See http://rfmw.em.keysight.com/wireless/helpfiles/89600b/webhelp/subsystems/digdemod/Content/dlg_digdemod_comp_evmnormref.htm
%See http://rfmw.em.keysight.com/wireless/helpfiles/89600b/webhelp/subsystems/digdemod/Content/digdemod_symtblerrdata_evm.htm

headerMax = 0;
headerRMS = 0;

for pt = 0:(radixHeader-1)
    %Modulate header
    if radixHeader == 2
        modPt = pskmod(pt, 2);
    elseif radixHeader == 4
        modPt = pskmod(pt, 4, pi/4, 'gray');
    else
        modPt = qammod(pt, radixHeader, 'gray', 'InputType','integer','UnitAveragePower',true);
    end
    
    headerMax = max([headerMax, abs(modPt)]);
    headerRMS = headerRMS+abs(modPt)^2;
end
headerRMS = sqrt(headerRMS/radixHeader);

payloadMax = 0;
payloadRMS = 0;
for pt = 0:(radix-1)
    %Modulate payload
    if radix == 2
        modPt = pskmod(pt, 2);
    elseif radix == 4
        modPt = pskmod(pt, 4, pi/4, 'gray');
    else
        modPt = qammod(pt, radix, 'gray', 'InputType','integer','UnitAveragePower',true);
    end
    
    payloadMax = max([payloadMax, abs(modPt)]);
    payloadRMS = payloadRMS+abs(modPt)^2;
end
payloadRMS = sqrt(payloadRMS/radix);

disp(' ')

%% BER Comparison

%NOTE: The data is recieved in words that are packed into the highest radix
%symbol, in this case, it is 4 bits/symbol (16 QAM)
lengthMultiplier = 8/bitsPerSymbolMax;

effectiveOversmple = overSample*channelizerUpDownSampling/numChannels; %Due the channelizer, we are actually using more bandwidth than we usually would.
%Note that the oversample ratio the inverse of the ratio of signal
%bandwidth to overall bandwidth.
%Take the example of a 4 channelizer with an up/down sample by 2
%The upsample decreaces the faction of bandwidth used by a channel signal 
%to 1/8.  However, with 4 signals, the collective signal occupies 1/2 of
%the available bandwidth (plus some excess BW).

[EbN0, EsN0, idealBer, idealEVM] = getIdealBER(awgnSNR, effectiveOversmple, radix);

if(radixHeader >= 4)
    headerIdealBer = berawgn(EbN0, 'qam', radixHeader, 'nondiff');
else
    headerIdealBer = berawgn(EbN0, 'psk', radixHeader, 'nondiff');
end

%Decode the header
% PACKET FORMAT
% ###Header (BPSK)###
% # Modulation Type #  8 bits
% #*****************#
% #   Packet Type   #  8 bits
% #*****************#
% #       Src       #  8 bits
% #*****************#
% #       Dst       #  8 bits
% #*****************#
% #     Network     # 16 bits
% #       ID        #
% #*****************#
% #  Length (Bytes) # 16 bits
% #(w/o hdr or CRC) #
% ###################
% #     Payload     # len bytes
% #    (Modtype)    #
% #                 #
% ###################
% #      CRC        # 4 bytes
% #    (ModType)    #
% ###################

headerBitErrors = 0;
headerBits = 0;
payloadBitErrors = 0;
payloadBits = 0;
packetDecodeCompleteFailure = 0;
packetDecodeFailureDueToModulationFieldCorruption = 0;

if calcEVM
    headerErrorVector = [];
    payloadErrorVector = [];
    headerErrorVectorTR = [];
    payloadErrorVectorTR = [];
end

disp(['SNR (dB): ', num2str(awgnSNR), ', EbN0 (dB): ', num2str(EbN0)])

for chan=0:(numChannels-1)
    disp(['  Channel: ' num2str(chan)']);
    cursor = 1;
    symbolCursor = 1;
    expectedCursor = 1;
%     expectedSymbolCursor = 1;
    headerBitErrorsCh = 0;
    headerBitsCh = 0;
    payloadBitErrorsCh = 0;
    payloadBitsCh = 0;
    packetDecodeCompleteFailureCh = 0;
    packetDecodeFailureDueToModulationFieldCorruptionCh = 0;
    
    if calcEVM
        headerErrorVectorCh = [];
        payloadErrorVectorCh = [];
        headerErrorVectorTRCh = [];
        payloadErrorVectorTRCh = [];
    end
    
    for packet = 0:(packetsPerChannel-1)
        if cursor + header_len_bytes*lengthMultiplier-1 > length(data_recieved_packed{chan+1})
           %The header was not completely recieved, complete failure
           packetDecodeCompleteFailureCh = packetDecodeCompleteFailureCh+1;
%            disp(['    Channel: ' num2str(chan) ' Packet: ' num2str(packet) ' failed to decode']);
        else
            if lengthMultiplier ~= 2
                error('Header Decoding Needs to be updated for new packing');
            end
            modulationRx = data_recieved_packed{chan+1}(cursor) + data_recieved_packed{chan+1}(cursor+1)*2^4;
            
            %Perform the majority function because the modulation type is
            %repcoded
            modulationRxInt = uint8(modulationRx);
            
            repA = bitand(modulationRxInt, 3);
            repB = bitand(bitsrl(modulationRxInt, 2), 3);
            repC = bitand(bitsrl(modulationRxInt, 4), 3);
            
            modulationRxDecoded = bitor(bitor(bitand(repA, repB), bitand(repA, repC)), bitand(repB, repC));
            
            %if radixRx is not one of the supported radicies, the
            %length of the packet is taken by thresholding the index of
            %the modualtion scheme.  The other blocks in the decoder also
            %assume this modulation scheme
            if modulationRxDecoded > maxModType()
                modulationRxDecoded = maxModType(); 
            end
            
            radixRx = modTypeToRadix(modulationRxDecoded); 
            
            %Get the uncoded BER for the header
            headerBitErrorsLocal = biterr(data_recieved_packed{chan+1}(cursor:(cursor+header_len_bytes*lengthMultiplier-1)), expected_packed_data{chan+1}(expectedCursor:(expectedCursor+header_len_bytes*lengthMultiplier-1)));
            headerBERLocal = headerBitErrorsLocal/header_len_bytes*8;

            if calcEVM
                %Compute the Error Vectors for the header
                headerErrorVectorChTmp = expected_const_pts{chan+1}(expectedSymbolCursor:(expectedSymbolCursor+headerSymbols-1)) - symbols_recieved{chan+1}(symbolCursor:(symbolCursor+headerSymbols-1));
                headerErrorVectorTRChTmp = expected_const_pts{chan+1}(expectedSymbolCursor:(expectedSymbolCursor+headerSymbols-1)) - symbols_afterTR_recieved{chan+1}(symbolCursor:(symbolCursor+headerSymbols-1));
            end
            
            cursor = cursor + header_len_bytes*lengthMultiplier;
            symbolCursor = symbolCursor + headerSymbols;
            expectedCursor = expectedCursor + header_len_bytes*lengthMultiplier;
            
            if calcEVM
                expectedSymbolCursor = expectedSymbolCursor + headerSymbols;
            end
            
            headerBitErrorsCh = headerBitErrorsCh + headerBitErrorsLocal;
            headerBitsCh = headerBitsCh + header_len_bytes*8;
                        
            if calcEVM
                headerErrorVectorCh = cat(1, headerErrorVectorCh, headerErrorVectorChTmp);
                headerErrorVectorTRCh = cat(1, headerErrorVectorTRCh, headerErrorVectorTRChTmp);
            end

            %Check if decoded radix is different from expected radix
            if(radixRx ~= radix)
                packetDecodeFailureDueToModulationFieldCorruptionCh = packetDecodeFailureDueToModulationFieldCorruptionCh+1;
%                 disp(['    Channel: ' num2str(chan) ' Packet: ' num2str(packet) ' failed to decode due to an error in the modulation field of the header.  Header BER: ' num2str(headerBERLocal)]);
                
                %Advance cursor based on what the reciever thought the
                %radix was
                
                payloadLengthRx = fixedPayloadLength(radixRx);
                frameLengthLengthRx = payloadLengthRx + crc_len_bytes;
                cursor = cursor + frameLengthLengthRx*lengthMultiplier;
                expectedCursor = expectedCursor + frame_len_bytes*lengthMultiplier;
                
                if calcEVM
                    symbolCursor = symbolCursor + frameLengthLengthRx*8/radixRx; %This should be the same as symbolCursor + payloadCRCSymbols
                    expectedSymbolCursor = expectedSymbolCursor + payloadCRCSymbols;
                end
            else
                %Calculate BER for the payload

                if(cursor + frame_len_bytes*lengthMultiplier-1 > length(data_recieved_packed{chan+1}))
                    error('Length of recieved frame does not match length expected for given modulation scheme');
                else
                    payloadBitErrorsLocal = biterr(data_recieved_packed{chan+1}(cursor:(cursor+frame_len_bytes*lengthMultiplier-1)), expected_packed_data{chan+1}(expectedCursor:(expectedCursor+frame_len_bytes*lengthMultiplier-1)));
                    payloadBERLocal = payloadBitErrorsLocal/(frame_len_bytes*8); %It is possible the packed data is not completly filled
                    payloadBitErrorsCh = payloadBitErrorsCh + payloadBitErrorsLocal;
                    payloadBitsCh = payloadBitsCh + frame_len_bytes*8;

                    %Calculate Error vector for the payload
                    if calcEVM
                        payloadErrorVectorChTmp = expected_const_pts{chan+1}(expectedSymbolCursor:(expectedSymbolCursor+payloadCRCSymbols-1)) - symbols_recieved{chan+1}(symbolCursor:(symbolCursor+payloadCRCSymbols-1));
                        payloadErrorVectorTRChTmp = expected_const_pts{chan+1}(expectedSymbolCursor:(expectedSymbolCursor+payloadCRCSymbols-1)) - symbols_afterTR_recieved{chan+1}(symbolCursor:(symbolCursor+payloadCRCSymbols-1));

                        payloadErrorVectorCh = cat(1, payloadErrorVectorCh, payloadErrorVectorChTmp);
                        payloadErrorVectorTRCh = cat(1, payloadErrorVectorTRCh, payloadErrorVectorTRChTmp);
                        
                        evmHeader = rms(abs(headerErrorVectorChTmp))*100/headerRMS;
                        evmHeaderTR = rms(abs(headerErrorVectorTRChTmp))*100/headerRMS;
                        evmPayload = rms(abs(payloadErrorVectorChTmp))*100/payloadRMS;
                        evmPayloadTR = rms(abs(payloadErrorVectorTRChTmp))*100/payloadRMS;
                    end

                    cursor = cursor + frame_len_bytes*lengthMultiplier;
                    expectedCursor = expectedCursor + frame_len_bytes*lengthMultiplier;
                    
                    if calcEVM
                        symbolCursor = symbolCursor + payloadCRCSymbols;
                        expectedSymbolCursor = expectedSymbolCursor + payloadCRCSymbols;
                    end

                    disp(['    Packet: ' num2str(packet) ', BER (Header): ' num2str(headerBERLocal) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(payloadBERLocal) ' [Ideal: ' num2str(idealBer) ']']);
                    disp(['      Errors (Header): ' num2str(headerBitErrorsLocal) '/' num2str(header_len_bytes*8) ', Errors (Payload): ' num2str(payloadBitErrorsLocal) '/' num2str(frame_len_bytes*8)]);
                    
                    if calcEVM
                        disp(['      After TR: EVM (Header): ' num2str(evmHeaderTR) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayloadTR) ' [Ideal: ' num2str(idealEVM) ']']);
                        disp(['      B4 Demod: EVM (Header): ' num2str(evmHeader) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayload) ' [Ideal: ' num2str(idealEVM) ']']);
                    end
                end
            end
        end
    end
    
    %Report Channel & Accumulate Global Stats
    headerBitErrors = headerBitErrors + headerBitErrorsCh;
    headerBits = headerBits + headerBitsCh;
    payloadBitErrors = payloadBitErrors + payloadBitErrorsCh;
    payloadBits = payloadBits + payloadBitsCh;
    packetDecodeCompleteFailure = packetDecodeCompleteFailure + packetDecodeCompleteFailureCh;
    packetDecodeFailureDueToModulationFieldCorruption = packetDecodeFailureDueToModulationFieldCorruption + packetDecodeFailureDueToModulationFieldCorruptionCh;

    if calcEVM
        headerErrorVector = cat(1, headerErrorVector, headerErrorVectorCh);
        headerErrorVectorTR = cat(1, headerErrorVectorTR, headerErrorVectorTRCh);
        payloadErrorVector = cat(1, payloadErrorVector, payloadErrorVectorCh);
        payloadErrorVectorTR = cat(1, payloadErrorVectorTR, payloadErrorVectorTRCh);
        
        evmHeader = rms(abs(headerErrorVectorCh))*100/headerRMS;
        evmHeaderTR = rms(abs(headerErrorVectorTRCh))*100/headerRMS;
        evmPayload = rms(abs(payloadErrorVectorCh))*100/payloadRMS;
        evmPayloadTR = rms(abs(payloadErrorVectorTRCh))*100/payloadRMS;
    end

    headerBERCh = headerBitErrorsCh/headerBitsCh;
    payloadBERCh = payloadBitErrorsCh/payloadBitsCh;
%     disp(['    Channel Summary: Packet Decode Failures (Did Not Rx): ' num2str(packetDecodeCompleteFailureCh) ', Packet Decode Failures (Corrupted Modulation Fld): ' num2str(packetDecodeFailureDueToModulationFieldCorruptionCh)]);
%     disp(['      BER (Header): ' num2str(headerBERCh) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(payloadBERCh) ' [Ideal: ' num2str(idealBer) ']']);
%     disp(['      Errors (Header): ' num2str(headerBitErrorsCh) '/' num2str(headerBitsCh) ', Errors (Payload): ' num2str(payloadBitErrorsCh) '/' num2str(payloadBitsCh)]);
%     disp(['      After TR: EVM (Header): ' num2str(evmHeaderTR) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayloadTR) ' [Ideal: ' num2str(idealEVM) ']']);
%     disp(['      B4 Demod: EVM (Header): ' num2str(evmHeader) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayload) ' [Ideal: ' num2str(idealEVM) ']']);
end

%Report Overall

%Note, packets with complete or partial decode errors are not incuded
%in the BER calculation for the payload.  Packets with partial decode errors
%are included in the BER calculation for the header.  Packet failures
%are reported seperatly.

%Report Total
totalHeaderBer = headerBitErrors/headerBits;
totalPayloadBer = payloadBitErrors/payloadBits;

if calcEVM
    evmHeader = rms(abs(headerErrorVector))*100/headerRMS;
    evmHeaderTR = rms(abs(headerErrorVectorTR))*100/headerRMS;
    evmPayload = rms(abs(payloadErrorVector))*100/payloadRMS;
    evmPayloadTR = rms(abs(payloadErrorVectorTR))*100/payloadRMS;
end

if ~calcEVM
    %Return blanks
    evmHeader = 0;
    evmHeaderTR = 0;
    evmPayload = 0;
    evmPayloadTR = 0;
    payloadErrorVector = [];
    payloadErrorVectorTR = [];
end

% disp(['  Global Summary: Packet Decode Failures (Did Not Rx): ' num2str(packetDecodeCompleteFailure) ', Packet Decode Failures (Corrupted Modulation Fld): ' num2str(packetDecodeFailureDueToModulationFieldCorruption) ]);
% disp(['    BER (Header): ' num2str(totalHeaderBer) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(totalPayloadBer) ' [Ideal: ' num2str(idealBer) ']']);
% disp(['    Errors (Header): ' num2str(headerBitErrors) '/' num2str(headerBits) ', Errors (Payload): ' num2str(payloadBitErrors) '/' num2str(payloadBits)]);
% disp(['    After TR: EVM (Header): ' num2str(evmHeaderTR) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayloadTR) ' [Ideal: ' num2str(idealEVM) ']']);
% disp(['    B4 Demod: EVM (Header): ' num2str(evmHeader) ' [Ideal: ' num2str(idealEVM) '], EVM (Payload): ' num2str(evmPayload) ' [Ideal: ' num2str(idealEVM) ']']);

end