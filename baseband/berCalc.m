%% Check BER
clear; close all; clc;

%% Init Model
rev0BB_startup;

% header_len_bytes gives the header length in bytes
% payload_len_bytes gives the payload length
% crc_len_bytes gives the CRC length in bytes
% frame_len_bytes gives the payload + crc length in bytes

if header_len_bytes ~= 8
    error('Header length is unexpected');
end 

simStartTime = datetime('now');
simulink_out = sim('rev0BB', 'SimulationMode', 'rapid');
data_recieved_packed = {simulink_out.get('data_recieved_packed_ch0'), ...
                        simulink_out.get('data_recieved_packed_ch1'), ...
                        simulink_out.get('data_recieved_packed_ch2'), ...
                        simulink_out.get('data_recieved_packed_ch3')};
simEndTime = datetime('now');
simDuration = simEndTime - simStartTime;
disp(['Sim Ran in ' char(simDuration)])

%For testing 2 packets in 1 sim (a duplicate of the generated packet)
packetsPerChannel = 2;
expected_packed_data = {transpose(cat(2, header_payload_packed_ch0, header_payload_packed_ch0)), ...
                        transpose(cat(2, header_payload_packed_ch1, header_payload_packed_ch1)), ...
                        transpose(cat(2, header_payload_packed_ch2, header_payload_packed_ch2)), ...
                        transpose(cat(2, header_payload_packed_ch3, header_payload_packed_ch3))};
                    
bitsSent = {2*transmittedBits_ch0, ...
            2*transmittedBits_ch1, ...
            2*transmittedBits_ch2, ...
            2*transmittedBits_ch3};

disp(' ')

%% BER Comparison

effectiveOversmple = overSample*channelizerUpDownSampling/numChannels; %Due the channelizer, we are actually using more bandwidth than we usually would.
%Note that the oversample ratio the inverse of the ratio of signal
%bandwidth to overall bandwidth.
%Take the example of a 4 channelizer with an up/down sample by 2
%The upsample decreaces the faction of bandwidth used by a channel signal 
%to 1/8.  However, with 4 signals, the collective signal occupies 1/2 of
%the available bandwidth (plus some excess BW).
EsN0 = awgnSNR + 10*log10(effectiveOversmple);
infoBitsPerSymbol = log2(radix); %Change when coding introduced
EbN0 = EsN0 - 10*log10(infoBitsPerSymbol);
if(radix >= 4)
    idealBer = berawgn(EbN0, 'qam', radix, 'nondiff');
else
    idealBer = berawgn(EbN0, 'psk', radix, 'nondiff');
end

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

disp(['SNR (dB): ', num2str(awgnSNR), ', EbN0 (dB): ', num2str(EbN0)])

