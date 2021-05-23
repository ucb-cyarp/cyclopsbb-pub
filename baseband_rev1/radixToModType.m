function modType = radixToModType(radix, repcode)
%radixToModType Converts radix to the modType field in the Cyclops header
    if(radix == 2) %BPSK
        modType = 0;
    elseif(radix == 4) %QPSK
        if repcode
            modType = 21;
        else
            modType = 1;
        end
    elseif(radix == 16)%16QAM
        if repcode
            modType = 42;
        else
            modType = 2;
        end
    else
        if repcode %256QAM
            modType = 63;
        else
            modType = 3;
        end
    end
end

