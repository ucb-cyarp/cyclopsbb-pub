%% Init
clear; close all; clc;

%% Import File
[after_cr_im,after_cr_re,selected_sample_i,selected_sample_q] = importChipscopeCSV('dc_blockers_and_software_rx_dc_offset_correction.csv');

%% Plot
number_pts = 20;
step = 20;
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
title_txt = 'After CR';
M_cr = plotConst(after_cr_re, after_cr_im, number_pts, step, const_pts, window_x, window_y, graph_y_lim, fig_size, title_txt);

f = figure('Position', [xpos, ypos, fig_size(1), fig_size(2)]);
movie(f, M_cr);

%% Selected Samples
title_txt = 'Selected Samples';
M_selected = plotConst(selected_sample_i, selected_sample_q, number_pts, step, const_pts, window_x, window_y, graph_y_lim, fig_size, title_txt);

f = figure('Position', [xpos, ypos, fig_size(1), fig_size(2)]);
movie(f, M_selected);