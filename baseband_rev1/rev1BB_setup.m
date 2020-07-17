%% Temporary Assignment of Partitions
TxResampleModulatorPartition = 1;
TxRRCFilterPartition = 2;
RxRRCPartition = 3;
RxAGCPartition = 4;
RxTimingRecoveryPartition = 5;
RxCoarseCFOPartition = 6;
RxEQPartition = 7;
RxFineCFOPartition = 8;
RxDemodPartition = 9;
RxPackerPartition = 9;
RxHeaderParsePartition = 9;
RxPacketControllerPartition = 10;
RxFreezeControllerPartition = 10;

%% Setup Packet Format
header_len_bytes = 8; %A 8 byte header of mod_type, type, src, dst, net_id (2 bytes), len (2 bytes).  The 4 byte CRC will be appended to the end of the frame
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

%% Setup Frequencies
carrierFreq = 1e6+.1; %This is the carrier frequency of the mixer
overSampleFreq = 80e6; %This is the sampling frequency of the ADC/DAC.  This includes the oversampling factor
overSample = 4; %Number of (complex) samples per symbol

baseFreq = overSampleFreq/overSample; %The symbol rate
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;

%% Setup Golay
golayType = 32;
golay_type = golayType;
Ga_32  = [+1, +1, +1, +1, +1, -1, +1, -1, -1, -1, +1, +1, +1, -1, -1, +1, +1, +1, -1, -1, +1, -1, -1, +1, -1, -1, -1, -1, +1, -1, +1, -1];
Gb_32  = [-1, -1, -1, -1, -1, +1, -1, +1, +1, +1, -1, -1, -1, +1, +1, -1, +1, +1, -1, -1, +1, -1, -1, +1, -1, -1, -1, -1, +1, -1, +1, -1];
D_32   = [ 1,  4,  8,  2, 16];
W_32   = [-1,  1, -1,  1, -1];

Gu_128_s = cat(2, -Gb_32, -Ga_32, Gb_32, -Ga_32);
Gv_128_s = cat(2, -Gb_32, Ga_32, -Gb_32, -Ga_32);

nSpectrum_STFRepCount_short = 60;
nSpectrum_STFRep_short = 0:1:(nSpectrum_STFRepCount_short*32-1);
nSpectrum_STFNeg_short = (nSpectrum_STFRepCount_short*32):1:((nSpectrum_STFRepCount_short+1)*32-1);
nSpectrum_STFFin_short = ((nSpectrum_STFRepCount_short+1)*32):1:((nSpectrum_STFRepCount_short+2)*32-1);
nSpectrumAck_STFRepCount_short = 13;
nSpectrumAck_STFRep_short = 0:1:(nSpectrumAck_STFRepCount_short*32-1);
nSpectrumAck_STFNeg_short = (nSpectrumAck_STFRepCount_short*32):1:((nSpectrumAck_STFRepCount_short+1)*32-1);
nSpectrumAck_STFFin_short = ((nSpectrumAck_STFRepCount_short+1)*32):1:((nSpectrumAck_STFRepCount_short+2)*32-1);
xSpectrum_STF_short = cat(2, Gb_32(mod(nSpectrum_STFRep_short, 32)+1), -Gb_32(mod(nSpectrum_STFNeg_short, 32)+1), -Ga_32(mod(nSpectrum_STFFin_short, 32)+1)); %+1 is for matlab
xSpectrum_CEF_short = cat(2, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s, Gu_128_s, Gv_128_s);
xSpectrum_PRE_short = cat(2, xSpectrum_STF_short, xSpectrum_CEF_short);
x_STF = xSpectrum_STF_short;
x_STFRepCount = nSpectrum_STFRepCount_short;
x_CEF = xSpectrum_CEF_short;
x_PRE = xSpectrum_PRE_short;

preLen = length(x_PRE);

%Note that numtiply by -1 because BPSK modulation has '0' at 1+0j and
%'1' at -1+0j
x_PRE_adj = transpose((x_PRE.*-1 + 1)./2);

after = zeros(100, 1);

cefLen = length(x_CEF);

%% Setup CRC (Not Currently Used But Relied on By Fctns)
% Same poly as Ethernet (IEEE 802.3)
% CRC-32 = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
%           32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
%            1           0           4           C           1           1           D           B           7
crc_poly = [ 1  0  0  0  0  0  1  0  0  1  1  0  0  0  0  0  1  0  0  0  1  1  1  0  1  1  0  1  1  0  1  1  1 ];
crc_init =    [ 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1 ];
crc_xor  =    [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ];

%% Setup Correlator Peak Detect
corr_peak_trigger = 0.50;
corr_peak_exclude_trigger = 1+corr_peak_trigger; %Used to exclude false peaks when AGC still settling

%% Setup Pulse Shaping Filter (Root Raised Cosine)
rcFiltRolloffFactor = 0.1;
rcFiltSpanSymbols = 16;
rcFileLinearAmpGain = 1;

%Setup Root Raised Cosine Matched Filters
rcSqrtFilt = rcosdesign(rcFiltRolloffFactor, rcFiltSpanSymbols, overSample, 'sqrt');

rcTxFilt = rcSqrtFilt;
rcRxFilt = rcSqrtFilt;

