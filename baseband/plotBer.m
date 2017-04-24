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
load_system('rev0BB');
%rev0BB_setup;

%% Init Model
trials = 100;
dBSnrRange = -2:1:4;
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
        
        %Modulation
        %0 = Zeros (ie. transmit nothing)
        %1 = BPSK
        %2 = QPSK
        %3 = 16QAM
        payload_modulation = 1;
        header = [0; 0; 0; 1]; % 4 bit (4 symbols in BPSK) field specifying modulation type
        payload = generate_random_payload(seed, dataLen, 2^(payload_modulation-1));

        testMsg = cat(1, xCTRL_PRE_adj, header, payload);

        createTestVectors;
        
        rng(awgnSeed+100);
        txTimingPhase = rand(1);
        rxPhaseOffset = rand(1)*360;
        
        %pad_first = 2000;

        %mod_imperfection = zeros(pad_first, 1);
        %testMsgFPGA = cat(1, mod_imperfection, testMsg);
        
        simulink_out = sim('rev0BB', 'SimulationMode', 'rapid');
        data_recieved = simulink_out.get('data_recieved');
        assignin('base','data_recieved',data_recieved);
        
        if(length(payload) ~= length(data_recieved))
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' Recieved Data Length (Symbols) Unexpected (', num2str(length(data_recieved)), '): Likely that no data was recieved']);
            bitErrors = dataLen;
            failure = 1;
        else
            %delta = abs(double(data_recieved) - testTextTrunkBin);
            %bitErrors = sum(delta);
            %ber = bitErrors/length(data_recieved);
            [bitErrors,ber] = biterr(double(data_recieved),payload);
            failure = 0;
            disp(['SNR: ', num2str(dBSnrRange(dBSnrInd)),' Trial: ', num2str(trial), ' BER: ', num2str(ber), ', Errors: ', num2str(bitErrors), ', Symbols: ', num2str(length(data_recieved)), ', Bits: ', num2str(dataLen)]);
        end
        
        trial_failures(trial, dBSnrInd) = failure;
        trial_bit_errors(trial, dBSnrInd) = bitErrors;
    end
    
    sim_failures (dBSnrInd) = sum(trial_failures(:,dBSnrInd));
    sim_ber(dBSnrInd) = sum(trial_bit_errors(:,dBSnrInd))/(trials*dataLen);
    
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
title('Baseband Simulation vs. Theoretical (Uncoded Coherent 16 QAM over AWGN)')
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

