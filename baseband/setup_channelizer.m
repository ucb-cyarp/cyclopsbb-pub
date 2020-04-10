numChannels = 4; %This is currently fixed in the simulink model (DO NOT CHANGE)
channelizerUpDownSampling = 2; %This is currently fixed in the simulink model (DO NOT CHANGE)
%overSample, defined in rev0BB_setup.m, defines how many samples per symbol
%at the input of the Rx baseband.
samplesPerSymbol = overSample;

%If the channelizerUpDownSampling matches numChannels, then the bandwidth
%of the downsampled channel matches the bandwidth of the channel in the IF.
%For example, with 16 MHz double sided bandwidth (16 Msps complex), a 4 
%channelizer would provide each channel with 4 MHz of bandwidth (4 Msps).
%If, instead the downsampling was less than 4, the provided bandwidth to
%each channel is larger and overlaps with other channels unless properly
%filtered.  For example, if only donwsampled by 2, each channel output from
%the channelizer would be 8 Msps (8 MHz wide).  However, this now overlaps
%with the other channels without filtering.

channelBWRatio = numChannels/channelizerUpDownSampling;

%We will say that the baseband connected to the channelizer expects a
%certain number of samples per symbol.  The bandwidth of the signal
%consumed/produced by the baseband is set by the symbol rate.
% - With 1 sample/symbol,  the signal would occupy the entire bandwidth of 
%                          the channel
% - With 2 samples/symbol, the signal would occupy half of the bandwidth of 
%                          the channel
% - With 4 samples/symbol, the signal would occupy a fourth of the 
%                          bandwidth of the channel
%When devloping the prototype filter, this information is important
%because it potentially allows the prototype filter to be narrowed to
%introduce guard bands.

%channelizerFractionOfBWToFilter = 1/numChannels*channelBWRatio/samplesPerSymbol;
%Basically, we would initilly filter the bandwidth by the number of
%channels.  Next, we need to know what percentage of the channel bandwidth
%is taken up by the actual signal. numChannels/channelizerUpDownSampling is
%how much wider the decimated bandwidth is relative to the bandwidth of the
%channel in the upsampled version. 1/samplesPerSymbol of this is taken by
%the actual signal.  It turns out that num channels cancels and that it is
%simply:
channelizerFractionOfBWToFilter = 1/(channelizerUpDownSampling*samplesPerSymbol);

%Note that for this to work, 1/(channelizerUpDownSampling*samplesPerSymbol)
%should be <= 1/numChannels
if channelizerUpDownSampling*samplesPerSymbol < numChannels
    warning('Baseband signal bandwidth (not includind excess bandwidth) is larger than the channel bandwidth');
end

numTapsChannelizerProto = 100; % Number of taps in the prototype filter

%The Channelizer is partitioned into 2 channelizers
numImplChannels = numChannels / 2;

%This gets the coefficients used in a DFT of the given size.  
channelizerDftVal = dftmtx(numImplChannels);

%Create the prototype filter.
channelizerFilterExcessBw = 0.5; %0.5 is Half the width of the signal on either side (50% excess)
channelizer_pb_freq   = channelizerFractionOfBWToFilter;
channelizer_sb_freq   = channelizerFractionOfBWToFilter*(1+channelizerFilterExcessBw);
protoPM = firpm(numTapsChannelizerProto-1, [0, channelizer_pb_freq, channelizer_sb_freq, 1], [1, 1, 0, 0]);

%The raised cosine filter can also be integrated into the channelizer.
%Note that this specifis the number of samples per symbol.  There is some
%excess bw due to the beta term
channelizerRRCBeta = 0.02;
protoRRC = rcosdesign(channelizerRRCBeta, numTapsChannelizerProto, overSample, 'sqrt');

%proto = conv(ProtoPM, ProtoRRC);
%proto = ProtoRRC;
proto = protoPM;
channelizerFilterLength = length(proto);

proto_T = proto ;
%plotProto ;

% Proto = hamming (channelizerFilterLength)';

 %fvtool(Proto,'Fs',sampleFreqHz,'Color','White') % Visualize filter

co = [];
co1 = [];
channelizerPolyphaseCoeff =[;];


for index = 1 : numImplChannels
    
    for k = index : numImplChannels : channelizerFilterLength
        co1 = cat(2, co, proto(k));
        co = co1;
    end
    coeffsub1 = [ channelizerPolyphaseCoeff; co ];
    channelizerPolyphaseCoeff = coeffsub1;
    co = [];
end

%For now, both the Tx and Rx use the same filter
channelizerPolyphaseCoeff_Tx = channelizerPolyphaseCoeff;
channelizerPolyphaseCoeff_Rx = channelizerPolyphaseCoeff;

%Since this channelizer is implmented in 2 parts with one shifted relative
%to the other, we need a mixer.  We need to shift one of the channelizers
%by a half of the larger 2-channelizer channels (we are basically emulating
%a 4-channel channelizer with%2 2-channel channelizers).
%An equivalent thing to say is that we need to shift by 1 of the 4
%channelizer channels.  This requires mixing with exp(j*omega*n) where
%omega is the radians/sample

channelizerMixerNumEntries = numChannels;
channelizerMixerPhaseStep = 2*pi/numChannels;

channelizerTxMixer = exp(j*channelizerMixerPhaseStep.*(0:(channelizerMixerNumEntries-1)));
channelizerRxMixer = exp(-j*channelizerMixerPhaseStep.*(0:(channelizerMixerNumEntries-1)));

%I will construct a lookup table to perform this relativly efficiently as
%it is a relativly simple mixer.

%An optional half channel shift can also be used to avoid splitting a
%channel.
channelizerHalfChannelMixerNumEntries = numChannels*channelizerUpDownSampling;
channelizerHalfChannelMixerPhaseStep = 2*pi/(numChannels*channelizerUpDownSampling);

channelizerHalfChannelTxMixer = exp(j*channelizerHalfChannelMixerPhaseStep.*(0:(channelizerHalfChannelMixerNumEntries-1)));
channelizerHalfChannelRxMixer = exp(-j*channelizerHalfChannelMixerPhaseStep.*(0:(channelizerHalfChannelMixerNumEntries-1)));