%Setup Raised Cosine Filter (used to correlate against pulse shape post Rx matched filter)
rcNormalFilt = rcosdesign(rcFiltRolloffFactor, rcFiltSpanSymbols, overSample, 'normal');
rcNormalFilt = rcNormalFilt./2;

% rcFiltSpanSamp = rcFiltSpanSymbols*overSample+1; %The filter designer makes the order odd
rcFiltSpanSamp = length(rcNormalFilt); %This should be the same as above
rcFiltGrpDelay = (rcFiltSpanSamp-1)/2;
%Alternate derivation
% rcNormalFilt = 0.5*conv(rcTxFilt, rcRxFilt);
% rcNormalFilt = 0.5*conv(rcTxFilt, rcRxFilt, 'same');

%% Setup AGC
agc_detector_taps = 16;

agcSaturation = 12;
agc_sat_up  =  agcSaturation;
agc_sat_low = -agcSaturation;
agcDesired = 0;
agcStep = 2^-8;

%Threshold for post AGC power before correlator peaks are passed
%Prevents triggering when AGC still settling
agcSettleThresh = 0.65;

%% Setup Timing Recovery
timing_differentiator_len = 15; %The block adds 1
timing_differentiator_grpDelay_roundUp = ceil((timing_differentiator_len)/2); %The block adds one which is subtracted again here.  The group delay is rounded up to a full sample

timingDifferentiatorFiltObj =  designfilt('differentiatorfir','FilterOrder',timing_differentiator_len);
timingDifferentiatorFilt = timingDifferentiatorFiltObj.Coefficients;

timingRecoveryFreqCorrectionAvgLen = 32;
timingRecoveryFreqCorrectionDiscardLastN = 2; %Discard the last 2 peaks before the CFO due to changing signal changing the shape of the correlation

trTappedDelayBase = 40;
trFarrowTaps = 4;
trTappedDelayLen = trTappedDelayBase+trFarrowTaps; %Include samples for the interpolator
trInitialDelay = round((trTappedDelayLen+1-trFarrowTaps)/2+1);

trLenToFSM = timing_differentiator_grpDelay_roundUp; %Omitted correlator delay as the peak will occure immediatly the last symbol in the correlated sequence enters the correlator.  However, the differentiator does introduce additional group delay
%The ideal match would be to bring the symbol clock / strobe into the 
%future (from it's standpoint) to align with the samples before all the 
%filters.  Hence, the negative sign.
trMatch = mod(-trLenToFSM, overSample);

trEarlyLateAvgNumSamp = 64;
trEarlyLatePGain = -0.005;
trEarlyLateIGain = -0.0000005;
enableTRFreqCorrection = true;

timing_p = -0.75;

timingMaxSymbols = dataLenSymbols + length(x_CEF) + length(x_STF)/x_STFRepCount*2+100; %This is to catch any weird case where a reset is not recieved by the timing block.

timing_tolerance = 4; %This is used to allow a shift of the peak by +- 1 sample per period as the fractional delay is adjusted
timing_cefEarlyWarningTollerance = 5; %This is because CEF early warning does not have its delay corrected.  As a result, extra tollerance is needed to account for any integer delay changes that occur durring the STF and should be based on the expected maximum timing frequency offset

%% Setup Coarse CFO
cfoNcoQuantizedAccumBits = 12;
cfoNcoWordLen = 16;

%% Setup EQ
lmsEqDepth = 38;
lmsStep_init =  0.012; %LMS
lmsStep_final = 0.006;
lmsStep_meta = (lmsStep_final - lmsStep_init)/cefLen;

%% Setup Demod
%For 16QAM
qam16Mod = comm.RectangularQAMModulator('ModulationOrder', 16, 'NormalizationMethod', 'Average power', 'AveragePower', 1, 'SymbolMapping', 'Binary');
qam16_points = constellation(qam16Mod);
qam16_power_normalized_distance = abs(qam16_points(1) - qam16_points(2));
qam16_hdl_distance = 2;
qam16_demod_scale_factor = qam16_hdl_distance/qam16_power_normalized_distance;

%% Setup Fine CFO
cr_smooth_samples = 4;
cr_p = 0.015;
cr_i = 0.020;
cr_i_preamp = 2^-9;

cr_integrator1_saturation = 0.6;
cr_integrator1_decay = 1;
cr_saturation2 = 0.6;

cr_int1_sat_up  =  cr_integrator1_saturation;
cr_int1_sat_low = -cr_integrator1_saturation;
cr_sat2_up  =  cr_saturation2;
cr_sat2_low = -cr_saturation2;

%% Setup Rx Controller
cefEarlyWarning = 256;
RxFeedbackPipelining = 128*3; %This is in samples
feedbackResetBuffer = 4; 

delayToOutputFromDataFSM = lmsEqDepth/2-1;
timingRecoveryDoneSamplesEarly = floor(RxFeedbackPipelining/overSample) - delayToOutputFromDataFSM-1; %Extra -1 so that the reset comes after the done

if timingRecoveryDoneSamplesEarly<1
    error('timingRecoveryDoneSamplesEarly must be at least 1')
end

minSTFPeaks = 3;

%% Setup Feedback Controller
freeze_agc_in_CEF     = true;
freeze_agc_in_HeaderPayload = true;

freeze_fineCFO_in_CEF      = false;
freeze_fineCFO_in_HeaderPayload  = false;

RxFreezeFeedbackPipelining = RxFeedbackPipelining; %This is in samples