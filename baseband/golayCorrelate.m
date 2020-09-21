function [ c ] = golayCorrelate(input, W, D)
    %set initial partialA and partialB to input
    partialA = zeros(length(D)+1, length(input));
    partialB = zeros(length(D)+1, length(input));

    partialA(1,:) = input;
    partialB(1,:) = input;

    for i = 1:(length(input))
        for stage = 1:(length(D))
            afterDelay = readSample(partialB(stage, :), i-D(stage));
            afterScale = readSample(partialA(stage, :), i)*conj(W(stage));
            partialA(stage+1, i) = afterDelay + afterScale;
            partialB(stage+1, i) = -afterDelay + afterScale;
        end
    end

    c = cat(1, partialA(length(D)+1, :), partialB(length(D)+1, :));
end