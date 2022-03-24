%% Temporary Assignment of Partitions
% Tx Partitions
TxResampleModulatorPartition = 1;
TxRRCFilterPartition = 2;

% Rx Partitions

% -Fine Grain Partitioning
% RxRRCPartition = 1;
% RxAGCPwrAvgPartition = 2;
% RxAGCCorrectionLoopPartition = 2;
% RxTimingRecoveryGolayCorrelatorPartition = 3;
% RxTimingRecoveryGolayPeakDetectPartition = 4;
% RxTimingRecoveryControlPartition = 5;
% RxTimingRecoveryCalcDelayError = 6;
% RxTimingRecoveryFreqEstPartition = 6;
% RxTimingRecoveryDelayAccumPartition = 7;
% RxTimingRecoveryVariableDelayPartition = 8;
% RxTimingRecoverySymbolClockPartition = 8;
% RxTimingRecoveryEarlyLatePartition = 9;
% RxSymbGolayCorrelatorPartition = 10;
% RxSymbGolayPeakDetectPartition = 11;
% RxCoarseCFOPartition = 12;
% RxEQPartition = 13;
% RxFineCFOPartition = 14;
% RxDemodPartition = 15;
% RxHeaderDemodPartition = 16;
% RxHeaderParsePartition = 17;
% RxPackerPartition = 18;
% RxPacketControllerPartition = 19;
% RxFreezeControllerPartition = 19;

% -Fine Grain Partitioning
RxRRCPartition = 1;
RxAGCPwrAvgPartition = 2;
RxAGCCorrectionLoopPartition = 2;
RxTimingRecoveryGolayCorrelatorPartition = 3;
RxTimingRecoveryGolayPeakDetectPartition = 3;
RxTimingRecoveryControlPartition = 5;
RxTimingRecoveryCalcDelayError = 6;
RxTimingRecoveryFreqEstPartition = 6;
RxTimingRecoveryDelayAccumPartition = 6;
RxTimingRecoveryVariableDelayPartition = 7;
RxTimingRecoverySymbolClockPartition = 8;
RxTimingRecoveryEarlyLatePartition = 9;
RxSymbGolayCorrelatorPartition = 10; % * Want to merge these due to workload but need multiple execution domains in a single partition to avoid deadlock
RxSymbGolayPeakDetectPartition = 10; % * - Using delays to break deadlock (with delay matching)
RxCoarseCFOPartition = 10;           % *
RxEQPartition = 12;
RxEQ2Partition = 13;
% RxFineCFOPartition = 13;
% RxFineCFOCorrectComputePartition = 14;
% RxHeaderDemodPartition = 15; % * Want to merge these due to workload but need multiple execution domains in a single partition to avoid deadlock
% RxHeaderParsePartition = 15; % *
RxDemodPartition = 16;       % *
RxPackerPartition = 16;      % *
RxPacketControllerPartition = 16;
RxFreezeControllerPartition = 16;

%All 1 Partition
% RxRRCPartition = 1;
% RxAGCPwrAvgPartition = 1;
% RxAGCCorrectionLoopPartition = 1;
% RxTimingRecoveryGolayCorrelatorPartition = 1;
% RxTimingRecoveryGolayPeakDetectPartition = 1;
% RxTimingRecoveryControlPartition = 1;
% RxTimingRecoveryCalcDelayError = 1;
% RxTimingRecoveryFreqEstPartition = 1;
% RxTimingRecoveryDelayAccumPartition = 1;
% RxTimingRecoveryVariableDelayPartition = 1;
% RxTimingRecoverySymbolClockPartition = 1;
% RxTimingRecoveryEarlyLatePartition = 1;
% RxSymbGolayCorrelatorPartition = 1; % * Want to merge these due to workload but need multiple execution domains in a single partition to avoid deadlock
% RxSymbGolayPeakDetectPartition = 1; % *
% RxCoarseCFOPartition = 1;           % *
% RxEQPartition = 1;
% RxEQ2Partition = 1;
% % RxFineCFOPartition = 1;
% % RxFineCFOCorrectComputePartition = 1;
% % RxHeaderDemodPartition = 1; % * Want to merge these due to workload but need multiple execution domains in a single partition to avoid deadlock
% % RxHeaderParsePartition = 1; % *
% RxDemodPartition = 1;       % *
% RxPackerPartition = 1;      % *
% RxPacketControllerPartition = 1;
% RxFreezeControllerPartition = 1;

