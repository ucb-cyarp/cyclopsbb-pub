function type = maxModType(radixMax)
%MAXMODTYPE Get the max modulation type (modulation field in header
%(un-repcoded) based on the ma
%   Detailed explanation goes here

if(radixMax == 2) %BPSK
    type = 0;
elseif(radixMax == 4) %QPSK
    type = 1;
elseif(radixMax == 16) %16QAM
    type = 2;
elseif(radixMax == 256) %256QAM
    type = 3;
else
    error('Unknown Mod Type');
end

end

