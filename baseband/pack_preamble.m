lead = zeros(16, 1);

pre = cat(1, lead, xCTRL_PRE_adj, guard, startWord);
packed_word = 32;

packed = zeros(1, ceil(length(pre)/packed_word));
for i = 0:1:(length(pre)-1)
    packed(idivide(i,int32(packed_word))+1) = bitor(packed(idivide(i,int32(packed_word))+1), (pre(i+1)*2^mod(i,packed_word)));
end

disp(mat2str(dec2bin(packed)));