%% Init
clear; close all; clc;

%% Import File
[adc_pipeline_data_ch0,adc_pipeline_data_ch1,adc_piepline_valid] = importADCChipscopeCSV('after_dc_offset_correction_lower_rx_gain_trial3_adc.csv');

%% Plot
number_pts = 50;
step = 50;
const_pts = complex([-1, 1]);
window_x = [-2, 2];
window_y = [-2, 2];
graph_y_lim = [-2, 3];
fig_size = [560*2, 420*2];

%Positioning from https://www.mathworks.com/matlabcentral/newsreader/view_thread/136464
screensize = get(0,'ScreenSize');
xpos = ceil((screensize(3)-fig_size(2))/2);
ypos = ceil((screensize(4)-fig_size(1))/2);

%% After CR
title_txt = 'ADC Raw Samples';
M_cr = plotConst(adc_pipeline_data_ch0, adc_pipeline_data_ch1, number_pts, step, const_pts, window_x, window_y, graph_y_lim, fig_size, title_txt);

f = figure('Position', [xpos, ypos, fig_size(1), fig_size(2)]);
movie(f, M_cr);