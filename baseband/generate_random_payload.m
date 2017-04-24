%Generate a random frame using a given seed
%Length is in bits
%Bits/symbol specifies the modulation scheme
function [payload] = generate_random_payload(seed, len, bits_per_symbol)

rng(seed);
payload = randi(2^(bits_per_symbol),len/bits_per_symbol,1)-1;