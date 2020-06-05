%dataLenSymbols = 4096; %orig design
header_len_bytes = 8; %This was a 32 bit CRC.  Will now be a 8 byte header of mod_type, type, src, dst, net_id (2 bytes), len (2 bytes).  The 4 byte CRC will be appended to the end of the frame
mod_scheme_len_bytes = 1;
crc_len_bytes = 4;

radix = 16; %QAM16
radixHeader = 2; %BPSK
radixMax = 16;
bitsPerSymbol = log2(radix);
bitsPerSymbolHeader = log2(radixHeader);
bitsPerSymbolMax = log2(radixMax);

bitsPerPackedWordRx = bitsPerSymbolMax; %This is what returned from the packed data output of the Rx

% 0 = BPSK
% 1 = QPSK
% 2 = 16QAM
modKeys = [0, 1, 2];
modBPS  = [1, 2, 4];

%Set the frame size based on the modulation scheme to maintain the same
%number of symbols per packet.
payload_len_bytes = fixedPayloadLength(radix);

frame_len_bytes = payload_len_bytes + crc_len_bytes;
dataLenSymbols = header_len_bytes*8/bitsPerSymbolHeader + frame_len_bytes*8/bitsPerSymbol; %/2 for QPSK
payload_len_symbols = payload_len_bytes*8/bitsPerSymbol; %/2 for QPSK

lineWidth = 60;

%% Sim Params
carrierFreq = 1e6+.1;
overSampleFreq = 80e6; %300 MHz would be optimal, now targeting 250 MHz
overSample = 4;
slowSample = 2;
baseFreq = overSampleFreq/overSample; %300 MHz
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;
slowPer = overSamplePer*slowSample;
fifo_slow_per = overSamplePer * overSample/slowSample;

RxFeedbackPipelining = 128*3;

eccTrellis = poly2trellis(7, [133 171 165]);

maxVal = 4;
minVal = -maxVal;

tx_gain = 1;
rx_gain = 1;
rx_gain_i = 1;
rx_gain_q = 1;

rcFiltRolloffFactor = 0.1;
rcFiltSpanSymbols = 16;
rcFileLinearAmpGain = 1;

rcSqrtFilt = rcosdesign(rcFiltRolloffFactor, rcFiltSpanSymbols, overSample, 'sqrt');

rcTxFilt = rcSqrtFilt;
rcRxFilt = rcSqrtFilt;

rcNormalFilt = rcosdesign(rcFiltRolloffFactor, rcFiltSpanSymbols, overSample, 'normal');

% rcFiltSpanSamp = rcFiltSpanSymbols*overSample+1; %The filter designer makes the order odd
rcFiltSpanSamp = length(rcNormalFilt); %This should be the same as above
rcFiltGrpDelay = (rcFiltSpanSamp-1)/2;
%Alternate derivation
% rcNormalFilt = 0.5*conv(rcTxFilt, rcRxFilt);
% rcNormalFilt = 0.5*conv(rcTxFilt, rcRxFilt, 'same');

%Xilinx Settings
mult_pipeline = 1;
wide_mult_pipeline = 1;
cr_mult_pipeline = 1;
regular_pipeline = 1;

%Tx Interp filter
tx_interp_filt = firpm(30, [0.0, 0.25, 0.3, 1], [1, 1, 0, 0]);

% DMM Averaging
dmm_samples = 16;
dmm_coefs = ones(1,dmm_samples)./dmm_samples;

% Sin Source
sin_source_amp = 1;
sin_source_freq = 250e6/16;

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

cr_i_preamp = 2^-9;
cr_integrator1_decay = 1;
cr_integrator2_decay = 0;

cr_i = 0.020;
%cr_i = 0;
cr_p = 0.015;
%cr_p = 0.0080;
%cr_p = 0.0075;

%[cr_smooth_num, cr_smooth_denom] = butter(cr_smooth_samples, 0.30, 'low');

%cr_smooth_amp = 0;

cr_pre_stage2_scale = 1;

cr_integrator1_saturation = 0.6;
cr_saturation2 = 0.6;

cr_int1_sat_up  =  cr_integrator1_saturation;
cr_int1_sat_low = -cr_integrator1_saturation;
cr_sat2_up  =  cr_saturation2;
cr_sat2_low = -cr_saturation2;

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

