%% Rev0BB

%% Init
clear; close all; clc;

%% Modulation
radix = 4;

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

% seed = abs(18*1000+1);
% awgnSeed = abs(18*1000+1+10000000);

%% Imperfections
maxDopplerHz = .1;
channelSpec = 'AWGN';
% channelSpec = 'Manual';
% channelSpec = 'cost207RAx4';
%Manual Delay Set
manualChanDelaysSymb = [1,3,4,16];
manualChanPathGainDB = [0,-3,-10,-20];
manualChanPathGain = [0.7, 0.1, 0.2, 0.0];

rxPhaseFixed = false;

%awgnSNR = -6;
% awgnSNR = -3;
% awgnSNR = 0;
% awgnSNR = 2;
% awgnSNR = 5.5;
% awgnSNR = 6;
% awgnSNR = 8;
awgnSNR = 10;
% awgnSNR = 15;
% awgnSNR = 18;
% awgnSNR = 20;
% awgnSNR = 24;
% awgnSNR = 27;
% awgnSNR = 30;
% awgnSNR = 50;
%awgnSNR = 92;
% awgnSNR = 100;
%awgnSNR = 1000;

% freqOffsetHz = 0;
freqOffsetHz = -1000;
% freqOffsetHz = 2000;
% freqOffsetHz = 5000;
% freqOffsetHz = 10000;
%%freqOffsetHz = 20000;
% freqOffsetHz = 100000;

%%txTimingOffset = 0.00002;
txTimingOffset = 0.0002;
% txTimingOffset = -0.0001;
% txTimingOffset = 0.00001;
% txTimingOffset = 0;

%% Setup Parameters
rev1BB_startup_core;

%% Start Simulink
disp('Opening Simulink ...')
% open_system('rev1BB')
%open_system('gm_rev1BB')
load_system('rev1BB')
disp('Ready to Simulate')
