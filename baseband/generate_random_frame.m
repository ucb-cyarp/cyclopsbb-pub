function [msg, header_payload_crc_symbols] = generate_random_frame(seed, payloadLenSymbols, xCTRL_PRE_adj, after, radix, type, src, dst, len, crc_poly, crc_init, crc_xor)

rng(seed);

bitsPerSymbol = log2(radix);

payload_symbols = randi(radix,payloadLenSymbols,1)-1;

header_symbols = transpose([packed2unpacked([type, src, dst], 8, bitsPerSymbol), packed2unpacked([len], 16, bitsPerSymbol)]);

header_payload_symbols = cat(1, header_symbols, payload_symbols);

header_payload_binary = packed2unpacked(header_payload_symbols, bitsPerSymbol, 1);

crc_gen = comm.CRCGenerator(crc_poly, 'InitialConditions', crc_init, 'FinalXOR', crc_xor);
codeword = step(crc_gen, transpose(header_payload_binary));

crc_binary = codeword((length(codeword)-31):length(codeword));
crc_dec = bin2dec(reverse(transpose(num2str(crc_binary))));
crc_symbols = transpose(packed2unpacked(crc_dec, 32, bitsPerSymbol));

header_payload_crc_symbols = cat(1, header_payload_symbols, crc_symbols);

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

msg = cat(1, xCTRL_PRE_adj, header_payload_crc_symbols, after);
