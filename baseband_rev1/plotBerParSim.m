%% Check BER
clear; close all; clc;

warning off;

%Perform Initial Setup
rev1BB_startup;

model_name = 'rev1BB';

reportName = 'BERvsEbN0';
timestamp = strrep(datestr(now,'ddmmmyyyy-HH_MM_SSAM'), ' ', '');

%Change to a temporary dir to perform the work
addpath(pwd);
currDir = pwd;
addpath(currDir);
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
load_system(model_name);


%% Sweep Parameters
trials = 15;
dBSnrRange = -2:1:18;
% dBSnrRange = [-3, 0, 3, 6, 10, 12, 15, 18, 21];
% dBSnrRange = [12, 15];
% dBSnrRange = [18];
indRange = 1:1:length(dBSnrRange);

rxPhaseFixed = true; %Disable for random carrier phase offset

% txChanEn = [true, true, true, true];
% rxMonitorCh = 1;

%freqOffsetHz = 0;
%txTimingOffset = 0;
% freqOffsetHz = 5000;
freqOffsetHz = 0;
txTimingOffset = 0;

%% Create Parameters for Sweep
simStartTime = datetime('now');

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

expected_packed_data_input = {};
expected_symbols_input = {};
numChannels_input = [];
packetsPerChannel_input = [];
header_len_bytes_input = [];
crc_len_bytes_input = [];
frame_len_bytes_input = [];
bitsPerSymbolHeader_input = [];
bitsPerSymbol_input = [];
radixHeader_input = [];
radix_input = [];
overSample_input = [];
bitsPerSymbolMax_input = [];
channelizerUpDownSampling_input = [];
awgnSNR_input = [];

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
    
    for trial = 1:1:trials
        configInd = (dBSnrInd-1)*(trials)+trial;
        
        simInputs(configInd) = Simulink.SimulationInput(model_name);
        
        disp(['Trial ' num2str(trial) ' of ' num2str(trials)]);
        
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        
        %Setup the Simulation
        rev1BB_simParams_setup; %Using the core function to avoid recomputing core radio configuration.  This will set up the packet and simulation parameters
        
        %Get Seed Vars
        simInputs(configInd) = simInputs(configInd).setVariable('seed', seed);
        simInputs(configInd) = simInputs(configInd).setVariable('awgnSeed', seed);
        %Get Packets To Send
        simInputs(configInd) = simInputs(configInd).setVariable('simX_ch0', simX_ch0);
        simInputs(configInd) = simInputs(configInd).setVariable('modX_ch0', modX_ch0);
        simInputs(configInd) = simInputs(configInd).setVariable('zeroX_ch0', zeroX_ch0);
%         simInputs(configInd) = simInputs(configInd).setVariable('simX_ch1', simX_ch1);
%         simInputs(configInd) = simInputs(configInd).setVariable('modX_ch1', modX_ch1);
%         simInputs(configInd) = simInputs(configInd).setVariable('zeroX_ch1', zeroX_ch1);
%         simInputs(configInd) = simInputs(configInd).setVariable('simX_ch2', simX_ch2);
%         simInputs(configInd) = simInputs(configInd).setVariable('modX_ch2', modX_ch2);
%         simInputs(configInd) = simInputs(configInd).setVariable('zeroX_ch2', zeroX_ch2);
%         simInputs(configInd) = simInputs(configInd).setVariable('simX_ch3', simX_ch3);
%         simInputs(configInd) = simInputs(configInd).setVariable('modX_ch3', modX_ch3);
%         simInputs(configInd) = simInputs(configInd).setVariable('zeroX_ch3', zeroX_ch3);
        simInputs(configInd) = simInputs(configInd).setVariable('tx_rx_gain', tx_rx_gain);
        simInputs(configInd) = simInputs(configInd).setVariable('txTimingPhase', txTimingPhase);
        simInputs(configInd) = simInputs(configInd).setVariable('txTimingOffset', txTimingOffset);
        simInputs(configInd) = simInputs(configInd).setVariable('rxPhaseOffset', rxPhaseOffset);
        simInputs(configInd) = simInputs(configInd).setVariable('freqOffsetHz', freqOffsetHz);
        simInputs(configInd) = simInputs(configInd).setVariable('channelFIR', channelFIR);
        simInputs(configInd) = simInputs(configInd).setVariable('awgnSNR', awgnSNR);
        simInputs(configInd) = simInputs(configInd).setVariable('manChan', manChan);
        simInputs(configInd) = simInputs(configInd).setVariable('chanDelays', chanDelays);
        simInputs(configInd) = simInputs(configInd).setVariable('chanAvgPathGainsdB', chanAvgPathGainsdB);
        simInputs(configInd) = simInputs(configInd).setVariable('maxDopplerHz', maxDopplerHz);
        
        %Set Radio setup parameters
        dumpConfigToSimulinkInput;
        
        %Set Rapid Accelerator.  Will be compiled once and used for all
        %workers.
        % See https://www.mathworks.com/help/simulink/slref/rapid-accelerator-simulations-using-parsim.html
