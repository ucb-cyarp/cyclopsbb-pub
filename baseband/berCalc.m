%% Check BER
clear; close all; clc;

%% Init Model
rev0BB_startup;

simulink_out = sim('rev0BB', 'SimulationMode', 'normal');
data_recieved = simulink_out.get('data_recieved');
assignin('base','data_recieved',data_recieved);

disp(' ')

%% BER Comparison
if(length(testTextTrunkBin) ~= length(data_recieved))
    disp(['Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
else
    delta = abs(double(data_recieved) - testTextTrunkBin);
    bitErrors = sum(delta);
    ber = bitErrors/length(data_recieved);
    disp(['BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Length: ', num2str(length(data_recieved))]);
end