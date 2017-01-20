%% Check BER
clear; close all; clc;

warning off;

addpath(pwd);
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
open_system('rev0BB');
%rev0BB_setup;

%% Init Model
trials = 30;
dBSnrRange = 5.5:.5:5.5;
indRange = 1:1:length(dBSnrRange);

rev0BB_setup;

freqOffsetFactor = 0;
txTimingOffset = 0;

iOffset = 0.01;
qOffset = 0.01;

for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    trial_result = zeros(1, length(indRange));
    
    for trial = 1:1:1
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        [testMsg, testTextTrunkBin] = generate_random_frame(seed, dataLen, xCTRL_PRE_adj, after);
        
        pad_first = 2000;

        mod_imperfection = zeros(pad_first, 1);
        testMsgFPGA = cat(1, mod_imperfection, testMsg);
        
        simX = struct();
        simX.time = [];
        simX.signals.values = testMsgFPGA;
        simX.signals.dimensions = 1;

        dataDelay = length(cat(1, xCTRL_PRE_adj)) + 1 + 187+360+1;%delay in computing
        
        idealX = struct();
        idealX.time = [];
        idealX.signals.values = cat(1, testTextTrunkBin, after);
        idealX.signals.dimensions = 1;
        
        simulink_out = sim('rev0BB', 'SimulationMode', 'normal');
        data_recieved = simulink_out.get('data_recieved');
        assignin('base','data_recieved',data_recieved);
        
        if(length(testTextTrunkBin) ~= length(data_recieved))
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
            bitErrors = inf;
        else
            delta = abs(double(data_recieved) - testTextTrunkBin);
            bitErrors = sum(delta);
            ber = bitErrors/length(data_recieved);
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Length: ', num2str(length(data_recieved))]);
        end
        
        trial_result(trial) = bitErrors;
    end
    

    sim_result(dBSnrInd) = sum(trial_result)/(trials*length(testTextTrunkBin));
    
    idealBer(dBSnrInd) = berawgn(dBSnrRange(dBSnrInd) + 10*log10(overSample), 'psk', 2, 'nondiff');
end

figure;
semilogy(dBSnrRange, idealBer);
hold all;
semilogy(dBSnrRange, sim_result);
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Ideal', 'Simulation');
title('Simulation vs. Ideal Accounting for Oversampling')
grid on;

figure;
semilogy(dBSnrRange, idealBer, 'bo');
hold all;
semilogy(dBSnrRange, sim_result, 'r*');
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Ideal', 'Simulation');
title('Simulation vs. Ideal Accounting for Oversampling')
grid on;

%close_system('rev0BB');
cd(currDir);
rmdir(tmpDir,'s');
rmpath(currDir);