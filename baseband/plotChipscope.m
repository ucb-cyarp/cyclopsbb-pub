%% Init
clear; close all; clc;

%% Import File
[after_cr_im,after_cr_re,selected_sample_i,selected_sample_q,selected_sample_valid,strobe] = importChipscopeCSV_v4('agc_frozen_less_agressive_cr_carrier_locked.csv');
zero_ind_ss = find(~selected_sample_valid);
selected_sample_i(zero_ind_ss) = [];
selected_sample_q(zero_ind_ss) = [];
selected_sample_valid(zero_ind_ss) = [];
zero_ind_cr = find(~strobe);
after_cr_im(zero_ind_cr) = [];
after_cr_re(zero_ind_cr) = [];

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