%         simInputs(configInd) = simInputs(configInd).setModelParameter('SimulationMode', 'rapid', ...
%                 'RapidAcceleratorUpToDateCheck', 'off');

%         simInputs(configInd) = simInputs(configInd).setModelParameter('SimulationMode', 'rapid');
        simInputs(configInd) = simInputs(configInd).setModelParameter('SimulationMode', 'accelerator');
%         simInputs(configInd) = simInputs(configInd).setModelParameter('SimulationMode', 'normal');
            
        %Store 
        packetsPerChannel = 2;
        expected_packed_data_input{configInd, 1} = transpose(cat(2, header_payload_packed_ch0, header_payload_packed_ch0));
%         expected_packed_data_input{configInd, 1} = transpose(cat(2, header_payload_packed_ch0, header_payload_packed_ch0));
%         expected_packed_data_input{configInd, 2} = transpose(cat(2, header_payload_packed_ch1, header_payload_packed_ch1));
%         expected_packed_data_input{configInd, 3} = transpose(cat(2, header_payload_packed_ch2, header_payload_packed_ch2));
%         expected_packed_data_input{configInd, 4} = transpose(cat(2, header_payload_packed_ch3, header_payload_packed_ch3));

        expected_symbols_input{configInd, 1} = cat(1, headerPayloadCRCSymbols_ch0, headerPayloadCRCSymbols_ch0);
%         expected_symbols_input{configInd, 1} = cat(1, headerPayloadCRCSymbols_ch0, headerPayloadCRCSymbols_ch0);
%         expected_symbols_input{configInd, 2} = cat(1, headerPayloadCRCSymbols_ch1, headerPayloadCRCSymbols_ch1);
%         expected_symbols_input{configInd, 3} = cat(1, headerPayloadCRCSymbols_ch2, headerPayloadCRCSymbols_ch2);
%         expected_symbols_input{configInd, 3} = cat(1, headerPayloadCRCSymbols_ch3, headerPayloadCRCSymbols_ch4);
        
        numChannels_input(configInd) = numChannels;
        packetsPerChannel_input(configInd) = packetsPerChannel;
        header_len_bytes_input(configInd) = header_len_bytes;
        crc_len_bytes_input(configInd) = crc_len_bytes;
        frame_len_bytes_input(configInd) = frame_len_bytes;
        bitsPerSymbolHeader_input(configInd) = bitsPerSymbolHeader;
        bitsPerSymbol_input(configInd) = bitsPerSymbol;
        radixHeader_input(configInd) = radixHeader;
        radix_input(configInd) = radix;
        overSample_input(configInd) = overSample;
        bitsPerSymbolMax_input(configInd) = bitsPerSymbolMax;
        channelizerUpDownSampling_input(configInd) = channelizerUpDownSampling;
        awgnSNR_input(configInd) = awgnSNR;
    end
end

simEndTime = datetime('now');
simDuration = simEndTime - simStartTime;
disp(['Setup Simulink Inputs in ' char(simDuration)])

%% Start parpool
numcores = feature('numcores');
pool = parpool(numcores);
% pool = parpool(16);

%% Run the Simulations
simStartTime = datetime('now');

% parsimOut = parsim(simInputs, 'ShowProgress', 'on', 'SetupFcn', @() sldemo_parallel_rapid_accel_sims_script_setup(model_name));
parsimOut = parsim(simInputs, 'ShowProgress', 'on');

simEndTime = datetime('now');
simDuration = simEndTime - simStartTime;
disp(['Sim Ran in ' char(simDuration)])

%% Shutdown parpool
delete(pool);

%% Collect the Results
for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    
%     disp(['SNR (dB): ', num2str(dBSnrRange(dBSnrInd)), ', EbN0 (dB): ', num2str(EbN0Loc), ', Ideal BER (AWGN): ', num2str(idealBerLoc)]);
    
    finalErrorVector = [];
    afterTRErrorVector = [];
    
    payloadRMSLoc = 0;
    
    for trial = 1:1:trials
        configInd = (dBSnrInd-1)*(trials)+trial;
        
