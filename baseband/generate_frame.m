function [msg, textTrunk, textTrunkBin] = generate_frame(str, len, xCTRL_PRE_adj, after)

if (idivide(len,uint32(8)) <= uint32(length(str)))
	%truncate
    trunkpt = double(idivide(len,uint32(8)));
	textTrunk = str(1:trunkpt);
else
	%pad with spaces
	textTrunk = [str, char(32.*ones(1, idivide(len,uint32(8)) - length(str)))];
end

disp(textTrunk);
disp(length(textTrunk));

textTrunkBin = [];
for ind = 1:length(textTrunk)
    newStr = dec2bin(textTrunk(ind), 8);
    textTrunkBin=cat(1, textTrunkBin, [str2num(newStr(:))]);
end

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

msg = cat(1, xCTRL_PRE_adj, textTrunkBin, after);