timing_smooth_samples = 32;
%[smooth_num, smooth_denom] = butter(smooth_samples, 0.35, 'low');
%smooth_num = firpm(smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
timing_smooth_num = (1/timing_smooth_samples).*ones(1, timing_smooth_samples);
timing_smooth_denom = zeros(1, timing_smooth_samples);

% timing_i = 0;
% timing_i = -1/(golay_type*overSample);
% timing_i_pre_scale = 1/2^1;
% timing_p = 45*0.0005;
% timing_p = -1/2^2;
timing_p = -1/2^2 -1/2^3;
% timing_p = 0;
timing_d = 0;
enableTRFreqCorrection = true;

timing_differentiator_len = 61; %The block adds 1
timing_differentiator_grpDelay_roundUp = ceil((timing_differentiator_len)/2); %The block adds one which is subtracted again here.  The group delay is rounded up to a full sample

timingWorstCaseOffset = overSample*1.05; %This is used by the dataFSM in the slow baseband to know how many delays to remove when signaling the early end of the packet, accounting for the pipelining delay back to the timing recovery block

timing_pre_scale = 0.0001;

timing_integrator1_decay=0.999;
timing_integrator2_decay=0;

timing_tolerance = 2; %This is used to allow a shift of the peak by +- 1 sample per period as the fractional delay is adjusted

forceSlowRxStrobed = false; %If true, strobes (ie. samples) will be passed to the slow RX while no packet has been detected. This makes the slow Rx load more consistent but wastes power/energy as computation is not needed until a packet is detected and timing recovery occurs

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
timing_saturate2 = 5e-3;

tr_int1_sat_up  =  timing_integrate1_saturate;
tr_int1_sat_low = -timing_integrate1_saturate;
tr_sat2_up  =  timing_saturate2;
tr_sat2_low = -timing_saturate2;

thetaInit = 0;

expDomain = 3.3;
expTol = .1;
expResolution = 2^-5;
%trigger = (80/128)^2;
trigger = 0.40;
trigger_tolerance = 0.35; %used after an initial peak has been detected to provide some degree of tolerance

%[a, b] = butter(8, .3);

atanDomain = 5;
atanResolution = 2^-9;

atanDomainTiming = 256;
atanResolutionTiming = 2^-5;

%Recieve Matching Filter Coefs (could not implement recieve match filter
%since no decemation was used)

%AGC config
agc_detector_taps = 16;
agc_detector_coef = ones(1,agc_detector_taps)./agc_detector_taps;

lnDomain = 16;
lnResolution = 2^-3;

agcSaturation = 12;

agc_sat_up  =  agcSaturation;
agc_sat_low = -agcSaturation;

agcExpDomain = agcSaturation;
agcExpResolution = 2^-3;

agcDesired = 0;
%agcStep = 2^-10+2^-11;
%agcStep = 2^-11;
agcStep = 2^-8;
%agcStep = 2^-13;

agcSettleThresh = 0.65;

coarseCFO_averaging_samples = 512;
atanDomainCoarseCFO = 128;
atanResolutionCoarseCFO = 2^-14;

frac_lut_domain_coarse_cfo = 32;
frac_lut_res_coarse_cfo = 2^-10;
frac_lut_range_max_coarse_cfo = 127;
frac_lut_range_min_coarse_cfo = -frac_lut_range_max_coarse_cfo;
frac_lut_table_breaks_coarse_cfo = -frac_lut_domain_coarse_cfo:frac_lut_res_coarse_cfo:(frac_lut_domain_coarse_cfo-1);
frac_lut_table_data_coarse_cfo = 1./frac_lut_table_breaks_coarse_cfo;

for ind = 1:length(frac_lut_table_data_coarse_cfo)
   if frac_lut_table_data_coarse_cfo(ind) > frac_lut_range_max_coarse_cfo
       frac_lut_table_data_coarse_cfo(ind) = frac_lut_range_max_coarse_cfo;
   elseif frac_lut_table_data_coarse_cfo(ind) < frac_lut_range_min_coarse_cfo
       frac_lut_table_data_coarse_cfo(ind) = frac_lut_range_min_coarse_cfo;
   end
end

coarseCFOAdaptDelay = 1;

coarseCFOFreqStep = 500;

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

%Smaller Golay
Gu_128_s = cat(2, -Gb_32, -Ga_32, Gb_32, -Ga_32);
Gv_128_s = cat(2, -Gb_32, Ga_32, -Gb_32, -Ga_32);

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

nSpectrum_STFRepCount = 7;
nSpectrum_STFRep = 0:1:(nSpectrum_STFRepCount*128-1);
nSpectrum_STFNeg = (nSpectrum_STFRepCount*128):1:((nSpectrum_STFRepCount+1)*128-1);
nSpectrum_STFFin = ((nSpectrum_STFRepCount+1)*128):1:((nSpectrum_STFRepCount+2)*128-1);

%nSpectrum_STFRepCount_short = 24;
% nSpectrum_STFRepCount_short = 28; %Used in SC2
nSpectrum_STFRepCount_short = 60;
%nSpectrum_STFRepCount_short = 50;
nSpectrum_STFRep_short = 0:1:(nSpectrum_STFRepCount_short*32-1);
nSpectrum_STFNeg_short = (nSpectrum_STFRepCount_short*32):1:((nSpectrum_STFRepCount_short+1)*32-1);
nSpectrum_STFFin_short = ((nSpectrum_STFRepCount_short+1)*32):1:((nSpectrum_STFRepCount_short+2)*32-1);

nSpectrumAck_STFRepCount_short = 13;
nSpectrumAck_STFRep_short = 0:1:(nSpectrumAck_STFRepCount_short*32-1);
nSpectrumAck_STFNeg_short = (nSpectrumAck_STFRepCount_short*32):1:((nSpectrumAck_STFRepCount_short+1)*32-1);
nSpectrumAck_STFFin_short = ((nSpectrumAck_STFRepCount_short+1)*32):1:((nSpectrumAck_STFRepCount_short+2)*32-1);

%Complex Baseband Preamble Signal
xSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1), -Ga_128(mod(nSC_STFNeg, 128)+1)); %+1 is for matlab
xCTRL_STF = cat(2, Gb_128(mod(nCTRL_STFRep, 128)+1), -Gb_128(mod(nCTRL_STFNeg, 128)+1), -Ga_128(mod(nCTRL_STFFin, 128)+1)); %+1 is for matlab
xSC_CEF   = cat(2, Gu_512, Gv_512, Gv_128);
xCTRL_CEF = xSC_CEF;
xSpectrum_STF = cat(2, Gb_128(mod(nSpectrum_STFRep, 128)+1), -Gb_128(mod(nSpectrum_STFNeg, 128)+1), -Ga_128(mod(nSpectrum_STFFin, 128)+1)); %+1 is for matlab
%xSpectrum_CEF = cat(2, Gu_512, Gv_512, Gu_512, Gv_512, Gu_512, Gv_512, Gu_512, Gv_512, Gu_512, Gv_512, Gv_128);
xSpectrum_CEF = cat(2, Gu_512, Gv_512, Gv_512);

