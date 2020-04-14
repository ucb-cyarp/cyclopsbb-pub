function [msg, header_payload_crc_symbols, header_payload_binary, crc_binary, header_payload_crc_packed, transmittedBits] = generate_random_frame(seed, bitsPerSymbolHeader, payloadLenSymbols, xCTRL_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWord)

rng(seed);

bitsPerSymbol = log2(radix);

payload_symbols = randi(radix,payloadLenSymbols,1)-1;

if(radix == 2) %BPSK
    modType = 0;
elseif(radix == 4) %QPSK
    modType = 1;
else %16QAM
    modType = 2;
end

header_symbols = transpose([packed2unpacked([modType, type, src, dst], 8, bitsPerSymbolHeader), packed2unpacked([net_id], 16, bitsPerSymbolHeader), packed2unpacked([len], 16, bitsPerSymbolHeader)]);

header_payload_symbols = cat(1, header_symbols, payload_symbols);

header_binary = packed2unpacked(header_symbols, bitsPerSymbolHeader, 1);
payload_binary = packed2unpacked(payload_symbols, bitsPerSymbol, 1);
header_payload_binary = cat(2, header_binary, payload_binary);

crc_gen = comm.CRCGenerator(crc_poly, 'InitialConditions', crc_init, 'FinalXOR', crc_xor);
codeword = step(crc_gen, transpose(header_payload_binary));

crc_binary = codeword((length(codeword)-31):length(codeword));
crc_dec = bin2dec(reverse(transpose(num2str(crc_binary))));
crc_symbols = transpose(packed2unpacked(crc_dec, 32, bitsPerSymbol));

header_payload_crc_symbols = cat(1, header_payload_symbols, crc_symbols);

header_payload_crc_packed = unpacked2packed(header_symbols, bitsPerPackedWord, bitsPerSymbolHeader); %Header uses bitsPerSymbolHeader
header_payload_crc_packed = cat(2, header_payload_crc_packed, unpacked2packed(payload_symbols, bitsPerPackedWord, bitsPerSymbol));
header_payload_crc_packed = cat(2, header_payload_crc_packed, unpacked2packed(crc_symbols, bitsPerPackedWord, bitsPerSymbol));

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

transmittedBits = length(header_payload_symbols)*bitsPerSymbolHeader + length(payload_symbols)*bitsPerSymbol+ length(crc_symbols)*bitsPerSymbol;

msg = cat(1, xCTRL_PRE_adj, header_payload_crc_symbols, after);
