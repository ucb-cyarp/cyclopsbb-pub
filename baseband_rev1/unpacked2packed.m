function [ packedArray ] = unpacked2packed(unpackedArray, bitsPerWord, bitsPerSymbol)
%packed2unpacked Converts an array of packed bits (bytes or words) to an array of symbols
%   Endianess is assumed to be little endian (bit and byte)

packedArray = zeros(1, ceil(length(unpackedArray)*bitsPerSymbol/bitsPerWord));

if(mod(bitsPerWord, bitsPerSymbol) ~=0)
    error('unpacked2packed currenrly requies bitsPerWord to be a multiple of bitsPerSymbol')
end

symbolsPerWord = bitsPerWord/bitsPerSymbol;

for(i = 0:(length(unpackedArray)-1))
    ind = floor(i/symbolsPerWord)+1; %indexes start at 1
    ind_internal = mod(i, symbolsPerWord);
    packedArray(ind) = packedArray(ind) + 2^(bitsPerSymbol*ind_internal)*unpackedArray(i+1); %indexes start at 1
end

end

