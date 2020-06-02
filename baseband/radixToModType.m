function modType = radixToModType(radix)
%radixToModType Converts radix to the modType field in the Cyclops header
    if(radix == 2) %BPSK
        modType = 0;
    elseif(radix == 4) %QPSK
        modType = 1;
    elseif(radix == 16)%16QAM
        modType = 2;
    else
        modType = 3;
    end
end

