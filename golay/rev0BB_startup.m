%% Rev0BB

%This code a segment from golay.m

%% Init
clear; close all; clc;

%% Sim Params
overSampleFreq = 300; %300 MHz
overSample = 4;
baseFreq = overSampleFreq/overSample; %300 MHz
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;

eccTrellis = poly2trellis(7, [133 171 165]);

maxVal = 4;
minVal = -maxVal;

loopNum =   [0.0008, 0.0008, 0.0008, 0.0008, 0.0008, 0.0008, 0.0008, 0.0008, 0.0008, 0.0008];
loopDenom = [1, 0.99, 0, 0, 0, 0, 0, 0, 0, 0];
amp = 4;

thetaInit = 0;

expDomain = 3.3;
expTol = .1;
expResolution = 2^-7;
trigger = 60;

%[a, b] = butter(8, .3);

atanDomain = 6;
atanResolution = 2^-7;

%% Golay Sequence
Ga_128 = [+1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, -1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
Gb_128 = [-1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
%Normal Values
D_128  = [ 1,  8,  2,  4, 16, 32, 64];
%Scaled by 4
D_128  = D_128 .* 4;

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

%Note that CEF note is duplicated in the state machine function because
%(for whatever reason) an array can not be passed as a parameter for
%stateflow HDL coder
cef_note  = cat(2, Gu_512_note, Gv_512_note, Gv_128_note);
cef_note  = int16(cef_note);
cef_note_len = uint16(length(cef_note));

lineWidth = 60;
dataLen = 4096;
testText='That''s one small step for man, one giant leap for mankind. Yes, the surface is fine and powdery. I can kick it up loosely with my toe. It does adhere in fine layers like powdered charcoal to the sole and sides of my boots. I only go in a small fraction of an inch, maybe an eighth of an inch, but I can see the footprints of my boots and the treads in the fine, sandy particles. Neil, this is Houston. We''re copying. There seems to be no difficulty in moving around, as we suspected. It''s even perhaps easier than the simulations at one-sixth g that we performed in the various simulations on the ground. It''s virtually no trouble to walk around. The descent engine did not leave a crater of any size. It has about 1 foot clearance on the ground. We''re essentially on a very level place here. I can see some evidence of rays emanating from the descent engine, but a very insignificant amount.';
%source https://www.hq.nasa.gov/alsj/a11/Apollo11VoiceTranscript-Geology.pdf
testTextTrunk = testText(1:(dataLen/8));
testTextTrunkDouble = double(testTextTrunk);
startWord = ones(8, 1);
guard = zeros(4, 1); 
after = zeros(100, 1);


testTextTrunkBin = [];
for ind = 1:(dataLen/8)
    newStr = dec2bin(testText(ind), 8);
    testTextTrunkBin=cat(1, testTextTrunkBin, [str2num(newStr(:))]);
end

%testTextTrunkCoded = convolutionVect( testTextTrunkBin(1:floor(dataLen/24)), eccTrellis );

xCTRL_PRE_adj = (xCTRL_PRE + 1)./2;
testMsg = cat(1, xCTRL_PRE_adj, guard, startWord, testTextTrunkBin, after);

simX.time = [];
simX.signals.values = testMsg;
simX.signals.dimensions = 1;

dataDelay = length(cat(1, xCTRL_PRE_adj, guard, startWord)) + 1;%delay in computing
idealX.time = [];
idealX.signals.values = cat(1, testTextTrunkBin, after);
idealX.signals.dimensions = 1;

rSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1).*exp(j*pi*nSC_STFRep/2), -Ga_128(mod(nSC_STFNeg, 128)+1).*exp(j*pi*nSC_STFNeg/2)); %+1 is for matlab
rSC_STF   = transpose(rSC_STF);
rSC_STF_I = real(xSC_STF);
rSC_STF_Q = imag(xSC_STF);

tol      = int16(15);
cbTol    = int16(5);
guardInt = int16(4);
wordLen  = int16(8);
guardTol = int16(5);

invertedTol = int16(8);

%expectedWidth = 1;
expectedWidth = int16(4);
%expectedPer = 128;
expectedPer = int16(128*expectedWidth);

outBuffer = zeros(1024,1);

%% Start Simulink
open_system('rev0BB')