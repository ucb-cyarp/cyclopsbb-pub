%Merge BER sweep plots for different conditions
%Using help from https://www.mathworks.com/matlabcentral/answers/100921-how-do-i-extract-data-points-from-a-plot

close all;

modName = '256QAM';

fig1Dir = './freqOffset0-timingOffset0_runs/cyclopsRev1_40_100Trials';
fig1Config   = 'No Timing Freq. Offset or CFO';
fig2Dir = './freqOffset20000-timingOffset0_00002_runs/cyclopsRev1_40_100Trials';
fig2Config   = '-1.6 KHz Timing Freq. Offset, 20 HKz CFO';

filesInDir1 = dir(fig1Dir);
outerDir1 = '';
for idx = 1:length(filesInDir1)
    file = filesInDir1(idx);
    if(file.isdir)
        if(~isempty(regexp(file.name, ['BERvsEbN0_' modName '_'], 'once')))
            outerDir1 = file.name;
        end
    end
end

if(isempty(outerDir1))
    error('Unable to find file1')
end

filesInDir2 = dir(fig2Dir);
outerDir2 = '';
for idx = 1:length(filesInDir2)
    file = filesInDir2(idx);
    if(file.isdir)
        if(~isempty(regexp(file.name, ['BERvsEbN0_' modName '_'], 'once')))
            outerDir2 = file.name;
        end
    end
end

if(isempty(outerDir2))
    error('Unable to find file2')
end

fig1Filename = [fig1Dir '/' outerDir1 '/' 'BERvsEbN0_' modName '_BER.fig'];
fig2Filename = [fig2Dir '/' outerDir2 '/' 'BERvsEbN0_' modName '_BER.fig'];

expectedTheoreticalBERName = 'Theoretical (AWGN)';
expectedSimulatedBERName   = 'Simulation (AWGN) - Header Excluded';

fig1 = openfig(fig1Filename);
fig2 = openfig(fig2Filename);

%Get axes
ax1 = findobj(fig1, 'Type', 'ax');
ax2 = findobj(fig2, 'Type', 'ax');


YLbl1 = ax1.YLabel.String;
XLbl1 = ax1.XLabel.String;
TitleTxt1 = ax1.Title.String;
YLbl2 = ax2.YLabel.String;
XLbl2 = ax2.XLabel.String;
TitleTxt2 = ax2.Title.String;

if(~strcmp(YLbl1, YLbl2))
    error('Label Mismatch')
end
if(~strcmp(XLbl1, XLbl2))
    error('Label Mismatch')
end

if((iscell(TitleTxt1) && ~iscell(TitleTxt1)) || (~iscell(TitleTxt1) && iscell(TitleTxt1)))
    if(strcmp(TitleTxt1, TitleTxt2))
        error('Label Mismatch')
    end
elseif(iscell(TitleTxt1))
    if(length(TitleTxt1) ~= length(TitleTxt2))
        error('Label Mismatch')
    end
    
    for idx = 1:length(TitleTxt1)
        if(~strcmp(TitleTxt1{idx}, TitleTxt2{idx}))
            error('Label Mismatch')
        end
    end
    
else
    if(~strcmp(TitleTxt1, TitleTxt2))
        error('Label Mismatch')
    end
end

% fig1TheoreticalX
% fig1TheoreticalY
% fig1SimulationX
% fig1SimulationY

h1 = findobj(ax1, 'Type', 'line');
for idx = 1:length(h1)
    lineLbl = h1(idx).DisplayName;
    if(strcmp(lineLbl, expectedTheoreticalBERName))
        fig1TheoreticalX = h1(idx).XData;
        fig1TheoreticalY = h1(idx).YData;
    elseif(strcmp(lineLbl, expectedSimulatedBERName))
        fig1SimulationX = h1(idx).XData;
        fig1SimulationY = h1(idx).YData;
    end
end

% fig2TheoreticalX
% fig2TheoreticalY
% fig2SimulationX
% fig2SimulationY

h2 = findobj(ax2, 'Type', 'line');
for idx = 1:length(h2)
    lineLbl = h2(idx).DisplayName;
    if(strcmp(lineLbl, expectedTheoreticalBERName))
        fig2TheoreticalX = h2(idx).XData;
        fig2TheoreticalY = h2(idx).YData;
    elseif(strcmp(lineLbl, expectedSimulatedBERName))
        fig2SimulationX = h2(idx).XData;
        fig2SimulationY = h2(idx).YData;
    end
end

if(~isequal(fig1TheoreticalX, fig2TheoreticalX))
    error('Theoretical X does not match');
end

if(~isequal(fig1TheoreticalY, fig2TheoreticalY))
    error('Theoretical Y does not match');
end

mergeFigure = figure;
semilogy(fig1TheoreticalX, fig1TheoreticalY, '-', 'Color', '#0072BD');
hold all;
semilogy(fig1SimulationX, fig1SimulationY, '-*', 'Color', '#D95319');
semilogy(fig2SimulationX, fig2SimulationY, '-o', 'Color', '#EDB120');
hold off;
title(TitleTxt1)
xlabel(XLbl1)
ylabel(YLbl1)
grid on;

legend(expectedTheoreticalBERName, [expectedSimulatedBERName ' [' fig1Config ']'], [expectedSimulatedBERName ' [' fig2Config ']'], 'Location', 'southwest');