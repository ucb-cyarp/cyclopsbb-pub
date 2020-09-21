%% Rev1BB - Startup Core
%This script sets the core workspace variables for the cyclopsBB
%simulation.  Many of the cyclops radio parameters are set in rev0BB_setup
%This script does not reset the state of the workspace, nor does it set
%some key parameters.  It does this so that rev0_startup_core can be used
%in parameter sweeps.

%% Parameters that must be set elsewhere 
% seed: random seed used for random packet generation random number seed
%
% channelSpec: used to set the channel 
%   Example Config
%   maxDopplerHz = .1;
%   channelSpec = 'AWGN';
%   %channelSpec = 'Manual';
%   %channelSpec = 'cost207RAx4';
%   %Manual Delay Set
%   manualChanDelaysSymb = [1,6,11,16];
%   manualChanPathGainDB = [0,-3,-10,-20];
%   manualChanPathGain = [0.25, 0.25, 0.25, 0.25];
%
% freqOffsetHz: CFO Frequency Offset in Hz
% 
% awgnSNR: SNR of AWGN Channel (in dB)
%
% awgnSeed: random seed used for channel
%
% txTimingOffset: The frequency offset of the sample clock (in fractions of
%                 the nominal sample.

%% Sim Params
disp('Setting Model Parameters ...')
rev1BB_setup;

disp(['Payload+Header Length (Symbols) = ', num2str(dataLenSymbols)])

%% Setup Channelizer
% setup_channelizer;

%Or, when running single channel, declare numChannels to 1 and
%channelizerUpDownSampling to 1
numChannels = 1;
channelizerUpDownSampling = 1;

%% Generate Packet & Sim Parameters
rev1BB_simParams_setup;