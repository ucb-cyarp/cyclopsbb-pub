%% Rev0BB

%% Init
clear; close all; clc;

%% Random Seeds
%seed = 67;
seed = 579;
%seed = 3997;
%seed = 15007;

awgnSeed = 67; %problem (decends but close to crossing point)
% awgnSeed = 68; %acends
% awgnSeed = 69;
% awgnSeed = 70; %decends
% awgnSeed = 10015007;
% awgnSeed = 245;
% awgnSeed = 300;
% awgnSeed = 400;
% awgnSeed = 9996003;

%% Tx Select
txChanEn = [false, true, false, false];
rxMonitorCh = 1;

%% Imperfections
maxDopplerHz = .1;
channelSpec = 'AWGN';
% channelSpec = 'Manual';
% channelSpec = 'cost207RAx4';
%Manual Delay Set
manualChanDelaysSymb = [1,6,11,16];
manualChanPathGainDB = [0,-3,-10,-20];
manualChanPathGain = [0.25, 0.25, 0.25, 0.25];

rxPhaseFixed = true;

%awgnSNR = -6;
% awgnSNR = -3;
% awgnSNR = 0;
% awgnSNR = 2;
%awgnSNR = 5.5;
% awgnSNR = 6;
%awgnSNR = 8;
% awgnSNR = 10;
% awgnSNR = 15;
% awgnSNR = 20;
awgnSNR = 30;
%awgnSNR = 50;
%awgnSNR = 92;
%awgnSNR = 100;
%awgnSNR = 1000;

freqOffsetHz = 0;
% freqOffsetHz = -1000;
% freqOffsetHz = 2000;
% freqOffsetHz = 5000;
%freqOffsetHz = 10000;
%freqOffsetHz = 20000;
%freqOffsetHz = 100000;

% txTimingOffset = 0.0002;
% txTimingOffset = -0.0001;
% txTimingOffset = 0.00001;
txTimingOffset = 0;

%% Setup Parameters
rev0BB_startup_core;

%% Start Simulink
disp('Opening Simulink ...')
%open_system('rev0BB')
%open_system('gm_rev0BB')
load_system('rev0BB')
disp('Ready to Simulate')
