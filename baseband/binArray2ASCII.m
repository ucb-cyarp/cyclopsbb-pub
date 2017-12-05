function [str] = binArray2ASCII(rx_data)
%binArray2ASCII Converts little endian (bit & byte) array to ASCII string
%   Detailed explanation goes here

%protect against partially filled array
rx_bits = int64(length(rx_data));
chars = idivide(rx_bits, int64(8), 'floor');

str = [];

for i = 1:chars
    work = rx_data((i-1)*8+1) + (rx_data((i-1)*8+2))*2 + (rx_data((i-1)*8+3))*4 + (rx_data((i-1)*8+4))*8 + (rx_data((i-1)*8+5))*16 + (rx_data((i-1)*8+6))*32 + (rx_data((i-1)*8+7))*64 + (rx_data((i-1)*8+8))*128;
    work_char = char(work);
    print_this = isstrprop(work_char, 'alphanum') || isstrprop(work_char, 'punct') || isstrprop(work_char, 'wspace');
    if(print_this)
        str = [str, char(work)];
    else
        str = [str, '*'];
    end
end

end

