%% Check BER
clear; close all; clc;

warning off;

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
%rev0BB_setup;

%% Init Model
trials = 10;
dBSnrRange = -4:1:20;
indRange = 1:1:length(dBSnrRange);

rev0BB_setup;

%freqOffsetHz = 0;
%txTimingOffset = 0;
freqOffsetHz = 5000;
txTimingOffset = 0;

iOffset = 0.00;
qOffset = 0.00;

trial_bit_errors = zeros(trials, length(indRange));
trial_failures = zeros(trials, length(indRange));

for dBSnrInd = indRange
    awgnSNR = dBSnrRange(dBSnrInd);
    
    %See https://www.mathworks.com/help/comm/ug/awgn-channel.html for a
    %consise explanation of the difference between SNR, EsN0, and EbN0
    EsN0 = dBSnrRange(dBSnrInd) + 10*log10(overSample);
    infoBitsPerSymbol = log2(radix); %Change when coding introduced
    EbN0 = EsN0 - 10*log10(infoBitsPerSymbol);
    idealBer(dBSnrInd) = berawgn(EbN0, 'psk', radix, 'nondiff');
    disp(['SNR (dB): ', num2str(dBSnrRange(dBSnrInd)), ', EbN0 (dB): ', num2str(EbN0), ', Ideal BER (AWGN): ', num2str(idealBer(dBSnrInd))]);
    
    for trial = 1:1:trials
        seed = abs(dBSnrRange(dBSnrInd)*1000+trial);
        awgnSeed = abs(dBSnrRange(dBSnrInd)*1000+trial+10000000);
        [testMsg, testTextTrunkRadix] = generate_random_frame(seed, payload_len_symbols, x_PRE_adj, after, radix, type, src, dst, len, crc_poly, crc_init, crc_xor);
        
        createTestVectors;
        
        rng(awgnSeed+100);
        txTimingPhase = rand(1);
        rxPhaseOffset = rand(1)*360;
        
        simulink_out = sim(model_name, 'SimulationMode', 'accelerator');
        data_recieved = simulink_out.get('data_recieved');
        assignin('base','data_recieved',data_recieved);
        
        if(length(testTextTrunkRadix) ~= length(data_recieved))
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' Recieved Data Length Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
            bitErrors = length(testTextTrunkRadix);
            failure = 1;
        else
            bitErrors = biterr(data_recieved, testTextTrunkRadix);
            ber = bitErrors/(log2(radix)*length(data_recieved));
            failure = 0;
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Length: ', num2str((log2(radix)*length(data_recieved)))]);
        end
        
        trial_failures(trial, dBSnrInd) = failure;
        trial_bit_errors(trial, dBSnrInd) = bitErrors;
    end
    
    sim_failures (dBSnrInd) = sum(trial_failures(:,dBSnrInd));
    sim_ber(dBSnrInd) = sum(trial_bit_errors(:,dBSnrInd))/(trials*(log2(radix)*length(data_recieved)));
end

%% Plot

fig1 = figure;
semilogy(dBSnrRange + 10*log10(overSample) - 10*log10(infoBitsPerSymbol), idealBer, 'b-');
hold all;
semilogy(dBSnrRange + 10*log10(overSample) - 10*log10(infoBitsPerSymbol), sim_ber, 'r*-');
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Theoretical (AWGN)', ['Simulation (', channelSpec, ')']);
title(['Baseband Simulation (', channelSpec, ') vs. Theoretical (Uncoded Coherent QPSK over AWGN)'])
grid on;

fig2 = figure;
bar(dBSnrRange + 10*log10(overSample) - 10*log10(infoBitsPerSymbol), sim_failures);
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

