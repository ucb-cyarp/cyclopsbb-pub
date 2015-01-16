%% Golay Sequence Test

%% Init
clear; close all; clc;

%% Golay Sequence
Ga_128 = [+1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, -1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
Gb_128 = [-1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
D_128  = [ 1,  8,  2,  4, 16, 32, 64];
W_128  = [-1, -1, -1, -1, +1, -1, -1];

Ga_64  = [-1, -1, +1, -1, +1, -1, -1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, +1, -1, +1, -1, -1, -1, -1, -1, +1, -1, -1, +1, +1, +1, -1, -1, +1, -1, +1, -1, -1, -1, +1, +1, -1, +1, +1, -1, -1, -1, +1, +1, -1, +1, -1, +1, +1, +1, +1, +1, -1, +1, +1, -1, -1, -1];
Gb_64  = [+1, +1, -1, +1, -1, +1, +1, +1, -1, -1, +1, -1, -1, +1, +1, +1, +1, +1, -1, +1, -1, +1, +1, +1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, +1, -1, +1, -1, -1, -1, +1, +1, -1, +1, +1, -1, -1, -1, +1, +1, -1, +1, -1, +1, +1, +1, +1, +1, -1, +1, +1, -1, -1, -1];
D_64   = [ 2,  1,  4,  8, 16, 32];
W_64   = [ 1,  1, -1, -1,  1, -1];

Ga_32  = [+1, +1, +1, +1, +1, -1, +1, -1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, -1, -1, +1, -1, -1, -1, -1, +1, -1, +1, -1];
Gb_32  = [-1, -1, -1, -1, -1, +1, -1, +1, +1, +1, -1, -1, -1, +1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, -1, -1, -1, -1, +1, -1, +1, -1];
D_32   = [ 1,  4,  8,  2, 16];
W_32   = [-1,  1, -1,  1, -1];

Gu_512 = cat(2, -Gb_128, -Ga_128, Gb_128, -Ga_128);
Gv_512 = cat(2, -Gb_128, Ga_128, -Gb_128, -Ga_128);

Gv_128 = Gv_512(1:1:128);

%From 802.11ad - Can Reconstruct Ga and Gb
%A0 (n)= delta(n)
%B0 (n)= delta(n)
%Ak (n) = W_k*A_{k?1}(n) + B_{k?1}(n ? D_k)
%Bk (n) = W_k*A_{k?1}(n) ? B_{k?1}(n ? D_k)
%k Note that Ak (n), Bk (n) are zero for n < 0 and for n?2 .

%Ga_128(n)=A_7(128-n)
%Gb_128(n)=B_7(128-n)
%Ga_64(n)=A_6(64-n)
%Gb_64(n)=B_6(64-n)
%Ga_32(n)=A_5(32-n)
%Gb_32(n)=B_5(32-n) 

%% Timing Parms
Tc = 1; % This is a fake Ts (not the one used in 802.11ad)

%% Golay Waveform
nSC_STFRep = 0:1:(16*128-1);
nSC_STFNeg = (16*128):1:(17*128-1);

nCTRL_STFRep = 0:1:(48*128-1);
nCTRL_STFNeg = (48*128):1:(49*128-1);
nCTRL_STFFin = (49*128):1:(50*128-1);

%Complex Baseband Preamble Signal
xSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1), -Ga_128(mod(nSC_STFNeg, 128)+1)); %+1 is for matlab
xCTRL_STF = cat(2, Gb_128(mod(nCTRL_STFRep, 128)+1), -Gb_128(mod(nCTRL_STFNeg, 128)+1), -Ga_128(mod(nCTRL_STFFin, 128)+1)); %+1 is for matlab
xSC_CEF   = cat(2, Gu_512, Gv_512, Gv_128);
xCTRL_CEF = xSC_CEF;
xSC_PRE   = cat(2, xSC_STF, xSC_CEF);
xCTRL_PRE = cat(2, xCTRL_STF, xCTRL_CEF);

xSC_STF   = transpose(xSC_STF);
xCTRL_STF = transpose(xCTRL_STF);
xSC_CEF   = transpose(xSC_CEF);
xCTRL_CEF = transpose(xCTRL_CEF);
xSC_PRE   = transpose(xSC_PRE);
xCTRL_PRE = transpose(xCTRL_PRE);

simX.time = [];
simX.signals.values = xCTRL_PRE;
simX.signals.dimensions = 1;

rSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1).*exp(j*pi*nSC_STFRep/2), -Ga_128(mod(nSC_STFNeg, 128)+1).*exp(j*pi*nSC_STFNeg/2)); %+1 is for matlab
rSC_STF = transpose(rSC_STF);
rSC_STF_I = real(xSC_STF);
rSC_STF_Q = imag(xSC_STF);

tol = 15;
cbTol = 5;

figure;
plot(rSC_STF);


%% Generate Sequence
D = D_128;
W = W_128;

c = golayGen(W, D, 128);
disp(mat2str(c(1,:)));
disp(mat2str(c(2,:)));

%% Test Correlation

input = xSC_PRE;
input = transpose(input);
%input = genA;
input = cat(2, zeros(1, 1000), input);
input = cat(2, input, zeros(1, 1000));

D = D_128;
W = W_128;

c = golayCorrelate(input, W, D);

figure
subplot(2, 1, 1);
plot(c(1, :));
a1 = gca;
title('Ca');
xlabel('Sample');
ylabel('Correlator Output');
subplot(2, 1, 2);
plot(c(2, :));
a2 = gca;
title('Cb');
xlabel('Sample');
ylabel('Correlator Output');

%match axes
if(a1.YLim(2) - a1.YLim(1) > a2.YLim(2) - a2.YLim(1))
    a2.YLim = a1.YLim;
else
    a1.YLim = a2.YLim;
end

figure
plot(c(1, :));
hold all;
plot(c(2, :));
title('Correlators Superimposed');
xlabel('Sample');
ylabel('Correlator Output');
legend('Ca', 'Cb');

%% Test summation of a and b correlations
Ca = golayCorrelate(cat(2, Ga_128, zeros(1, 128)), W_128, D_128);
Ca = Ca(1, :);
Cb = golayCorrelate(cat(2, Gb_128, zeros(1, 128)), W_128, D_128);
Cb = Cb(2, :);

S = Ca+Cb;

figure
subplot(3, 1, 1);
plot(Ca);
title('Ca');
xlabel('Sample');
ylabel('Correlator Output');
subplot(3, 1, 2);
plot(Cb);
title('Cb');
xlabel('Sample');
ylabel('Correlator Output');
subplot(3, 1, 3);
plot(S);
title('Ca+Cb');
xlabel('Sample');
ylabel('Correlator Output');

fftS = fft(S);
figure
subplot(2, 1, 1)
plot(abs(fftS))
title('Frequency Response of Perfect Channel (From Ca+Cb)')
ylabel('Magnitude')
subplot(2, 1, 2)
plot(atan(imag(fftS)./real(fftS)));
ylabel('Phase')

%% Test filtered summation of a and b correlations
h = [0.25, 0.25, 0.25, 0, 0, 0, 0, 0];
ffth = fft(h, 1000);
figure
subplot(2, 1, 1)
plot(abs(ffth))
[y,x] = freqz(h, 1000, 'whole');
subplot(2, 1, 2)
plot(x, abs(y))


fa = conv(cat(2, Ga_128, zeros(1, 128)), h);
fb = conv(cat(2, Gb_128, zeros(1, 128)), h);

Ca = golayCorrelate(fa, W_128, D_128);
Ca = Ca(1, :);
Cb = golayCorrelate(fb, W_128, D_128);
Cb = Cb(2, :);

S = Ca+Cb;

figure
subplot(3, 1, 1);
plot(Ca);
title('Ca');
xlabel('Sample');
ylabel('Correlator Output');
subplot(3, 1, 2);
plot(Cb);
title('Cb');
xlabel('Sample');
ylabel('Correlator Output');
subplot(3, 1, 3);
plot(S);
title('Ca+Cb');
xlabel('Sample');
ylabel('Correlator Output');

fftS = fft(S);
figure
subplot(2, 1, 1)
plot(abs(fftS))
title('Frequency Response of Filtering Channel (From Ca+Cb)')
ylabel('Magnitude')
subplot(2, 1, 2)
plot(atan(imag(fftS)./real(fftS)));
ylabel('Phase')

figure
subplot(2, 1, 1)
plot(abs(ffth))
title('Freq Response Channel')
ylabel('Magnitude')
subplot(2, 1, 2)
plot(abs(fftS))
title('Calulated Freq Response')
ylabel('Magnitude')