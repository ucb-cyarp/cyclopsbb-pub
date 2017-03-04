%% Rev0BB


%% Init
clear; close all; clc;

%% Sim Params
disp('Setting Model Parameters ...')
rev0BB_setup;

%% Message

%simple_ascii_message;
%or
seed = 67;
[testMsg, testTextTrunkBin] = generate_random_frame(seed, dataLen, xCTRL_PRE_adj, after);

createTestVectors;

%% Imperfections
%freqOffsetHz = 0;
freqOffsetHz = -100000;

%qScale = 0.8631;
qScale = 1;

%awgnSNR = -6;
%awgnSNR = -3;
%awgnSNR = 0;
%awgnSNR = 2;
%awgnSNR = 5.5;
%awgnSNR = 6;
%awgnSNR = 8;
%awgnSNR = 12;
%awgnSNR = 24;
%awgnSNR = 92;
awgnSNR = 100;

%awgnSeed = 67;
awgnSeed = 245;


%txTimingOffset = 0.0002;
%txTimingOffset = -0.0001;
txTimingOffset = 0;

rng(awgnSeed);
txTimingPhase = rand(1);
rxPhaseOffset = rand(1)*360;

tx_rx_gain = 0.5882;

tx_impare_i_scale = 0.2822;
tx_impare_q_scale = 0.2822;
%tx_impare_i_offset = 0.0084*tx_rx_gain;
%tx_impare_q_offset = 0.1851*tx_rx_gain;
tx_impare_i_offset = 0;
tx_impare_q_offset = 0;

rx_impare_i_scale = 1;
rx_impare_q_scale = 1;
%rx_impare_i_offset = 0.0198;
%rx_impare_q_offset = -4.5168e-04;
rx_impare_i_offset = 0;
rx_impare_q_offset = 0;

%post_cr_i_offset = -tx_impare_i_offset/tx_rx_gain;
%post_cr_q_offset = -tx_impare_q_offset/tx_rx_gain;

post_cr_i_offset = 0;
post_cr_q_offset = 0;

%rx_offset_correction_i = -rx_impare_i_offset;
%rx_offset_correction_q = -rx_impare_q_offset;

rx_offset_correction_i = 0;
rx_offset_correction_q = 0;

lowfreq_osc_amp = 0;
lowfreq_osc_offset = .75;
lowfreq_osc_freq = 2e5;


%% Start Simulink
disp('Opening Simulink ...')
open_system('rev0BB')
%load_system('rev0BB')
disp('Ready to Simulate')
