function [ out ] = reverse_endian8( in )
%PACK32 Unpack binary data from 32 bit words into 8 bit words.
out = zeros(size(in));

for i = 1:length(in)
    inval = in(i);
    for j = 1:8
        out(i) = out(i)*2+mod(idivide(inval, uint32(2^(j-1))), 2);
    end
        
end

end