%% Check BER
clear; close all; clc;

warning off;

%Perform Initial Setup
rev0BB_startup;

model_name = 'rev0BB';

timestamp = datestr(now,'ddmmmyyyy-HH_MM_SSAM');

addpath(pwd);
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
load_system(model_name);


%% Sweep Parameters
trials = 1;
% dBSnrRange = -4:1:20;
dBSnrRange = [-3, 0, 3, 6, 10, 20, 30];
indRange = 1:1:length(dBSnrRange);

%freqOffsetHz = 0;
%txTimingOffset = 0;
% freqOffsetHz = 5000;
freqOffsetHz = 0;
txTimingOffset = 0;

%% Sweep

trial_bit_payload_errors = zeros(trials, length(indRange));
trial_bit_payload_bits_sent = zeros(trials, length(indRange));
trial_failures_complete = zeros(trials, length(indRange));
trial_failures_modulation_field_corrupted = zeros(trials, length(indRange));

%Avoid collisions from variables in berCalcPoint script
sim_idealBer = zeros(1, length(indRange));
sim_EbN0 = zeros(1, length(indRange));
sim_failures_complete = zeros(1, length(indRange));
sim_failures_modulation_field_corrupted = zeros(1, length(indRange));
sim_ber = zeros(1, length(indRange));

for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    
    %See https://www.mathworks.com/help/comm/ug/awgn-channel.html for a
    %consise explanation of the difference between SNR, EsN0, and EbN0
    effectiveOversmple = overSample*channelizerUpDownSampling/numChannels; %Due the channelizer, we are actually using more bandwidth than we usually would.
    [EbN0Loc, EsN0Loc, idealBerLoc] = getIdealBER(awgnSNR, effectiveOversmple, radix);
    
    sim_idealBer(dBSnrInd) = idealBerLoc;
    sim_EbN0(dBSnrInd) = EbN0Loc;
    disp(['SNR (dB): ', num2str(dBSnrRange(dBSnrInd)), ', EbN0 (dB): ', num2str(EbN0Loc), ', Ideal BER (AWGN): ', num2str(idealBerLoc)]);
    
    for trial = 1:1:trials
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        
        %Setup the Simulation
        rev0BB_startup_core; %Using the core function to avoid resetting workspace and overriding sweep parameters
        
        %Run BER Calc Point
        berCalcPoint;
        
        %Accumulate 
        
        trial_failures_complete(trial, dBSnrInd) = packetDecodeCompleteFailure;
        trial_failures_modulation_field_corrupted(trial, dBSnrInd) = packetDecodeFailureDueToModulationFieldCorruption;
        trial_bit_payload_errors(trial, dBSnrInd) = payloadBitErrors;
        trial_bit_payload_bits_sent(trial, dBSnrInd) = payloadBits;
    end
    
    sim_failures_complete(dBSnrInd) = sum(trial_failures_complete(:,dBSnrInd));
    sim_failures_modulation_field_corrupted(dBSnrInd) = sum(trial_failures_modulation_field_corrupted(:,dBSnrInd));
    sim_ber(dBSnrInd) = sum(trial_bit_payload_errors(:,dBSnrInd))/sum(trial_bit_payload_bits_sent(:,dBSnrInd));
end

%% Plot

fig1 = figure;
semilogy(sim_EbN0, sim_idealBer, 'b-');
hold all;
semilogy(sim_EbN0, sim_ber, 'r*-');
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Theoretical (AWGN)', ['Simulation (', channelSpec, ') - Header Excluded']);

title(['Baseband Simulation (', channelSpec, ') - Failures Excluded vs. Theoretical (Uncoded Coherent ' radixToModulationStr(radix) ' over AWGN)'])
grid on;

fig2 = figure;
sim_failures = [transpose(sim_failures_complete), transpose(sim_failures_modulation_field_corrupted)];
bar(sim_EbN0, sim_failures, 'stacked');
xlabel('Eb/N0 (dB)')
ylabel('Number of Packet Decode Failures (Stacked)')
legend('Complete Packet Decode Failure', 'Packet Decode Failure Due to Corrupted Modulation Field');
title(['Packet Decode Failures for ' num2str(trials) ' Trials'])
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

