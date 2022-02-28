function [msg, header_payload_crc_symbols, header_payload_binary, crc_binary, header_payload_crc_packed, transmittedBits] = generate_frame(str, bitsPerSymbolHeader, payloadLenSymbols, xCTRL_PRE_adj, after, radix, type, src, dst, net_id, len, crc_poly, crc_init, crc_xor, bitsPerPackedWord)

bitsPerSymbol = log2(radix);

%Trunkate the string based on the number of payload symbols allowed
if mod(payloadLenSymbols*bitsPerSymbol, 8) ~= 0
    error('Payload length must be a multiple of 8 bits');
end
    
numASCIIChars = payloadLenSymbols*bitsPerSymbol/8;
if length(str) > numASCIIChars
    payload_ascii = str(1:numASCIIChars);
else
    payload_ascii = str;
end

%Then pad the string if required
switch radix
    case 2
        paddingChar = 'U';
    case 4
        paddingChar = '3';
    case 16
        paddingChar = '(';
    otherwise
        paddingChar = 'U';
end

unpaddedLen = length(payload_ascii);
for i = (unpaddedLen+1):numASCIIChars
    payload_ascii = [payload_ascii, paddingChar];
end

payload_symbols = transpose(packed2unpacked(payload_ascii, 8, bitsPerSymbol));

% %Scramble payload symbols by XOR-ing with pseudorandom number stream
% %(similar to a stream cypher)
% %The same seed will be used for each packet (so it provides no protection)
% randStreamGen = RandStream('mt19937ar', 'Seed', 0);
% randStream = randi(randStreamGen, 2^8, numASCIIChars, 1)-1;
% payload_symbols = bitxor(payload_symbols, transpose(packed2unpacked(randStream, 8, bitsPerSymbol)));

modType = radixToModType(radix, true); %Modtype in packet is repcoded

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