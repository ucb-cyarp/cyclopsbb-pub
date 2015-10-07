function [ val ] = readSample( matrix, ind )
%readSample Read a particular sample.  Returns 0 if index <1
if(ind < 1)
    val = 0;
else
    val = matrix(ind);
end

end