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
freqOffsetHz = 100000;

%qScale = 0.8631;
qScale = 1;

%awgnSNR = -6;
%awgnSNR = -3;
%awgnSNR = 0;
%awgnSNR = 5.5;
%awgnSNR = 6;
awgnSNR = 12;
%awgnSNR = 92;
%awgnSNR = 100;

awgnSeed = 67;

%txTimingOffset = 0.0002;
txTimingOffset = 0.0001;
%txTimingOffset = 0;

rng(awgnSeed);
txTimingPhase = rand(1);
rxPhaseOffset = rand(1)*360;

iOffset = 0.001;
qOffset = 0.001;



%% Start Simulink
disp('Opening Simulink ...')
open_system('rev0BB')
%load_system('rev0BB')
disp('Ready to Simulate')
