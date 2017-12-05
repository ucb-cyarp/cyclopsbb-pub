%% Check BER
clear; close all; clc;

%% Init Model
rev0BB_startup;

simulink_out = sim('gm_rev0BB', 'SimulationMode', 'normal');
data_recieved = simulink_out.get('data_recieved');
assignin('base','data_recieved',data_recieved);

disp(' ')

%% BER Comparison
if(length(testTextTrunkRadix) ~= length(data_recieved))
    disp(['Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
else
    bitErrors = biterr(data_recieved, testTextTrunkRadix);
    ber = bitErrors/(log2(radix)*length(data_recieved));
    
    EsN0 = awgnSNR + 10*log10(overSample);
    infoBitsPerSymbol = log2(radix); %Change when coding introduced
    EbN0 = EsN0 - 10*log10(infoBitsPerSymbol);
    if(radix >= 4)
        idealBer = berawgn(EbN0, 'qam', radix, 'nondiff');
    else
        idealBer = berawgn(EbN0, 'psk', radix, 'nondiff');
    end
    
    disp(['SNR (dB): ', num2str(awgnSNR), ', EbN0 (dB): ', num2str(EbN0), ', BER: ', num2str(ber), ' [Ideal: ', num2str(idealBer), '], Errors: ', num2str(bitErrors), ', Length: ', num2str(log2(radix)*length(data_recieved))]);
end