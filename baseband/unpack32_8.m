function [ unpacked_data ] = unpack32_8( packed_data )
%PACK32 Unpack binary data from 32 bit words into 8 bit words.
unpacked_data = zeros(length(packed_data)*4, 1);

for i = 1:length(unpacked_data)
    addr = idivide(i-1, uint32(4))+1;
    place = mod(i-1, 4);
    
    %Data is stored as little endian
    %Note that text is stored with big endian bit endiannes
    
    pdata = packed_data(addr);
    
    unpacked_data(i) = mod(idivide(pdata, uint32(2^(8*place))), 2^8);
end

end