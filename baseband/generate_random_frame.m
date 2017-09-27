function [msg, textTrunkRadix] = generate_random_frame(seed, len, xCTRL_PRE_adj, after, radix)

rng(seed);
textTrunkRadix = randi(radix,len,1)-1;

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

msg = cat(1, xCTRL_PRE_adj, textTrunkRadix, after);
