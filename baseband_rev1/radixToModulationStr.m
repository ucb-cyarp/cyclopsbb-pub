function str = radixToModulationStr(radix)
%radixToModulationStr Get the human readable name for modulation
if radix == 2
    str = 'BPSK';
elseif radix == 4
    str = 'QPSK';
elseif radix == 16
    str = '16QAM';
elseif radix == 256
    str = '256QAM';
else
    str = 'UNKNOWN';
end
end

