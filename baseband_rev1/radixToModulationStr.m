function str = radixToModulationStr(radix)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
if radix == 2
    str = 'BPSK';
elseif radix == 4
    str = 'QPSK';
elseif radix == 16
    str = '16QAM';
else
    str = 'UNKNOWN';
end
end

