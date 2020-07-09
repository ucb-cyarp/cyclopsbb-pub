function payload_len_bytes = fixedPayloadLength(radix)
%fixedPayloadLength Get the frame size based on the modulation scheme.
%Maintains the same number of symbols per packet.

mtu_eth = 1500+26+2;%+2 is so that the result fits evenly in 32 bit words

if(radix == 2) %BPSK
    payload_len_bytes = mtu_eth;
elseif(radix == 4) %QPSK
    payload_len_bytes = mtu_eth*2+4;
else %16QAM
    payload_len_bytes = mtu_eth*4+12;
end

end

