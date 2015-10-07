function [ packed_data ] = pack32( data_in )
%PACK32 Pack binary data into a 32 bit words
packed_data = uint32(zeros(ceil(length(data_in)/32), 1));

for i = 1:length(data_in)
    addr = idivide(i-1, uint32(32))+1;
    place = mod(i-1, 32);
    
    %Data is stored as little endian
    %Note that text is stored with big endian bit endiannes
    
    packed_data(addr) = packed_data(addr) + (2^place)*data_in(i);
end

end

