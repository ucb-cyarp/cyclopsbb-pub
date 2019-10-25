%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\git\cyclopsbb\baseband\unlocked_carrier_clock_success.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2017/02/21 11:21:28

%% Initialize variables.
filename = 'C:\git\cyclopsbb\baseband\unlocked_carrier_clock_success.csv';
delimiter = ',';

%% Format string for each line of text:
%   column6: text (%q)
%	column8: text (%q)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*q%*q%*q%*q%*q%q%*q%q%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
hex_bits = 16;
total_bits = 14;
frac_bits  = 11;

q_int = quantizer('mode', 'ufixed', [hex_bits, 0]);
q_frac = quantizer('mode', 'fixed', [total_bits, frac_bits]);

after_cr_im130_tmp = dataArray{:, 1};
after_cr_re130_tmp = dataArray{:, 2};
after_cr_im130_tmp = after_cr_im130_tmp(2:length(after_cr_im130_tmp));
after_cr_re130_tmp = after_cr_re130_tmp(2:length(after_cr_re130_tmp));

for i = 1:length(after_cr_im130_tmp)
    after_cr_im130(i) = bin2num(q_frac, num2bin(q_int, hex2dec(after_cr_im130_tmp(i))));
    after_cr_re130(i) = bin2num(q_frac, num2bin(q_int, hex2dec(after_cr_re130_tmp(i))));
    disp(num2str(i))
end


%% Clear temporary variables

clearvars filename delimiter formatSpec fileID dataArray ans i after_cr_im130_tmp after_cr_re130_tmp hex_bits total_bits frac_bits q_int q_frac;