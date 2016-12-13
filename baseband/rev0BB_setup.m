%% Sim Params
overSampleFreq = 250; %300 MHz would be optimal, now targeting 250 MHz
overSample = 4;
slowSample = 3;
baseFreq = overSampleFreq/overSample; %300 MHz
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;
slowPer = overSamplePer*slowSample;

eccTrellis = poly2trellis(7, [133 171 165]);

maxVal = 4;
minVal = -maxVal;

%rcTxFilt = [-1.03769992306702e-17 -0.0174283635332858 -0.0285829661173474 -0.0233898373552725 1.40529799264088e-17 0.031296324887301 0.0513307676627465 0.0422774915144242 -1.71758643544996e-17 -0.0587694232708108 -0.100040381410716 -0.087141817666429 1.92715699998162e-17 0.150831175979548 0.323737474740084 0.461060176875571 0.513307676627465 0.461060176875571 0.323737474740084 0.150831175979548 1.92715699998162e-17 -0.087141817666429 -0.100040381410716 -0.0587694232708108 -1.71758643544996e-17 0.0422774915144242 0.0513307676627465 0.031296324887301 1.40529799264088e-17 -0.0233898373552725 -0.0285829661173474 -0.0174283635332858 -1.03769992306702e-17];
rcTxFilt = [-1.72985923225974e-17 -0.0591893527576443 -0.100755207313207 -0.0877644785117768 1.9409272567752e-17 0.151908921085804 0.326050699952622 0.464354624101683 0.516975451760132 0.464354624101683 0.326050699952622 0.151908921085804 1.9409272567752e-17 -0.0877644785117768 -0.100755207313207 -0.0591893527576443 -1.72985923225974e-17];

%Xilinx Settings
mult_pipeline = 3;
regular_pipeline = 1;

%Tx Interp filter
tx_interp_filt = firpm(30, [0.0, 0.25, 0.3, 1], [1, 1, 0, 0]);

%Carrier Recovery

cr_bound_thresh = 2^-8;