xSpectrum_STF_short = cat(2, Gb_32(mod(nSpectrum_STFRep_short, 32)+1), -Gb_32(mod(nSpectrum_STFNeg_short, 32)+1), -Ga_32(mod(nSpectrum_STFFin_short, 32)+1)); %+1 is for matlab
xSpectrum_CEF_short = cat(2, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s);
%xSpectrum_CEF_short = cat(2, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s);
%xSpectrum_CEF_short = cat(2, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s);
%xSpectrum_CEF_short = cat(2, Gu_128_s, Gv_128_s, Gv_128_s);

xSpectrumAck_STF_short = cat(2, Gb_32(mod(nSpectrumAck_STFRep_short, 32)+1), +Gb_32(mod(nSpectrumAck_STFNeg_short, 32)+1), -Ga_32(mod(nSpectrumAck_STFFin_short, 32)+1)); %+1 is for matlab
xSpectrumAck_STF_short = cat(2, xSpectrumAck_STF_short, Ga_32);

xSC_PRE   = cat(2, xSC_STF, xSC_CEF);
xCTRL_PRE = cat(2, xCTRL_STF, xCTRL_CEF);
xSpectrum_PRE = cat(2, xSpectrum_STF, xSpectrum_CEF);
xSpectrum_PRE_short = cat(2, xSpectrum_STF_short, xSpectrum_CEF_short);

xSC_STF   = transpose(xSC_STF);
xCTRL_STF = transpose(xCTRL_STF);
xSC_CEF   = transpose(xSC_CEF);
xCTRL_CEF = transpose(xCTRL_CEF);
xSpectrum_STF = transpose(xSpectrum_STF);
xSpectrum_CEF = transpose(xSpectrum_CEF);
xSC_PRE   = transpose(xSC_PRE);
xCTRL_PRE = transpose(xCTRL_PRE);
xSpectrum_PRE = transpose(xSpectrum_PRE);
xSpectrum_STF_short = transpose(xSpectrum_STF_short);
xSpectrum_CEF_short = transpose(xSpectrum_CEF_short);
xSpectrum_PRE_short = transpose(xSpectrum_PRE_short);

xSpectrumAck_STF_short = transpose(xSpectrumAck_STF_short);

% select preamble
x_STF = xSpectrum_STF_short;
x_STFRepCount = nSpectrum_STFRepCount_short;
x_CEF = xSpectrum_CEF_short;
x_PRE = xSpectrum_PRE_short;

x_ACK_STF = xSpectrumAck_STF_short;