%% Sub-Blocking
% Tx Sub-Blocking
TxResampleModulatorSubBlocking = 24;
TxRRCFilterSubBlocking = 24;

% % Rx Sub-Blocking
% RxRRCSubBlocking = 24;
% RxAGCPwrAvgSubBlocking = 8;
% RxAGCCorrectionLoopSubBlocking = 8;
% RxTimingRecoveryGolayCorrelatorSubBlocking = 24;
% RxTimingRecoveryGolayPeakDetectSubBlocking = 24;
% RxTimingRecoveryControlSubBlocking = 24;
% RxTimingRecoveryCalcDelayErrorSubBlocking = 8;
% RxTimingRecoveryFreqEstSubBlocking = 8;
% RxTimingRecoveryDelayAccumSubBlocking = 8;
% RxTimingRecoveryVariableDelaySubBlocking = 8;
% RxTimingRecoverySymbolClockSubBlocking = 8;
% RxTimingRecoveryEarlyLateSubBlocking = 8;
% RxSymbGolayCorrelatorSubBlocking = 24;
% RxSymbGolayPeakDetectSubBlocking = 24;
% RxCoarseCFOSubBlocking = 8;
% RxEQSubBlocking = 24;
% RxEQ2SubBlocking = 8;
% RxDemodSubBlocking = 8;
% RxPackerSubBlocking = 8;
% RxPacketControllerSubBlocking = 24;
% RxFreezeControllerSubBlocking = 24;

% Rx Sub-Blocking (Clock Domains have one Sub-Blocking Length)
RxRRCSubBlocking = 24;
RxAGCPwrAvgSubBlocking = 8;
RxAGCCorrectionLoopSubBlocking = 8;
RxTimingRecoveryGolayCorrelatorSubBlocking = 24;
RxTimingRecoveryGolayPeakDetectSubBlocking = 24;
RxTimingRecoveryControlSubBlocking = 24;
RxTimingRecoveryCalcDelayErrorSubBlocking = 8;
RxTimingRecoveryFreqEstSubBlocking = 8;
RxTimingRecoveryDelayAccumSubBlocking = 8;
RxTimingRecoveryVariableDelaySubBlocking = 8;
RxTimingRecoverySymbolClockSubBlocking = 24; % Actually want this to be 8 but part of this is in the symbol clock domain,
RxTimingRecoveryEarlyLateSubBlocking = 8;
RxSymbGolayCorrelatorSubBlocking = 24;
RxSymbGolayPeakDetectSubBlocking = 24;
RxCoarseCFOSubBlocking = 24;
RxEQSubBlocking = 24;
RxEQ2SubBlocking = 24;
RxDemodSubBlocking = 24;
RxPackerSubBlocking = 24;
RxPacketControllerSubBlocking = 24;
RxFreezeControllerSubBlocking = 24;

%% Setup Packet Format
header_len_bytes = 8; %A 8 byte header of mod_type, type, src, dst, net_id (2 bytes), len (2 bytes).  The 4 byte CRC will be appended to the end of the frame
mod_scheme_len_bytes = 1;
crc_len_bytes = 4;

radixHeader = 2; %BPSK
radixMax = 256;
bitsPerSymbol = log2(radix);
bitsPerSymbolHeader = log2(radixHeader);
bitsPerSymbolMax = log2(radixMax);

bitsPerPackedWordRx = bitsPerSymbolMax; %This is what returned from the packed data output of the Rx

% 0 = BPSK
% 1 = QPSK
% 2 = 16QAM
% 3 = 256QAM
modKeys = [0, 1, 2, 3];
modBPS  = [1, 2, 4, 8];

