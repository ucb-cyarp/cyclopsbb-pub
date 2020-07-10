%% Check BER
clear; close all; clc;

warning off;

%Perform Initial Setup
rev1BB_startup;

model_name = 'rev1BB';

timestamp = datestr(now,'ddmmmyyyy-HH_MM_SSAM');

addpath(pwd);
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
load_system(model_name);


%% Sweep Parameters
trials = 15;
% dBSnrRange = -4:1:20;
dBSnrRange = [-3, 0, 3, 6, 10, 12, 15, 18];
indRange = 1:1:length(dBSnrRange);

rxPhaseFixed = true; %Disable for random carrier phase offset

% txChanEn = [true, true, true, true];
% rxMonitorCh = 1;

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

sim_idealEvm = zeros(1, length(indRange));
sim_finalEvm = zeros(1, length(indRange));
sim_afterTREvm = zeros(1, length(indRange));

for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    
    %See https://www.mathworks.com/help/comm/ug/awgn-channel.html for a
    %consise explanation of the difference between SNR, EsN0, and EbN0
    effectiveOversmple = overSample*channelizerUpDownSampling/numChannels; %Due the channelizer, we are actually using more bandwidth than we usually would.
    [EbN0Loc, EsN0Loc, idealBerLoc, idealEVMLoc] = getIdealBER(awgnSNR, effectiveOversmple, radix);
    
    sim_idealBer(dBSnrInd) = idealBerLoc;
    sim_EbN0(dBSnrInd) = EbN0Loc;
    sim_idealEvm(dBSnrInd) = idealEVMLoc;
    
    disp(['SNR (dB): ', num2str(dBSnrRange(dBSnrInd)), ', EbN0 (dB): ', num2str(EbN0Loc), ', Ideal BER (AWGN): ', num2str(idealBerLoc)]);
    
    finalErrorVector = [];
    afterTRErrorVector = [];
    
    payloadRMSLoc = 0;
    
    for trial = 1:1:trials
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        
        %Setup the Simulation
        rev1BB_startup_core; %Using the core function to avoid resetting workspace and overriding sweep parameters
        
        %Run BER Calc Point
        berCalcPoint;
        
        if trial == 1
            payloadRMSLoc = payloadRMS;
        elseif payloadRMSLoc ~= payloadRMS
            error('Payload RMS Reference is not permitted to change durring BER sweep');
        end
        
        %Accumulate 
        trial_failures_complete(trial, dBSnrInd) = packetDecodeCompleteFailure;
        trial_failures_modulation_field_corrupted(trial, dBSnrInd) = packetDecodeFailureDueToModulationFieldCorruption;
        trial_bit_payload_errors(trial, dBSnrInd) = payloadBitErrors;
        trial_bit_payload_bits_sent(trial, dBSnrInd) = payloadBits;
        finalErrorVector = cat(1, finalErrorVector, payloadErrorVector);
        afterTRErrorVector = cat(1, afterTRErrorVector, payloadErrorVectorTR);
    end
    
    sim_failures_complete(dBSnrInd) = sum(trial_failures_complete(:,dBSnrInd));
    sim_failures_modulation_field_corrupted(dBSnrInd) = sum(trial_failures_modulation_field_corrupted(:,dBSnrInd));
    sim_ber(dBSnrInd) = sum(trial_bit_payload_errors(:,dBSnrInd))/sum(trial_bit_payload_bits_sent(:,dBSnrInd));
    
    sim_finalEvm(dBSnrInd) = rms(abs(finalErrorVector))*100/payloadRMSLoc;
    sim_afterTREvm(dBSnrInd) = rms(abs(afterTRErrorVector))*100/payloadRMSLoc;
end

%% Plot

%Get a smooth plot for ideal terms
idealPlotStep = 0.01;
minSNR = min(dBSnrRange);
maxSNR = max(dBSnrRange);
snrPlotRange = minSNR:idealPlotStep:maxSNR;

sim_EbN0_plot = zeros(size(snrPlotRange));
sim_idealBer_plot = zeros(size(snrPlotRange));
sim_idealEvm_plot = zeros(size(snrPlotRange));

for awgnSNRInd = 1:length(snrPlotRange)
    awgnSNR = snrPlotRange(awgnSNRInd);
    [EbN0Loc, EsN0Loc, idealBerLoc, idealEVMLoc] = getIdealBER(awgnSNR, effectiveOversmple, radix);
    sim_EbN0_plot(awgnSNRInd) = EbN0Loc;
    sim_idealBer_plot(awgnSNRInd) = idealBerLoc;
    sim_idealEvm_plot(awgnSNRInd) = idealEVMLoc;
end

fig1 = figure;
semilogy(sim_EbN0_plot, sim_idealBer_plot, 'b-');
hold all;
semilogy(sim_EbN0, sim_ber, 'r*-');
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Theoretical (AWGN)', ['Simulation (', channelSpec, ') - Header Excluded']);
title(['Baseband Simulation (', channelSpec, ') - Failures Excluded (Modulation Field Rep3 Coded) vs. Theoretical (Uncoded Coherent ' radixToModulationStr(radix) ' over AWGN)'])
grid minor;
xlimits = xlim;

fig2 = figure;
sim_failures = [transpose(sim_failures_complete), transpose(sim_failures_modulation_field_corrupted)];
bar(sim_EbN0, sim_failures, 'stacked');
xlabel('Eb/N0 (dB)')
ylabel('Number of Packet Decode Failures (Stacked)')
legend('Complete Packet Decode Failure', 'Packet Decode Failure Due to Corrupted Modulation Field');
title(['Packet Decode Failures for ' num2str(trials) ' Trials (Modulation Field Rep3 Coded)'])
xlim(xlimits);
grid on;

fig3 = figure;
plot(sim_EbN0_plot, sim_idealEvm_plot, 'b-');
hold all;
plot(sim_EbN0, sim_finalEvm, 'r*-');
plot(sim_EbN0, sim_afterTREvm, 'k*-');
xlabel('Eb/N0 (dB)')
ylabel('EVM % (Normalized to RMS of Constallation Pts)')
legend('Theoretical (AWGN)', ['EVM Before Demod (', channelSpec, ') - Header Excluded'], ['EVM After TR (', channelSpec, ') - Header Excluded']);
title(['Baseband Simulation (', channelSpec, ') - Failures Excluded (Modulation Field Rep3 Coded) vs. Theoretical (Uncoded Coherent ' radixToModulationStr(radix) ' over AWGN)'])
xlim(xlimits);
grid minor;

%% Cleanup
%close_system('rev0BB');
cd(currDir);
%rmdir(tmpDir,'s');
rmpath(currDir);

%% Save

savefig(fig1, ['BERvsEbN0-fig1-',timestamp]);
savefig(fig2, ['BERvsEbN0-fig2-',timestamp]);
savefig(fig3, ['BERvsEbN0-fig3-',timestamp]);
save(['BERvsEbN0-workspace-',timestamp]);

