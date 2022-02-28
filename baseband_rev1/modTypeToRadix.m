function radix = modTypeToRadix(modType)
%radixToModType Converts radix to the modType field in the Cyclops header
    if(modType == 0) %BPSK
        radix = 2;
    elseif(modType == 1) %QPSK
        radix = 4;
    elseif(modType == 2) %16QAM
        radix = 16;
    elseif(modType == 3) %256QAM
        radix = 256;
    else
        radix = 0;
    end
end