%Set the frame size based on the modulation scheme to maintain the same
%number of symbols per packet.
payload_len_bytes = fixedPayloadLength(radix);

frame_len_bytes = payload_len_bytes + crc_len_bytes;
headerLenSymbols = header_len_bytes*8/bitsPerSymbolHeader;
dataLenSymbols = headerLenSymbols + frame_len_bytes*8/bitsPerSymbol; %/2 for QPSK
payload_len_symbols = payload_len_bytes*8/bitsPerSymbol; %/2 for QPSK

modFieldLenSymbols = mod_scheme_len_bytes*8/bitsPerSymbolHeader;

%% Setup Frequencies
carrierFreq = 1e6+.1; %This is the carrier frequency of the mixer
overSampleFreq = 80e6; %This is the sampling frequency of the ADC/DAC.  This includes the oversampling factor
overSample = 3; %Number of (complex) samples per symbol

baseFreq = overSampleFreq/overSample; %The symbol rate
basePer = 1/baseFreq;
overSamplePer = 1/overSampleFreq;

unrollFactor = 8;

channelizeRateConvertNumerator = 7;
channelizeRateConvertDenominator = 6;

%Splitting Channel into 3 parts
%B = Fs
%Bandwidth of each channel = B/3
%Center Frequencies at 0, 2B/3, -2B/3

%Calculate phase increment of NCOs
channels = 3;
channelizerNCOWidth = 16;
channelizerNCOAccumulatorBits = 12;
chan0NCOPhaseIncrement = -2*2^channelizerNCOWidth/3;
chan2NCOPhaseIncrement = 2*2^channelizerNCOWidth/3;

channelizedOversampleFreq = overSampleFreq*channelizeRateConvertNumerator/channelizeRateConvertDenominator;
channelizedEffectiveOversampleForChannelSimulation = channelizedOversampleFreq/(baseFreq*overSample);

% txChannelizerFilter = designMultirateFIR(channelizeRateConvertNumerator, channelizeRateConvertDenominator, 0.01);
%The RRC filter does not provice great stopband attenuation, will filter
%again to form a narrower signal
% txChannelizerBasebandFilter = firpm(txChannelizerBasebandFilterOrder, [0, (1/overSample+1/overSample*channelizedEffectiveOversampleForChannelSimulation)/2, 1/overSample*channelizedEffectiveOversampleForChannelSimulation, 1], [1, 1, 0, 0]);
% txChannelizerBasebandFilterOrder = 120;
% txChannelizerBasebandFilterSepc = fdesign.lowpass('N,Fp,Fst,Ap', txChannelizerBasebandFilterOrder, (1/overSample+1/overSample*channelizedEffectiveOversampleForChannelSimulation)/2, 1/overSample*channelizedEffectiveOversampleForChannelSimulation, 0.1);
txChannelizerBasebandFilterSepc = fdesign.lowpass('Fp,Fst,Ap,Ast', 1/overSample*(1+(channelizedEffectiveOversampleForChannelSimulation-1)*2/3), 1/overSample*channelizedEffectiveOversampleForChannelSimulation, 0.05, 60);
txChannelizerBasebandFilterDesign = design(txChannelizerBasebandFilterSepc,'equiripple');
txChannelizerBasebandFilter = txChannelizerBasebandFilterDesign.Numerator;

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

%% Pkt Control
pktLenPlusCEF = cefLen+dataLenSymbols;

%% Setup CRC (Not Currently Used But Relied on By Fctns)
% Same poly as Ethernet (IEEE 802.3)
% CRC-32 = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
%           32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
%            1           0           4           C           1           1           D           B           7
crc_poly = [ 1  0  0  0  0  0  1  0  0  1  1  0  0  0  0  0  1  0  0  0  1  1  1  0  1  1  0  1  1  0  1  1  1 ];
crc_init =    [ 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1 ];
crc_xor  =    [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ];

