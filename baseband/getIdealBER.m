function [EbN0, EsN0, idealBer] = getIdealBER(awgnSNR, effectiveOversmple, radix)
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
end

