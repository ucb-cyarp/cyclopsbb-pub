%% Sim Params
overSampleFreq = 250; %300 MHz would be optimal, now targeting 250 MHz
overSample = 4;
baseFreq = overSampleFreq/overSample; %300 MHz
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;

eccTrellis = poly2trellis(7, [133 171 165]);

maxVal = 4;
minVal = -maxVal;

%Xilinx Settings
mult_pipeline = 3;
regular_pipeline = 1;

%Carrier Recovery

cr_bound_thresh = 2^-8;

cr_smooth_samples = 4;
cr_smooth_num = (1/cr_smooth_samples).*ones(1, cr_smooth_samples);
%cr_smooth_num = firpm(cr_smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
%cr_smooth_denom = zeros(1, cr_smooth_samples);
%cr_smooth_denom(1) = 1;
%cr_smooth_denom(2) = -0.90;

cr_smooth_second_num = [1, 0];
cr_smooth_second_denom = [1, -0.30];

cr_int_preamp = 2^-8;
cr_int_intr = -0.999999;
cr_int_amp = 2^-5+2^-7;

%[cr_smooth_num, cr_smooth_denom] = butter(cr_smooth_samples, 0.30, 'low');
cr_smooth_amp = 2^-5;
%cr_smooth_amp = 0;

cr_pre_amp = 1;

frac_lut_res_cr = 2^-5;
%Timing Recovery
frac_lut_domain = 5;

frac_lut_res = 2^-5;


averaging_samples = 40;
averaging_num = (1/averaging_samples).*ones(1, averaging_samples);
averaging_denom = zeros(1, averaging_samples);
averaging_denom(1) = 1;

smooth_samples = 4;
%[smooth_num, smooth_denom] = butter(smooth_samples, 0.35, 'low');
%smooth_num = firpm(smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
smooth_num = (1).*(1/smooth_samples).*ones(1, smooth_samples);
smooth_denom = zeros(1, smooth_samples);
smooth_denom(1) = 1;
smooth_denom(2) = -0.95;

smooth_second_num = [1, 0];
smooth_second_denom = [1, -0.95];

smooth_scale = 0.0005;
smooth_pre_scale = 1;
%smooth_num = [-0.000291723590836063 -0.00189040309614012 -0.00292818756339082 -0.00465671740235307 -0.00627225726025284 -0.00748117979971559 -0.00784951042322378 -0.00706790676162783 -0.00504024683234228 -0.00197291259925477 0.00161229674999934 0.00495396936361733 0.00721256543859064 0.00768858301637501 0.00604275550354361 0.00245513351781428 -0.00233533446972779 -0.0071456688820574 -0.0106052499779213 -0.0115138806128092 -0.00920500804274433 -0.00382440805589127 0.00358205511814609 0.0112116568949578 0.0168877131886811 0.0186025199453639 0.0151051821901078 0.00638111222231867 -0.0061224001760283 -0.0196057813722362 -0.030387605228581 -0.0346529496038089 -0.0293287477668018 -0.0128886191262846 0.0141156057755088 0.0489367760994866 0.0869929664510594 0.122651800554721 0.150283146189454 0.165358043121494 0.165358043121494 0.150283146189454 0.122651800554721 0.0869929664510594 0.0489367760994866 0.0141156057755088 -0.0128886191262846 -0.0293287477668018 -0.0346529496038089 -0.030387605228581 -0.0196057813722362 -0.0061224001760283 0.00638111222231867 0.0151051821901078 0.0186025199453639 0.0168877131886811 0.0112116568949578 0.00358205511814609 -0.00382440805589127 -0.00920500804274433 -0.0115138806128092 -0.0106052499779213 -0.0071456688820574 -0.00233533446972779 0.00245513351781428 0.00604275550354361 0.00768858301637501 0.00721256543859064 0.00495396936361733 0.00161229674999934 -0.00197291259925477 -0.00504024683234228 -0.00706790676162783 -0.00784951042322378 -0.00748117979971559 -0.00627225726025284 -0.00465671740235307 -0.00292818756339082 -0.00189040309614012 -0.000291723590836063];
%smooth_denom = zeros(size(smooth_num));
%smooth_denom(1) = 1;

thetaInit = 0;

expDomain = 3.3;
expTol = .1;
expResolution = 2^-6;
trigger = 60;

%[a, b] = butter(8, .3);

atanDomain = 2.5;
atanResolution = 2^-4;

%Recieve Matching Filter Coefs (could not implement recieve match filter
%since no decemation was used)
rcRxFilt = [0.0136862302916632 -1.07255950749522e-17 -0.0189771276893529 -0.0291239876115654 -0.0188755211158258 0.0106361356824736 0.0424635782726055 0.0519988855587596 0.023305426798367 -0.0360582703762239 -0.092415015279578 -0.100052449159764 -0.0262868760771072 0.126203946316784 0.313718534732932 0.467989970028836 0.527600531456874 0.467989970028836 0.313718534732932 0.126203946316784 -0.0262868760771072 -0.100052449159764 -0.092415015279578 -0.0360582703762239 0.023305426798367 0.0519988855587596 0.0424635782726055 0.0106361356824736 -0.0188755211158258 -0.0291239876115654 -0.0189771276893529 -1.07255950749522e-17 0.0136862302916632];
rcTxFilt = [6.68779489007459e-19 0.000270691295206529 -4.999338702171e-19 -0.000336219524424471 9.03438958834639e-19 0.00123463632165323 0.00256356625248123 0.00248824066903917 -3.39878148797709e-18 -0.00417063755826204 -0.00735316162855211 -0.00637019823453658 6.665784936228e-18 0.00919882830359276 0.0154066243645854 0.0128078682811614 -1.03706409504942e-17 -0.0174176846832742 -0.028565452527648 -0.0233755057420699 1.40443692691566e-17 0.0312771487461362 0.0512993158532978 0.0422515869026752 -1.71653402178581e-17 -0.0587334135872177 -0.0999790838467681 -0.0870884234163709 1.92597617652035e-17 0.150738757462899 0.323539111656293 0.460777672298146 0.512993158532978 0.460777672298146 0.323539111656293 0.150738757462899 1.92597617652035e-17 -0.0870884234163709 -0.0999790838467681 -0.0587334135872177 -1.71653402178581e-17 0.0422515869026752 0.0512993158532978 0.0312771487461362 1.40443692691566e-17 -0.0233755057420699 -0.028565452527648 -0.0174176846832742 -1.03706409504942e-17 0.0128078682811614 0.0154066243645854 0.00919882830359276 6.665784936228e-18 -0.00637019823453658 -0.00735316162855211 -0.00417063755826204 -3.39878148797709e-18 0.00248824066903917 0.00256356625248123 0.00123463632165323 9.03438958834639e-19 -0.000336219524424471 -4.999338702171e-19 0.000270691295206529 6.68779489007459e-19];

%% Imperfections
freqOffsetFactor = 0.001;
%freqOffsetFactor = 0.004;
%awgnEbN0 = 15; %very bad
%awgnEbN0 = 30;
awgnEbN0 = 1000000;

%% Golay Sequence
Ga_128 = [+1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, -1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
Gb_128 = [-1, -1, +1, +1, +1, +1, +1, +1, +1, -1, +1, -1, -1, +1, +1, -1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, +1, -1, +1, -1, +1, -1, +1, +1, -1, +1, +1, -1, -1, -1, -1, -1, -1, -1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, +1, -1, -1, -1, -1, +1, -1, +1, -1, +1, -1, -1, +1];
%Normal Values
D_128  = [ 1,  8,  2,  4, 16, 32, 64];
%Scaled by 4
%D_128  = D_128 .* 4;

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

%% Pipeline Parms
DivPipe = 3;
DivPipeMatch = DivPipe*4 + 8;

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

startWord = ones(8, 1);
guard = zeros(4, 1); 
after = zeros(100, 1);
xCTRL_PRE_adj = (xCTRL_PRE + 1)./2;

lineWidth = 60;
dataLen = 4096;
testText='That''s one small step for man, one giant leap for mankind. Yes, the surface is fine and powdery. I can kick it up loosely with my toe. It does adhere in fine layers like powdered charcoal to the sole and sides of my boots. I only go in a small fraction of an inch, maybe an eighth of an inch, but I can see the footprints of my boots and the treads in the fine, sandy particles. Neil, this is Houston. We''re copying. There seems to be no difficulty in moving around, as we suspected. It''s even perhaps easier than the simulations at one-sixth g that we performed in the various simulations on the ground. It''s virtually no trouble to walk around. The descent engine did not leave a crater of any size. It has about 1 foot clearance on the ground. We''re essentially on a very level place here. I can see some evidence of rays emanating from the descent engine, but a very insignificant amount.';
%source https://www.hq.nasa.gov/alsj/a11/Apollo11VoiceTranscript-Geology.pdf
[testMsg, testTextTrunk, testTextTrunkBin] =generate_frame(testText, dataLen, xCTRL_PRE_adj, startWord, guard, after);

simX.time = [];
simX.signals.values = testMsg;
simX.signals.dimensions = 1;

dataDelay = length(cat(1, xCTRL_PRE_adj, guard, startWord)) + 1 + 187;%delay in computing
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

expectedWidth = int16(1);
%expectedWidth = int16(4);
%expectedPer = 128;
expectedPer = int16(128*expectedWidth);

outBuffer = zeros(1024,1);