ack_stf_len_symbols = length(x_ACK_STF);
dst_field_len = 8;
flush_delay = regular_pipeline*2+mult_pipeline+4; %4 for a little additional slack

golay_type = 32;

%Pkt Types
std_pkt_type = 0;

%Note that CEF note is duplicated in the state machine function because
%(for whatever reason) an array can not be passed as a parameter for
%stateflow HDL coder
cef_note  = cat(2, Gu_512_note, Gv_512_note, Gv_128_note);
cef_note  = int16(cef_note);
cef_note_len = uint16(length(cef_note));

after = zeros(100, 1);

%Note that numtiply by -1 because BPSK modulation has '0' at 1+0j and
%'1' at -1+0j
x_PRE_adj = (x_PRE.*-1 + 1)./2;

rSC_STF   = cat(2, Ga_128(mod(nSC_STFRep, 128)+1).*exp(j*pi*nSC_STFRep/2), -Ga_128(mod(nSC_STFNeg, 128)+1).*exp(j*pi*nSC_STFNeg/2)); %+1 is for matlab
rSC_STF   = transpose(rSC_STF);
rSC_STF_I = real(xSC_STF);
rSC_STF_Q = imag(xSC_STF);

%cbTol    = int16(36);
cbTol    = int16(48-4);
guardInt = int16(4);
wordLen  = int16(8);
guardTol = int16(5);

invertedTol = int16(8);

expectedWidth = int16(1);
%expectedWidth = int16(4);
%expectedPer = 128;
expectedPer = int16(128*expectedWidth);
tol         = int16(15+expectedPer*4); %allow for a momentary loss (ie. due to adaptive filtering)

stfLen = length(x_STF);
%stfLenTol = 50;
minSTFPeaks = 3;
cefLen = length(x_CEF);
preLen = length(x_PRE);

cefEarlyWarning = 256;

outBuffer = zeros(1024,1);

agcPwrAvgNum = 128;
agc_delay_lag = 32;

lmsEqDepth = 38;
lmsStep_init =  0.012; %LMS
lmsStep_final = 0.006;
lmsStep_meta = (lmsStep_final - lmsStep_init)/cefLen;

delayToOutputFromDataFSM = lmsEqDepth/2-1 + regular_pipeline*9 + cr_mult_pipeline*4; %This is how many samples
timingRecoveryDoneSamplesEarly = floor(RxFeedbackPipelining/timingWorstCaseOffset) - delayToOutputFromDataFSM;
timingRecoveryDoneSamplesEarlyExtraDelay = 0;

%To keep the FSM simple (ie. to avoid having multiple versions), we need
%timingRecoveryDoneSamplesEarly>=1
if timingRecoveryDoneSamplesEarly == 0
    timingRecoveryDoneSamplesEarlyExtraDelay = 1;
    timingRecoveryDoneSamplesEarly = 1;
elseif timingRecoveryDoneSamplesEarly < 0
    timingRecoveryDoneSamplesEarlyExtraDelay = -timingRecoveryDoneSamplesEarly+1;
    timingRecoveryDoneSamplesEarly = 1;
end
%Delay is added on the output of the FSM to compensate

preambleSequentialDetect = 2;
default_channel = 3;
maxMsgSize = length(xSpectrum_PRE)+dataLenSymbols+300;

%Correlator Running Avg
corrAvgLen = 32;

% CRC Settings
% Same poly as Ethernet (IEEE 802.3)
% CRC-32 = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
%           32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
%            1           0           4           C           1           1           D           B           7
crc_poly = [ 1  0  0  0  0  0  1  0  0  1  1  0  0  0  0  0  1  0  0  0  1  1  1  0  1  1  0  1  1  0  1  1  1 ];
crc_init =    [ 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1 ];
crc_xor  =    [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ];
    
%For 16QAM
qam16Mod = comm.RectangularQAMModulator('ModulationOrder', 16, 'NormalizationMethod', 'Average power', 'AveragePower', 1, 'SymbolMapping', 'Binary');
qam16_points = constellation(qam16Mod);
qam16_power_normalized_distance = abs(qam16_points(1) - qam16_points(2));
qam16_hdl_distance = 2;
qam16_demod_scale_factor = qam16_hdl_distance/qam16_power_normalized_distance;

%For out of band emmissionms
%txLPF = designfilt('lowpassfir', 'PassbandFrequency', .25, 'StopbandFrequency', .3, 'PassbandRipple', 1, 'StopbandAttenuation', 140);
%txLPF_coef = txLPF.Coefficients;
txLPF_coef = firpm(90, [0 0.25 0.30 1], [1 1 0 0]);