%         disp(['Trial ' num2str(trial) ' of ' num2str(trials)]);
        simulink_out = parsimOut(configInd);
        data_recieved_packed = {simulink_out.get('data_recieved_packed_ch0')};
        % data_recieved_packed = {simulink_out.get('data_recieved_packed_ch0'), ...
        %                         simulink_out.get('data_recieved_packed_ch1'), ...
        %                         simulink_out.get('data_recieved_packed_ch2'), ...
        %                         simulink_out.get('data_recieved_packed_ch3')};

        symbols_recieved = {simulink_out.get('data_recieved_constPt_ch0')};
        % symbols_recieved = {simulink_out.get('data_recieved_constPt_ch0'), ...
        %                     simulink_out.get('data_recieved_constPt_ch1'), ...
        %                     simulink_out.get('data_recieved_constPt_ch2'), ...
        %                     simulink_out.get('data_recieved_constPt_ch3')};

        symbols_afterTR_recieved = {simulink_out.get('data_recieved_afterTR_ch0')};
        % symbols_afterTR_recieved = {simulink_out.get('data_recieved_afterTR_ch0'), ...
        %                             simulink_out.get('data_recieved_afterTR_ch1'), ...
        %                             simulink_out.get('data_recieved_afterTR_ch2'), ...
        %                             simulink_out.get('data_recieved_afterTR_ch3')};
        
        %Parse the results
        [totalHeaderBer, totalPayloadBer, evmHeader, evmHeaderTR, evmPayload, evmPayloadTR, ...
         packetDecodeCompleteFailure, packetDecodeFailureDueToModulationFieldCorruption, ...
         payloadBitErrors, payloadBits, payloadErrorVector, payloadErrorVectorTR, payloadRMS] = ...
        berCalcPointParSim(data_recieved_packed, symbols_recieved, symbols_afterTR_recieved, ... %These should be cell arrays
                       expected_packed_data_input(configInd, :), expected_symbols_input(configInd, :), ...
                       numChannels_input(configInd), packetsPerChannel_input(configInd), ...
                       header_len_bytes_input(configInd), crc_len_bytes_input(configInd), frame_len_bytes_input(configInd), ...
                       bitsPerSymbolHeader_input(configInd), bitsPerSymbol_input(configInd), ...
                       radixHeader_input(configInd), radix_input(configInd), overSample_input(configInd), bitsPerSymbolMax_input(configInd), channelizerUpDownSampling_input(configInd), awgnSNR_input(configInd));
        
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
title({['Baseband Simulation (', channelSpec, ') - Failures Excluded (Modulation Field Rep3 Coded) vs.'], ['Theoretical (Uncoded Coherent ' radixToModulationStr(radix) ' over AWGN)']})
grid on;
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
if rxPhaseFixed
    plot(sim_EbN0, sim_afterTREvm, 'k*-');
end
xlabel('Eb/N0 (dB)')
ylabel('EVM % (Normalized to RMS of Constallation Pts)')
if rxPhaseFixed
    legend('Theoretical (AWGN)', ['EVM Before Demod (', channelSpec, ') - Header Excluded'], ['EVM After TR (', channelSpec, ') - Header Excluded']);
else
    legend('Theoretical (AWGN)', ['EVM Before Demod (', channelSpec, ') - Header Excluded']);
end
title({['Baseband Simulation (', channelSpec, ') - Failures Excluded (Modulation Field Rep3 Coded) vs.'], ['Theoretical (Uncoded Coherent ' radixToModulationStr(radix) ' over AWGN)']})
xlim(xlimits);
grid on;

%% Cleanup
%close_system('rev0BB');
cd(currDir);
%rmdir(tmpDir,'s');
rmpath(currDir);

%% Save

%Make a directory for the results
foldername = [reportName '_' timestamp];
mkdir(foldername);
cd(foldername);

%Save matlab figs
savefig(fig1, [reportName '_BER']);
savefig(fig2, [reportName '_Failures']);
savefig(fig3, [reportName '_EVM']);

%Save png versions
saveas(fig1, [reportName '_BER.png'])
saveas(fig2, [reportName '_Failures.png'])
saveas(fig3, [reportName '_EVM.png'])

%Save workspace
save([reportName '_workspace']);

cd(currDir);