for chan=0:3
    disp(['  Channel: ' num2str(chan)']);
    cursor = 1;
    expectedCursor = 1;
    headerBitErrorsCh = 0;
    headerBitsCh = 0;
    payloadBitErrorsCh = 0;
    payloadBitsCh = 0;
    packetDecodeCompleteFailureCh = 0;
    packetDecodeFailureDueToModulationFieldCorruptionCh = 0;
    
    for packet = 0:(packetsPerChannel-1)
        if cursor + header_len_bytes-1 > length(data_recieved_packed{chan+1})
           %The header was not completely recieved, complete failure
           packetDecodeCompleteFailureCh = packetDecodeCompleteFailureCh+1;
%            disp(['    Channel: ' num2str(chan) ' Packet: ' num2str(packet) ' failed to decode']);
        else
            modulationRx = data_recieved_packed{chan+1}(cursor);
            radixRx = modTypeToRadix(modulationRx);
            
            %Get the uncoded BER for the header
            headerBitErrorsLocal = biterr(data_recieved_packed{chan+1}(cursor:(cursor+header_len_bytes-1)), expected_packed_data{chan+1}(expectedCursor:(expectedCursor+header_len_bytes-1)));
            headerBERLocal = headerBitErrorsLocal/header_len_bytes*8;
            
            cursor = cursor + header_len_bytes;
            expectedCursor = expectedCursor + header_len_bytes;
            
            headerBitErrorsCh = headerBitErrorsCh + headerBitErrorsLocal;
            headerBitsCh = headerBitsCh + header_len_bytes*8;

            %Check if decoded radix is different from expected radix
            if(radixRx ~= radix)
                packetDecodeFailureDueToModulationFieldCorruptionCh = packetDecodeFailureDueToModulationFieldCorruptionCh+1;
%                 disp(['    Channel: ' num2str(chan) ' Packet: ' num2str(packet) ' failed to decode due to an error in the modulation field of the header.  Header BER: ' num2str(headerBERLocal)]);
                
                %Advance cursor based on what the reciever thought the
                %radix was
                payloadLengthRx = fixedPayloadLength(radixRx);
                frameLengthLengthRx = payloadLengthRx + crc_len_bytes;
                cursor = cursor + frameLengthLengthRx;
                expectedCursor = expectedCursor + frame_len_bytes;
            else
                %Calculate BER for the payload

                if(cursor + frame_len_bytes-1 > length(data_recieved_packed{chan+1}))
                    error('Length of recieved frame does not match length expected for given modulation scheme');
                else
                    payloadBitErrorsLocal = biterr(data_recieved_packed{chan+1}(cursor:(cursor+frame_len_bytes-1)), expected_packed_data{chan+1}(expectedCursor:(expectedCursor+frame_len_bytes-1)));
                    payloadBERLocal = payloadBitErrorsLocal/frame_len_bytes*8; %It is possible the packed data is not completly filled
                    payloadBitErrorsCh = payloadBitErrorsCh + payloadBitErrorsLocal;
                    payloadBitsCh = payloadBitsCh + frame_len_bytes*8;
                    cursor = cursor + frame_len_bytes;
                    expectedCursor = expectedCursor + frame_len_bytes;

                    disp(['    Packet: ' num2str(packet) ', BER (Header): ' num2str(headerBERLocal) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(payloadBERLocal) ' [Ideal: ' num2str(idealBer) '], Errors (Header): ' num2str(headerBitErrorsLocal) '/' num2str(header_len_bytes*8) ', Errors (Payload): ' num2str(payloadBitErrorsLocal) '/' num2str(frame_len_bytes*8)]);
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

    headerBERCh = headerBitErrorsCh/headerBitsCh;
    payloadBERCh = payloadBitErrorsCh/payloadBitsCh;
    disp(['    Channel Summary: Packet Decode Failures (Did Not Rx): ' num2str(packetDecodeCompleteFailureCh) ', Packet Decode Failures (Corrupted Modulation Fld): ' num2str(packetDecodeFailureDueToModulationFieldCorruptionCh) ', BER (Header): ' num2str(headerBERCh) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(payloadBERCh) ' [Ideal: ' num2str(idealBer) '], Errors (Header): ' num2str(headerBitErrorsCh) '/' num2str(headerBitsCh) ', Errors (Payload): ' num2str(payloadBitErrorsCh) '/' num2str(payloadBitsCh)]);

end

%Report Overall

%Note, packets with complete or partial decode errors are not incuded
%in the BER calculation for the payload.  Packets with partial decode errors
%are included in the BER calculation for the header.  Packet failures
%are reported seperatly.

%Report Total
totalHeaderBer = headerBitErrors/headerBits;
totalPayloadBer = payloadBitErrors/payloadBits;
disp(['  Global Summary: Packet Decode Failures (Did Not Rx): ' num2str(packetDecodeCompleteFailure) ', Packet Decode Failures (Corrupted Modulation Fld): ' num2str(packetDecodeFailureDueToModulationFieldCorruption) ', BER (Header): ' num2str(totalHeaderBer) ' [Ideal: ' num2str(headerIdealBer) '], BER (Payload): ' num2str(totalPayloadBer) ' [Ideal: ' num2str(idealBer) '], Errors (Header): ' num2str(headerBitErrors) '/' num2str(headerBits) ', Errors (Payload): ' num2str(payloadBitErrors) '/' num2str(payloadBits)]);
    