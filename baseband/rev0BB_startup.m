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
freqOffsetFactor = 0.001;
%freqOffsetFactor = 0.0001;
%freqOffsetFactor = 0;
%freqOffsetFactor = 0.004;
awgnSNR = 5.5;
awgnSeed = 67;

%txTimingOffset = 0.0002;
txTimingOffset = 0.0001;
%txTimingOffset = 0;

iOffset = 0.01;
qOffset = 0.01;



%% Start Simulink
disp('Opening Simulink ...')
open_system('rev0BB')
%load_system('rev0BB')
disp('Ready to Simulate')
