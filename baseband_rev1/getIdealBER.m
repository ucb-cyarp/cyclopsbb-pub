function [EbN0, EsN0, idealBer, idealEVM] = getIdealBER(awgnSNR, effectiveOversmple, radix)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
EsN0 = awgnSNR + 10*log10(effectiveOversmple);
infoBitsPerSymbol = log2(radix); %Change when coding introduced
EbN0 = EsN0 - 10*log10(infoBitsPerSymbol);
if(radix >= 4)
    idealBer = berawgn(EbN0, 'qam', radix, 'nondiff');
else
    idealBer = berawgn(EbN0, 'psk', radix, 'nondiff');
end

%Compute ideal EVM
idealEVM = 10^(EsN0/(-20))*100; %TODO: Check.  Keysight equation used SNR but it seems too high (doing better than ideal).  Expect EsN0 is what was really was needed
%Based on 2.10 of
%https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=4136960, it looks
%like there is an assumptuon that Es/N0 = SNR which is not strictly
%speaking true

end

