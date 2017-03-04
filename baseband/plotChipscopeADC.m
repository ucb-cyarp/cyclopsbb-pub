%% Init
clear; close all; clc;

%% Import File
[adc_pipeline_data_ch0,adc_pipeline_data_ch1,adc_piepline_valid] = importADCChipscopeCSV_v2('after_cr_delay_reduced_adc.csv');

%% Plot
number_pts = 50;
step = 25;
const_pts = complex([-1, 1]);
window_x = [-.75, .75];
window_y = [-.75, .75];
graph_y_lim = [-10, 10];
fig_size = [560*2, 420*2];

%Positioning from https://www.mathworks.com/matlabcentral/newsreader/view_thread/136464
screensize = get(0,'ScreenSize');
xpos = ceil((screensize(3)-fig_size(2))/2);
ypos = ceil((screensize(4)-fig_size(1))/2);

%% After CR
title_txt = 'ADC Raw Samples';
[M, midpt_i, midpt_q] = plotConst(adc_pipeline_data_ch0, adc_pipeline_data_ch1, number_pts, step, const_pts, window_x, window_y, graph_y_lim, fig_size, title_txt);

midpt_i
midpt_q

f = figure('Position', [xpos, ypos, fig_size(1), fig_size(2)]);
movie(f, M);