%% Setup Correlator Peak Detect
corr_peak_trigger = 0.40;
corr_peak_exclude_trigger = 1+corr_peak_trigger; %Used to exclude false peaks when AGC still settling

%% Setup I/Q Correction
% IQ_Imbal_Tx_I = 1.1;
% IQ_Imbal_Tx_Q = 1.0;
% 
% IQ_Imbal_Rx_I = 1.0;
% IQ_Imbal_Rx_Q = 1.1;

IQ_Imbal_Alpha = 0.95;
IQ_Imbal_Phi_Deg = -2;
IQ_Imbal_Phi = IQ_Imbal_Phi_Deg*pi/180;

%% Setup Pulse Shaping Filter (Root Raised Cosine)
rcFiltRolloffFactor = 0.2;
rcFiltSpanSymbols = 20;
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

%% Setup Rx Pre-Filter
% rxPreFiltOrder = 200;
% rxPreFiltPass = 1/overSample*(1+rcFiltRolloffFactor);
% rxPreFiltStop = 1/overSample*(1+3*rcFiltRolloffFactor);
% 
% rxPreFilt = firpm(rxPreFiltOrder, [0, rxPreFiltPass, rxPreFiltStop, 1], [1, 1, 0, 0]);

%% Setup AGC
agc_detector_taps = 16;

agcSaturation = 12;
agc_sat_up  =  agcSaturation;
agc_sat_low = -agcSaturation;
agcDesired = 0;
agcStep = 2^-8;

agcLnStart = 1e-2;
agcLnStep = 2^-6;
agcLnSteps = 2e3;
agcLnBreakpoints = (agcLnStep.*(0:(agcLnSteps-1)))+agcLnStart;

agcExpStart = agc_sat_low;
agcExpStop = agc_sat_up;
agcExpStep = 2^-6;
agcExpSteps = ceil((agcExpStop-agcExpStart)/agcExpStep);
agcExpBreakpoints = (agcExpStep.*(0:agcExpSteps))+agcExpStart;

%Threshold for post AGC power before correlator peaks are passed
%Prevents triggering when AGC still settling
agcSettleThresh = 0.65;

agcLoopPipeline = RxAGCCorrectionLoopSubBlocking;

%% Setup Timing Recovery
timing_differentiator_len = 15; %The block adds 1

%Add 
timing_correlator_pipeline = 0;
timing_differentiator_pipeline = 0;
timing_phase_detect_delay = 1;
timing_var_delay_out_pipeline = 0;

timing_differentiator_grpDelay_roundUp = ceil((timing_differentiator_len)/2+timing_differentiator_pipeline); %The block adds one which is subtracted again here.  The group delay is rounded up to a full sample

timingDifferentiatorFiltObj =  designfilt('differentiatorfir','FilterOrder',timing_differentiator_len);
timingDifferentiatorFilt = timingDifferentiatorFiltObj.Coefficients;

timingRecoveryFreqCorrectionAvgLen = 32;
timingRecoveryFreqCorrectionDiscardLastN = 3; %Discard the last 2 peaks before the CFO due to changing signal changing the shape of the correlation

trTappedDelayBase = 40;
trFarrowTaps = 4;
trTappedDelayLen = trTappedDelayBase+trFarrowTaps; %Include samples for the interpolator
trInitialDelay = round((trTappedDelayLen+1-trFarrowTaps)/2+1);

