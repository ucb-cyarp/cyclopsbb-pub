dataLen = 4096;
lineWidth = 60;

%% Sim Params
overSampleFreq = 250e6; %300 MHz would be optimal, now targeting 250 MHz
overSample = 4;
slowSample = 3;
baseFreq = overSampleFreq/overSample; %300 MHz
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;
slowPer = overSamplePer*slowSample;
fifo_slow_per = overSamplePer * overSample/slowSample;

eccTrellis = poly2trellis(7, [133 171 165]);

maxVal = 4;
minVal = -maxVal;

tx_gain = 1;
rx_gain = 1;
rx_gain_i = 1;
rx_gain_q = 1;

%rcTxFilt = [-1.03769992306702e-17 -0.0174283635332858 -0.0285829661173474 -0.0233898373552725 1.40529799264088e-17 0.031296324887301 0.0513307676627465 0.0422774915144242 -1.71758643544996e-17 -0.0587694232708108 -0.100040381410716 -0.087141817666429 1.92715699998162e-17 0.150831175979548 0.323737474740084 0.461060176875571 0.513307676627465 0.461060176875571 0.323737474740084 0.150831175979548 1.92715699998162e-17 -0.087141817666429 -0.100040381410716 -0.0587694232708108 -1.71758643544996e-17 0.0422774915144242 0.0513307676627465 0.031296324887301 1.40529799264088e-17 -0.0233898373552725 -0.0285829661173474 -0.0174283635332858 -1.03769992306702e-17];
%rcTxFilt = [-1.72985923225974e-17 -0.0591893527576443 -0.100755207313207 -0.0877644785117768 1.9409272567752e-17 0.151908921085804 0.326050699952622 0.464354624101683 0.516975451760132 0.464354624101683 0.326050699952622 0.151908921085804 1.9409272567752e-17 -0.0877644785117768 -0.100755207313207 -0.0591893527576443 -1.72985923225974e-17];
%rcTxFilt = [-0.00145819233657424 0.00167660283794244 0.00363804153661548 0.00268834592980426 -0.000583751274696097 -0.00350403382084115 -0.00340323807646869 1.36476890018101e-17 0.00396646568216291 0.00470106400808503 0.000644062647979466 -0.00556871656888028 -0.00848876358543611 -0.00410326484022757 0.00610253409841469 0.0148406138294449 0.0136798614304148 -1.07206039396737e-17 -0.0189682967190586 -0.0291104348192957 -0.0188667374279574 0.0106311861769533 0.0424438179271805 0.0519746879762158 0.0232945816623105 -0.0360414907286519 -0.0923720101279006 -0.10000588994275 -0.0262746435292967 0.126145217550282 0.31357254640918 0.467772191785943 0.527355013552541 0.467772191785943 0.31357254640918 0.126145217550282 -0.0262746435292967 -0.10000588994275 -0.0923720101279006 -0.0360414907286519 0.0232945816623105 0.0519746879762158 0.0424438179271805 0.0106311861769533 -0.0188667374279574 -0.0291104348192957 -0.0189682967190586 -1.07206039396737e-17 0.0136798614304148 0.0148406138294449 0.00610253409841469 -0.00410326484022757 -0.00848876358543611 -0.00556871656888028 0.000644062647979466 0.00470106400808503 0.00396646568216291 1.36476890018101e-17 -0.00340323807646869 -0.00350403382084115 -0.000583751274696097 0.00268834592980426 0.00363804153661548 0.00167660283794244 -0.00145819233657424];
rcTxFilt = [-0.00848977273295494 -0.00410375263794876 0.00610325957004339 0.0148423780873929 0.0136814876976658 -1.07218784092424e-17 -0.0189705516775549 -0.0291138954791167 -0.0188689803130457 0.0106324500165036 0.0424488636647747 0.0519808667473508 0.0232973509312447 -0.0360457753550969 -0.0923829913484155 -0.100017778681868 -0.0262777670691454 0.126160213742839 0.313609824035538 0.467827800726157 0.527417705721797 0.467827800726157 0.313609824035538 0.126160213742839 -0.0262777670691454 -0.100017778681868 -0.0923829913484155 -0.0360457753550969 0.0232973509312447 0.0519808667473508 0.0424488636647747 0.0106324500165036 -0.0188689803130457 -0.0291138954791167 -0.0189705516775549 -1.07218784092424e-17 0.0136814876976658 0.0148423780873929 0.00610325957004339 -0.00410375263794876 -0.00848977273295494];
rcRxFilt = [-0.00848977273295494 -0.00410375263794876 0.00610325957004339 0.0148423780873929 0.0136814876976658 -1.07218784092424e-17 -0.0189705516775549 -0.0291138954791167 -0.0188689803130457 0.0106324500165036 0.0424488636647747 0.0519808667473508 0.0232973509312447 -0.0360457753550969 -0.0923829913484155 -0.100017778681868 -0.0262777670691454 0.126160213742839 0.313609824035538 0.467827800726157 0.527417705721797 0.467827800726157 0.313609824035538 0.126160213742839 -0.0262777670691454 -0.100017778681868 -0.0923829913484155 -0.0360457753550969 0.0232973509312447 0.0519808667473508 0.0424488636647747 0.0106324500165036 -0.0188689803130457 -0.0291138954791167 -0.0189705516775549 -1.07218784092424e-17 0.0136814876976658 0.0148423780873929 0.00610325957004339 -0.00410375263794876 -0.00848977273295494];

