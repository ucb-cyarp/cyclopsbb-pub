function [msg, textTrunkBin] = generate_random_frame(seed, len, xCTRL_PRE_adj, after)

rng(seed);
textTrunkBin = randi(2,len,1)-1;

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

msg = cat(1, xCTRL_PRE_adj, textTrunkBin, after);