trLenToFSM = timing_differentiator_grpDelay_roundUp+timing_correlator_pipeline; %Omitted correlator delay as the peak will occure immediatly the last symbol in the correlated sequence enters the correlator.  However, the differentiator does introduce additional group delay
%The ideal match would be to bring the symbol clock / strobe into the 
%future (from it's standpoint) to align with the samples before all the 
%filters.  Hence, the negative sign.
trMatch = mod(-trLenToFSM, overSample);

trEarlyLateAvgNumSamp = 64;
% trEarlyLatePGain = -0.005;
% trEarlyLateIGain = -0.0000005;

% trEarlyLatePGain = -0.00225;
% trEarlyLateIGain = -0.000000050;
trEarlyLatePGain = -0.00300;
trEarlyLateIGain = -0.000000100;
% trEarlyLatePGain = 0;
% trEarlyLateIGain = 0;
enableTRFreqCorrection = true;

trCorrScaleFactor = correlationShape(Gb_32, overSample, rcTxFilt, rcRxFilt);
    
trCorrTargetScaleFactor = 0.5;

timing_p = -0.215;

trFeedbackPipelining = 120*4;

trDelayThroughCorrAndPeakDetect = golayType*overSample+timing_differentiator_grpDelay_roundUp+timing_correlator_pipeline+timing_phase_detect_delay;
trIntPhaseCounterInit = mod(-trDelayThroughCorrAndPeakDetect+timing_var_delay_out_pipeline+trTappedDelayLen/2, overSample); %The plus 1 is for the peak detect
 
%Will also delay the line being decimated (going into the selector) so that
%the feedback path of the integer phase when the packet is first detected
%does not cause samples to be lost.  This allows us to add more pipeline
%state.

timingMaxSymbols = dataLenSymbols + length(x_CEF) + length(x_STF)/x_STFRepCount*2+100; %This is to catch any weird case where a reset is not recieved by the timing block.

timing_tolerance = 4; %This is used to allow a shift of the peak by +- 1 sample per period
timing_cefEarlyWarningTollerance = 5; %This is because CEF early warning does not have its delay corrected.  As a result, extra tollerance is needed to account for any integer delay changes that occur durring the STF and should be based on the expected maximum timing frequency offset

timingControlToGolay = 128*2; %This many sample can be missed if packets are back to back

%% Setup Coarse CFO
cfoNcoQuantizedAccumBits = 12;
cfoNcoWordLen = 22;

coarseCFODeadlockResolvingDelay = 120*3;

%% Setup EQ
lmsEqDepth = 16;
% lmsStep_init =  0.005; %LMS
% lmsStep_final = 0.005;
lmsStep_init =  0.015; %LMS
lmsStep_final = 0.001;
lmsStep_meta = (lmsStep_final - lmsStep_init)/cefLen;
eqBatchSize = 8; %Currently use a int8 counter.  Update type in simulink if batch size substantially increased
eqPipeline = 120*2/overSample;
% eqPipeline = 0;

packetRxControllerDataPackerDeadlockResolvingDelay = 120*3;

%% Setup Demod
%For 16QAM
qam16Mod = comm.RectangularQAMModulator('ModulationOrder', 16, 'NormalizationMethod', 'Average power', 'AveragePower', 1, 'SymbolMapping', 'Binary');
qam16_points = constellation(qam16Mod);
qam16_power_normalized_distance = abs(qam16_points(1) - qam16_points(2));
qam16_hdl_distance = 2;
qam16_demod_scale_factor = qam16_hdl_distance/qam16_power_normalized_distance;

%For 256QAM
qam256Mod = comm.RectangularQAMModulator('ModulationOrder', 256, 'NormalizationMethod', 'Average power', 'AveragePower', 1, 'SymbolMapping', 'Binary');
qam256_points = constellation(qam256Mod);
qam256_power_normalized_distance = abs(qam256_points(1) - qam256_points(2));
qam256_hdl_distance = 2;
qam256_demod_scale_factor = qam256_hdl_distance/qam256_power_normalized_distance;

%% Setup Fine CFO
cr_smooth_samples = 4;
cr_p = 0.0022;
cr_i = 0.00010;
cr_i_preamp = 2^-9;

cr_integrator1_saturation = 0.6;
cr_integrator1_decay = 1;
cr_saturation2 = 0.6;

cr_int1_sat_up  =  cr_integrator1_saturation;
cr_int1_sat_low = -cr_integrator1_saturation;
cr_sat2_up  =  cr_saturation2;
cr_sat2_low = -cr_saturation2;

fineCFOPipeline = 128*2;

%% Setup Rx Controller
cefEarlyWarning = 256;
RxFeedbackPipelining = 120*13; %This is in symbols
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
