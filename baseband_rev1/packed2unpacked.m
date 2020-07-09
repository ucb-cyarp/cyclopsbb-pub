function [ unpackedArray ] = packed2unpacked( packedArray, bitsPerWord, bitsPerSymbol )
%packed2unpacked Converts an array of packed bits (bytes or words) to an array of symbols
%   Endianess is assumed to be little endian (bit and byte)

unpackedArray = [];

if(mod(bitsPerWord, bitsPerSymbol) ~=0)
    error('packed2unpacked currenrly requies bitsPerWord to be a multiple of bitsPerSymbol')
end

for(i = 1:length(packedArray))
    %for each of these bytes, divide into symbols
    bitString = dec2bin(packedArray(i), bitsPerWord);
    
    for(j = 0:(bitsPerWord/bitsPerSymbol-1))
        %Note that the bit string has the MSB at bit 0
        %to preserve little endian, we need to start at
        %the end of the string
        stringSegment = bitString([(bitsPerWord-(j+1)*bitsPerSymbol+1):(bitsPerWord-j*bitsPerSymbol)]);
        unpackedSymbol = bin2dec(stringSegment);
        unpackedArray = [unpackedArray, unpackedSymbol];
    end
    
end

end

