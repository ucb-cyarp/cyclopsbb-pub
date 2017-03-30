%% Rev0BB


%% Init
clear; close all; clc;

%% Sim Params
disp('Setting Model Parameters ...')
rev0BB_setup;

%% Message

%simple_ascii_message;
%or
%seed = 67;
seed = 579;
[testMsg, testTextTrunkBin] = generate_random_frame(seed, dataLen, xCTRL_PRE_adj, after);

createTestVectors;

%% Imperfections

dc_block_passband = 0.1; %MHz

%freqOffsetHz = 0;
freqOffsetHz = 100000;

%qScale = 0.8631;
qScale = 1;

%awgnSNR = -6;
%awgnSNR = -3;
%awgnSNR = 0;
%awgnSNR = 2;
%awgnSNR = 5.5;
%awgnSNR = 6;
%awgnSNR = 8;
awgnSNR = 12;
%awgnSNR = 24;
%awgnSNR = 92;
%awgnSNR = 100;

%awgnSeed = 67;
awgnSeed = 245;


%txTimingOffset = 0.0002;
%txTimingOffset = -0.0001;
txTimingOffset = 0;

rng(awgnSeed);
txTimingPhase = rand(1);
rxPhaseOffset = rand(1)*360;

%tx_rx_gain = 0.5882;
tx_rx_gain = 1;

tx_impare_i_scale = 1;
tx_impare_q_scale = 1;
%tx_impare_i_scale = 0.2822;
%tx_impare_q_scale = 0.2822;
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

rx_offset_correction_i = -0.3801;
rx_offset_correction_q = -0.2840;

%rx_offset_correction_i = -0.39;
%rx_offset_correction_q = -0.27;

agc_on = true;
freeze_on_stf_done  = true;
freeze_on_cef_done  = true;
freeze_on_valid     = true;

freeze_en_agc       = true;
freeze_en_tr_phase  = false;
freeze_en_tr_int1   = false;
freeze_en_tr_int2   = false;
freeze_en_cr_int2   = false;
freeze_en_cr_phase  = false;
freeze_en_cr_int1   = false;


cal_sig_i_mult = 1.0;
cal_sig_q_mult = 1.0;
cal_sig_i_offset = 0.0;
cal_sig_q_offset = 0.0;

%% Raw From ADC
load adc_raw_data.mat

raw_adc_ch0.time = [];
raw_adc_ch0.signals.values = transpose(adc_pipeline_data_ch0);
raw_adc_ch0.signals.dimensions = 1;

raw_adc_ch1.time = [];
raw_adc_ch1.signals.values = transpose(adc_pipeline_data_ch1);
raw_adc_ch1.signals.dimensions = 1;

load selected_samples_captured.mat

ss_ch0.time = [];
ss_ch0.signals.values = transpose(selected_sample_i);
ss_ch0.signals.dimensions = 1;

ss_ch1.time = [];
ss_ch1.signals.values = transpose(selected_sample_q);
ss_ch1.signals.dimensions = 1;


%% Start Simulink
disp('Opening Simulink ...')
open_system('rev0BB')
%load_system('rev0BB')
disp('Ready to Simulate')
