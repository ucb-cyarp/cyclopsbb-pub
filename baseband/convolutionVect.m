function [ codedVec ] = convolutionVect( inputVec, trellis )
%CONVOLUTIONVECT Generates convolution code for given binary vector and
%trellis.  It operates in terminated mode.
%   inputVec: a vector of 0's and 1's which constitute the uncoded msg
%   trellis:  a trellis object defining the convolutional code

% Based on example from:
% www.mathworks.com/help/comm/ref/comm.convolutionalencoder-class.html

convEnc = comm.ConvolutionalEncoder(trellis, 'TerminationMethod', ...
                                    'Terminated');
coded = step(convEnc, inputVec);
codedVec = transpose(coded);
end