cr_smooth_samples = 12;
cr_smooth_num = (1/cr_smooth_samples).*ones(1, cr_smooth_samples);
%cr_smooth_num = firpm(cr_smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
%cr_smooth_denom = zeros(1, cr_smooth_samples);
%cr_smooth_denom(1) = 1;
%cr_smooth_denom(2) = -0.90;

cr_smooth_second_num = [1, 0];
cr_smooth_second_denom = [1, -0.99];

cr_int_preamp = 2^-7;
cr_int_intr = -0.9999999;
cr_int_amp = 2^-7;

%[cr_smooth_num, cr_smooth_denom] = butter(cr_smooth_samples, 0.30, 'low');
cr_smooth_amp = 2^-6;
%cr_smooth_amp = 0;

cr_pre_amp = 1;

frac_lut_res_cr = 2^-4;


%Timing Recovery
frac_lut_domain = 4;

frac_lut_res = 2^-10;

range_max = 2^(18-13-1)-1;
range_min = -2^(18-13-1);
frac_lut_table_breaks = -frac_lut_domain:frac_lut_res:(frac_lut_domain-1);
frac_lut_table_data = 1./frac_lut_table_breaks;

for ind = 1:length(frac_lut_table_data)
   if frac_lut_table_data(ind) > range_max
       frac_lut_table_data(ind) = range_max;
   elseif frac_lut_table_data(ind) < range_min
       frac_lut_table_data(ind) = range_min;
   end
end
   
timing_loop_prescale = 0.5;


averaging_samples = 256;
averaging_num = (1/averaging_samples).*ones(1, averaging_samples);
averaging_denom = zeros(1, averaging_samples);
averaging_denom(1) = 1;

smooth_samples = 128;
%[smooth_num, smooth_denom] = butter(smooth_samples, 0.35, 'low');
%smooth_num = firpm(smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
smooth_num = (1/smooth_samples).*ones(1, smooth_samples);
smooth_denom = zeros(1, smooth_samples);

smooth_scale = 0.00075;
smooth_pre_scale = 0.5;
smooth_intg = 0.90;
%smooth_num = [-0.000291723590836063 -0.00189040309614012 -0.00292818756339082 -0.00465671740235307 -0.00627225726025284 -0.00748117979971559 -0.00784951042322378 -0.00706790676162783 -0.00504024683234228 -0.00197291259925477 0.00161229674999934 0.00495396936361733 0.00721256543859064 0.00768858301637501 0.00604275550354361 0.00245513351781428 -0.00233533446972779 -0.0071456688820574 -0.0106052499779213 -0.0115138806128092 -0.00920500804274433 -0.00382440805589127 0.00358205511814609 0.0112116568949578 0.0168877131886811 0.0186025199453639 0.0151051821901078 0.00638111222231867 -0.0061224001760283 -0.0196057813722362 -0.030387605228581 -0.0346529496038089 -0.0293287477668018 -0.0128886191262846 0.0141156057755088 0.0489367760994866 0.0869929664510594 0.122651800554721 0.150283146189454 0.165358043121494 0.165358043121494 0.150283146189454 0.122651800554721 0.0869929664510594 0.0489367760994866 0.0141156057755088 -0.0128886191262846 -0.0293287477668018 -0.0346529496038089 -0.030387605228581 -0.0196057813722362 -0.0061224001760283 0.00638111222231867 0.0151051821901078 0.0186025199453639 0.0168877131886811 0.0112116568949578 0.00358205511814609 -0.00382440805589127 -0.00920500804274433 -0.0115138806128092 -0.0106052499779213 -0.0071456688820574 -0.00233533446972779 0.00245513351781428 0.00604275550354361 0.00768858301637501 0.00721256543859064 0.00495396936361733 0.00161229674999934 -0.00197291259925477 -0.00504024683234228 -0.00706790676162783 -0.00784951042322378 -0.00748117979971559 -0.00627225726025284 -0.00465671740235307 -0.00292818756339082 -0.00189040309614012 -0.000291723590836063];
%smooth_denom = zeros(size(smooth_num));
%smooth_denom(1) = 1;

thetaInit = 0;

expDomain = 3.3;
expTol = .1;
expResolution = 2^-5;
trigger = 60;

%[a, b] = butter(8, .3);

atanDomain = 5;
atanResolution = 2^-9;

atanDomainTiming = 6;
atanResolutionTiming = 2^-9;

%Recieve Matching Filter Coefs (could not implement recieve match filter
%since no decemation was used)

%AGC config
agc_detector_taps = 256;
agc_detector_coef = ones(1,agc_detector_taps)./agc_detector_taps;

lnDomain = 16;
lnResolution = 2^-9;

agcExpDomain = 8;
agcExpResolution = 2^-9;

agcDesired = 0;
agcStep = 2^-10;


%% Imperfections
freqOffsetFactor = 0.001;
%freqOffsetFactor = 0.004;
%awgnEbN0 = 10; %very bad
%awgnEbN0 = 15; %very bad
awgnEbN0 = 30;
%awgnEbN0 = 1000000;

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
guard = zeros(8, 1); 
after = zeros(100, 1);
xCTRL_PRE_adj = (xCTRL_PRE + 1)./2;

lineWidth = 60;
dataLen = 4096;
testText='That''s one small step for man, one giant leap for mankind. Yes, the surface is fine and powdery. I can kick it up loosely with my toe. It does adhere in fine layers like powdered charcoal to the sole and sides of my boots. I only go in a small fraction of an inch, maybe an eighth of an inch, but I can see the footprints of my boots and the treads in the fine, sandy particles. Neil, this is Houston. We''re copying. There seems to be no difficulty in moving around, as we suspected. It''s even perhaps easier than the simulations at one-sixth g that we performed in the various simulations on the ground. It''s virtually no trouble to walk around. The descent engine did not leave a crater of any size. It has about 1 foot clearance on the ground. We''re essentially on a very level place here. I can see some evidence of rays emanating from the descent engine, but a very insignificant amount.';
%source https://www.hq.nasa.gov/alsj/a11/Apollo11VoiceTranscript-Geology.pdf
[testMsg, testTextTrunk, testTextTrunkBin] =generate_frame(testText, dataLen, xCTRL_PRE_adj, startWord, guard, after);

%pad some 0's to the front (simulate what occurs in the FPGA given the
%modulator)
mod_imperfection = zeros(500, 1);
testMsgFPGA = cat(1, mod_imperfection, testMsg);

simX.time = [];
simX.signals.values = testMsgFPGA;
simX.signals.dimensions = 1;

dataDelay = length(cat(1, xCTRL_PRE_adj, guard, startWord)) + 1 + 187+360+1;%delay in computing
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
