%% Check BER
clear; close all; clc;

%% Init Model
rev0BB_startup;

simulink_out = sim('rev0BB', 'SimulationMode', 'accelerator');
data_recieved = simulink_out.get('data_recieved');
assignin('base','data_recieved',data_recieved);

disp(' ')

%% BER Comparison
if(length(payload) ~= length(data_recieved))
    disp(['Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
else
    %only for BPSK where each symbol is a bit
    %delta = abs(double(data_recieved) - payload);
    %bitErrors = sum(delta);
    %ber = bitErrors/length(data_recieved);
    
    %general, where symbols may contain multiple bits
    [bitErrors,ber] = biterr(double(data_recieved),payload);
    
    disp(['BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Symbol Count: ', num2str(length(data_recieved)), ', Bits: ', num2str(dataLen)]);
end