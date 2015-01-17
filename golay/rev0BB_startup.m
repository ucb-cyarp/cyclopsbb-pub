%% Rev0BB

%This code a segment from golay.m

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

Gu_512_note = [-2, -1, 2, -1];
Gv_512_note = [-2, 1, -2, -1];

Gv_128_note = Gv_512_note(1);

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

cef_note  = cat(2, Gu_512_note, Gv_512_note, Gv_128_note);

testText = 'We the People of the United States, in Order to form a more perfect Union, establish Justice, insure domestic Tranquility, provide for the common defence, promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity, do ordain and establish this Constitution for the United States of America.';
testTextTrunk = testText(1:(1024/8));
testTextTrunkDouble = double(testTextTrunk);
startWord = ones(8, 1);
guard = zeros(10, 1); %guard must be >5 or else start word is missed
after = zeros(100, 1);


testTextTrunkBin = [];
for ind = 1:(1024/8)
    newStr = dec2bin(testText(ind), 8);
    testTextTrunkBin=cat(1, testTextTrunkBin, [str2num(newStr(:))]);
end

xCTRL_PRE_adj = (xCTRL_PRE + 1)./2;
testMsg = cat(1, xCTRL_PRE_adj, guard, startWord, testTextTrunkBin, after);

simX.time = [];
simX.signals.values = testMsg;
simX.signals.dimensions = 1;

rSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1).*exp(j*pi*nSC_STFRep/2), -Ga_128(mod(nSC_STFNeg, 128)+1).*exp(j*pi*nSC_STFNeg/2)); %+1 is for matlab
rSC_STF = transpose(rSC_STF);
rSC_STF_I = real(xSC_STF);
rSC_STF_Q = imag(xSC_STF);

tol = 15;
cbTol = 5;
guardInt = 10; %guard must be >5 or else start word is missed
guardTol = 5;

outBuffer = zeros(1024,1);

%% Start Simulink
open_system('rev0BB')