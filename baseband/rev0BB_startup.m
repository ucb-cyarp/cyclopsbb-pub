%% Rev0BB

%% Init
clear; close all; clc;

%% Sim Params
disp('Setting Model Parameters ...')
rev0BB_setup;

%% Start Simulink
disp('Opening Simulink ...')
open_system('rev0BB')
disp('Ready to Simulate')