%Xilinx Settings
mult_pipeline = 3;
cr_mult_pipeline = 1;
regular_pipeline = 1;

%Tx Interp filter
tx_interp_filt = firpm(30, [0.0, 0.25, 0.3, 1], [1, 1, 0, 0]);

% %DC Blocking filter:
% fs = overSampleFreq; % Sampling frequency
% f = [0 200e3];          % Cutoff frequencies
% a = [0 1];           % Desired amplitudes
% dev = [.001 .4]; %Passband needs to be exceptionally flat
% 
% %fs = overSampleFreq/overSample; % Sampling frequency
% %f = [0 100e3];          % Cutoff frequencies
% %a = [1 0];           % Desired amplitudes
% %dev = [.05 .02]; %Passband needs to be exceptionally flat
% 
% dc_avg = 64;
% dc_avg_filt = ones(1, dc_avg)./dc_avg;
% 
% [dc_n,fo,ao,w] = firpmord(f,a,dev,fs);
% dc_n
% dc_block = firpm(dc_n,fo,ao,w);
% freqz(dc_block,1,1024,fs)

%Carrier Recovery

cr_bound_thresh = 2^-8;

cr_smooth_samples = 4;
cr_smooth_num = (1/cr_smooth_samples).*ones(1, cr_smooth_samples);
%cr_smooth_num = firpm(cr_smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
%cr_smooth_denom = zeros(1, cr_smooth_samples);
%cr_smooth_denom(1) = 1;
%cr_smooth_denom(2) = -0.90;

cr_smooth_second_num = [1, 0];
cr_smooth_second_denom = [1, -0.999];

cr_i_preamp = 2^-7+2^-8;
cr_integrator1_decay = 1;
cr_integrator2_decay = 0;

cr_i = 0.015;
%cr_i = 0;
cr_p = 0.015;
%cr_p = 0.0080;
%cr_p = 0.0075;

%[cr_smooth_num, cr_smooth_denom] = butter(cr_smooth_samples, 0.30, 'low');

%cr_smooth_amp = 0;

cr_pre_scale = 1;
cr_pre_stage2_scale = 1;
cr_post_scale = 1;

cr_integrator1_saturation = 0.6;
cr_integrator2_saturation = 0.6;

cr_int1_sat_up  =  cr_integrator1_saturation;
cr_int1_sat_low = -cr_integrator1_saturation;
cr_int2_sat_up  =  cr_integrator2_saturation;
cr_int2_sat_low = -cr_integrator2_saturation;

frac_lut_domain_cr = 64;
frac_lut_res_cr = 2^-4;
frac_lut_range_max_cr = 127;
frac_lut_range_min_cr = -frac_lut_range_max_cr;
frac_lut_table_breaks_cr = -frac_lut_domain_cr:frac_lut_res_cr:(frac_lut_domain_cr-1);
frac_lut_table_data_cr = 1./frac_lut_table_breaks_cr;

for ind = 1:length(frac_lut_table_data_cr)
   if frac_lut_table_data_cr(ind) > frac_lut_range_max_cr
       frac_lut_table_data_cr(ind) = frac_lut_range_max_cr;
   elseif frac_lut_table_data_cr(ind) < frac_lut_range_min_cr
       frac_lut_table_data_cr(ind) = frac_lut_range_min_cr;
   end
end


%Timing Recovery
frac_lut_domain = 256;

%frac_lut_res = 2^-7;
frac_lut_res = 2^-5;

frac_lut_range_max = 512;
frac_lut_range_min = -frac_lut_range_max;
frac_lut_table_breaks = -frac_lut_domain:frac_lut_res:(frac_lut_domain-1);
frac_lut_table_data = 1./frac_lut_table_breaks;

for ind = 1:length(frac_lut_table_data)
   if frac_lut_table_data(ind) > frac_lut_range_max
       frac_lut_table_data(ind) = frac_lut_range_max;
   elseif frac_lut_table_data(ind) < frac_lut_range_min
       frac_lut_table_data(ind) = frac_lut_range_min;
   end
end


averaging_samples = 128;
averaging_num = ones(1, averaging_samples);
averaging_denom = zeros(1, averaging_samples);
averaging_denom(1) = 1;

timing_smooth_samples = 128;
%[smooth_num, smooth_denom] = butter(smooth_samples, 0.35, 'low');
%smooth_num = firpm(smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
timing_smooth_num = (1/timing_smooth_samples).*ones(1, timing_smooth_samples);
timing_smooth_denom = zeros(1, timing_smooth_samples);

timing_i = 0.35;
timing_p = 40;
timing_d = 0;

timing_pre_scale = 0.0001;
timing_pre_stage2_scale = 1;

timing_post_scale = 1;

timing_integrator1_decay=0.999;
timing_integrator2_decay=0;

%for 256 smoothing
%i=0.85, p=100, d=25 or 10

%alt
%i=0.075, p=125, d=50 or 0

%for 512 smoothing
%i=0.25, p=85, d=0.85

%alt
%i=0.1, p=77.5, d=0

%smooth_num = [-0.000291723590836063 -0.00189040309614012 -0.00292818756339082 -0.00465671740235307 -0.00627225726025284 -0.00748117979971559 -0.00784951042322378 -0.00706790676162783 -0.00504024683234228 -0.00197291259925477 0.00161229674999934 0.00495396936361733 0.00721256543859064 0.00768858301637501 0.00604275550354361 0.00245513351781428 -0.00233533446972779 -0.0071456688820574 -0.0106052499779213 -0.0115138806128092 -0.00920500804274433 -0.00382440805589127 0.00358205511814609 0.0112116568949578 0.0168877131886811 0.0186025199453639 0.0151051821901078 0.00638111222231867 -0.0061224001760283 -0.0196057813722362 -0.030387605228581 -0.0346529496038089 -0.0293287477668018 -0.0128886191262846 0.0141156057755088 0.0489367760994866 0.0869929664510594 0.122651800554721 0.150283146189454 0.165358043121494 0.165358043121494 0.150283146189454 0.122651800554721 0.0869929664510594 0.0489367760994866 0.0141156057755088 -0.0128886191262846 -0.0293287477668018 -0.0346529496038089 -0.030387605228581 -0.0196057813722362 -0.0061224001760283 0.00638111222231867 0.0151051821901078 0.0186025199453639 0.0168877131886811 0.0112116568949578 0.00358205511814609 -0.00382440805589127 -0.00920500804274433 -0.0115138806128092 -0.0106052499779213 -0.0071456688820574 -0.00233533446972779 0.00245513351781428 0.00604275550354361 0.00768858301637501 0.00721256543859064 0.00495396936361733 0.00161229674999934 -0.00197291259925477 -0.00504024683234228 -0.00706790676162783 -0.00784951042322378 -0.00748117979971559 -0.00627225726025284 -0.00465671740235307 -0.00292818756339082 -0.00189040309614012 -0.000291723590836063];
%smooth_denom = zeros(size(smooth_num));
%smooth_denom(1) = 1;

timing_integrate1_saturate = 2.5e-3;
timing_integrate2_saturate = 2.5e-3;

tr_int1_sat_up  =  timing_integrate1_saturate;
tr_int1_sat_low = -timing_integrate1_saturate;
tr_int2_sat_up  =  timing_integrate2_saturate;
tr_int2_sat_low = -timing_integrate2_saturate;

thetaInit = 0;

expDomain = 3.3;
expTol = .1;
expResolution = 2^-5;
trigger = (80/128)^2;

%[a, b] = butter(8, .3);

atanDomain = 5;
atanResolution = 2^-9;

atanDomainTiming = 256;
atanResolutionTiming = 2^-5;

%Recieve Matching Filter Coefs (could not implement recieve match filter
%since no decemation was used)

%AGC config
agc_detector_taps = 128;
agc_detector_coef = ones(1,agc_detector_taps)./agc_detector_taps;

lnDomain = 16;
lnResolution = 2^-7;

agcSaturation = 4;

agc_sat_up  =  agcSaturation;
agc_sat_low = -agcSaturation;

agcExpDomain = agcSaturation;
agcExpResolution = 2^-7;

agcDesired = 0;
%agcStep = 2^-10+2^-11;
%agcStep = 2^-11;
agcStep = 2^-12;
%agcStep = 2^-13;

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

after = zeros(100, 1);

%Note that numtiply by -1 because BPSK modulation has '0' at 1+0j and
%'1' at -1+0j
xCTRL_PRE_adj = (xCTRL_PRE.*-1 + 1)./2;

rSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1).*exp(j*pi*nSC_STFRep/2), -Ga_128(mod(nSC_STFNeg, 128)+1).*exp(j*pi*nSC_STFNeg/2)); %+1 is for matlab
rSC_STF   = transpose(rSC_STF);
rSC_STF_I = real(xSC_STF);
rSC_STF_Q = imag(xSC_STF);

cbTol    = int16(36);
guardInt = int16(4);
wordLen  = int16(8);
guardTol = int16(5);

invertedTol = int16(8);

expectedWidth = int16(1);
%expectedWidth = int16(4);
%expectedPer = 128;
expectedPer = int16(128*expectedWidth);
tol         = int16(15+expectedPer*3); %allow for a momentary loss (ie. due to adaptive filtering)

outBuffer = zeros(1024,1);
