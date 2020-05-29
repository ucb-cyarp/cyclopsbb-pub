%% Check BER
clear; close all; clc;

%% Init Model
rev0BB_startup;

simulink_out = sim('rev0BB', 'SimulationMode', 'normal');
data_recieved_packed = {simulink_out.get('data_recieved_packed_ch0'), ...
                        simulink_out.get('data_recieved_packed_ch1'), ...
                        simulink_out.get('data_recieved_packed_ch2'), ...
                        simulink_out.get('data_recieved_packed_ch3')};

%For testing 2 packets in 1 sim (a duplicate of the generated packet)
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
bitErrorsTotal = 0;
bitsSentTotal = 0;

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

for chan=0:3
    if(length(expected_packed_data{chan+1}) ~= length(data_recieved_packed{chan+1}))
        disp(['Recieved Data Length Unexpected (', num2str(length(data_recieved_packed)), '): Possible that no data was recieved']);
    else
        bitErrors = biterr(data_recieved_packed{chan+1}, expected_packed_data{chan+1});
        ber = bitErrors/bitsSent{chan+1}; %It is possible the packed data is not completly filled
        bitErrorsTotal = bitErrorsTotal + bitErrors;
        bitsSentTotal = bitsSentTotal + bitsSent{chan+1};

        disp(['Channel ' num2str(chan) ': SNR (dB): ', num2str(awgnSNR), ', EbN0 (dB): ', num2str(EbN0), ', BER (Header + Payload): ', num2str(ber), ' [Ideal (Payload Only): ', num2str(idealBer), '], Errors: ', num2str(bitErrors), ', Length: ', num2str(bitsSent{chan+1})]);
    end
end

totalBer = bitErrorsTotal/bitsSentTotal;

disp(['All Channels: SNR (dB): ', num2str(awgnSNR), ', EbN0 (dB): ', num2str(EbN0), ', BER (Header + Payload): ', num2str(totalBer), ' [Ideal (Payload Only): ', num2str(idealBer), '], Errors: ', num2str(bitErrorsTotal), ', Length: ', num2str(bitsSentTotal)]);
