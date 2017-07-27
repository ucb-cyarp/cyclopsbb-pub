%% Check BER
clear; close all; clc;

warning off;

rev0BB_startup;

timestamp = datestr(now,'ddmmmyyyy-HH_MM_SSAM');

addpath(pwd);
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
load_system('gm_rev0BB');
%rev0BB_setup;

%% Init Model
trials = 1000;
dBSnrRange = -4:1:5;
indRange = 1:1:length(dBSnrRange);

rev0BB_setup;

%freqOffsetHz = 0;
%txTimingOffset = 0;
freqOffsetHz = 100000;
txTimingOffset = -0.0001;

iOffset = 0.01;
qOffset = 0.01;

trial_bit_errors = zeros(trials, length(indRange));
trial_failures = zeros(trials, length(indRange));

for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    
    for trial = 1:1:trials
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        [testMsg, testTextTrunkBin] = generate_random_frame(seed, dataLen, x_PRE_adj, after);
        
        rng(awgnSeed+100);
        txTimingPhase = rand(1);
        rxPhaseOffset = rand(1)*360;
        
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
        
        simulink_out = sim('gm_rev0BB', 'SimulationMode', 'rapid');
        data_recieved = simulink_out.get('data_recieved');
        assignin('base','data_recieved',data_recieved);
        
        if(length(testTextTrunkBin) ~= length(data_recieved))
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
            bitErrors = length(testTextTrunkBin);
            failure = 1;
        else
            delta = abs(double(data_recieved) - testTextTrunkBin);
            bitErrors = sum(delta);
            ber = bitErrors/length(data_recieved);
            failure = 0;
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Length: ', num2str(length(data_recieved))]);
        end
        
        trial_failures(trial, dBSnrInd) = failure;
        trial_bit_errors(trial, dBSnrInd) = bitErrors;
    end
    
    sim_failures (dBSnrInd) = sum(trial_failures(:,dBSnrInd));
    sim_ber(dBSnrInd) = sum(trial_bit_errors(:,dBSnrInd))/(trials*length(testTextTrunkBin));
    
    idealBer(dBSnrInd) = berawgn(dBSnrRange(dBSnrInd) + 10*log10(overSample), 'psk', 2, 'nondiff');
end

%% Plot

fig1 = figure;
semilogy(dBSnrRange + 10*log10(overSample), idealBer, 'b-');
hold all;
semilogy(dBSnrRange + 10*log10(overSample), sim_ber, 'r*-');
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Theoretical', 'Simulation');
title('Baseband Simulation vs. Theoretical (Uncoded Coherent BPSK over AWGN)')
grid on;

fig2 = figure;
bar(dBSnrRange + 10*log10(overSample), sim_failures);
xlabel('Eb/N0 (dB)')
ylabel('Number of Packet Decode Failures')
title(['Number of Packet Decode Failures (No Valid Frame Detected) for ' num2str(trials), ' Trials'])
grid on;


%% Cleanup
%close_system('rev0BB');
cd(currDir);
%rmdir(tmpDir,'s');
rmpath(currDir);

%% Save

savefig(fig1, ['BERvsEbN0-fig1-',timestamp]);
savefig(fig2, ['BERvsEbN0-fig2-',timestamp]);
save(['BERvsEbN0-workspace-',timestamp]);

