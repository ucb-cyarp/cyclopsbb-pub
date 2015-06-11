function [ out ] = Convert2UInt32( arr )
%CONVERT2UINT32 Takes a signed array and converts it to the corresponding
%uint32 array

out = zeros(size(arr));

for i = 1:length(arr)
    if arr(i) < 0
        out(i) = 2^32+arr(i);
    else
        out(i) = arr(i);
    end
end

end

