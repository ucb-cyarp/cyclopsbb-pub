interpRes = 1000;

%Preamble STF Segment Before shaping
preambleSeg = upsample(Gb_32, overSample);

%Convolve with Tx RRC Filter
txSignal = conv([preambleSeg, preambleSeg, preambleSeg], rcTxFilt);
nReps = 3;

%Upsample and interpolate
txSignalInterp = interp(txSignal, interpRes);

beforePeak = zeros(1, interpRes);
afterPeak = zeros(1, interpRes);
peak = zeros(1, interpRes);
beforePeakSq = zeros(1, interpRes);
afterPeakSq = zeros(1, interpRes);
peakSq = zeros(1, interpRes);

for del = 0:(interpRes-1) %NOTE this is negative delay
%(Negative) Delay by a fraction of a sample
txSignalDelayed = txSignalInterp((del+1):length(txSignalInterp));
%Downsample from interpolated signal to expected rx sample rate
rxSignal = downsample(txSignalDelayed, interpRes);

%Rx Filter Signal
rxFiltSignal = conv(rxSignal, rcRxFilt);

%Correlate with preamble seq
prambleCorr = conv(rxFiltSignal, flip(preambleSeg));

%Get the magnitude of the peaks (sq)
preambleCorrMagSq = prambleCorr.*conj(prambleCorr);

%Find the index of the peak
% [pks,locs] = findpeaks(preambleCorrMagSq);
% %Get the top 3 peaks
% tbl = [transpose(pks), transpose(locs)];
% tblSort = sortrows(tbl, 1, 'descend');
% maxVal = tblSort((nReps+1)/2, 1);
% maxInd = tblSort((nReps+1)/2, 2);
[maxVal, maxInd] = max(preambleCorrMagSq(250:350)); %TODO: Make this parameterizable
maxInd = maxInd + 250-1;

%Find the values before and after the peak
beforePeak(del+1) = prambleCorr(maxInd-1);
afterPeak(del+1)  = prambleCorr(maxInd+1);
peak(del+1) = prambleCorr(maxInd);

beforePeakSq(del+1) = preambleCorrMagSq(maxInd-1);
afterPeakSq(del+1)  = preambleCorrMagSq(maxInd+1);
peakSq(del+1)       = preambleCorrMagSq(maxInd);
end

diffS = afterPeak./peak - beforePeak./peak;
diffSq = afterPeakSq./peakSq - beforePeakSq./peakSq;

figure;
plot(diffS);

figure;
plot(diffSq);
