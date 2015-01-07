function [ c ] = golayGen( W, D, len )
%GOLAYGEN Generate Golay Sequence
a = zeros(length(D)+1, len);
b = zeros(length(D)+1, len);

a(1, 1) = 1;
b(1, 1) = 1;

for i = 1:len
    for stage = 1:(length(D))
        prev = readSample(a(stage, :), i);
        afterScale = readSample(b(stage, :), i-D(stage))*W(stage);
        a(stage+1, i) = prev + afterScale;
        b(stage+1, i) = prev - afterScale;
    end
end

genA = fliplr(a(length(D)+1,:));
genB = fliplr(b(length(D)+1,:));

c = cat(1, genA, genB);

end

