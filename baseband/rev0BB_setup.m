%dataLenSymbols = 4096; %orig design
header_len_bytes = 6; %This was a 32 bit CRC.  Will now be a 6 byte header of mod_type, type, src, dst, len (2 bytes).  The 4 byte CRC will be appended to the end of the frame
mod_scheme_len_bytes = 1;
crc_len_bytes = 4;

radix = 4; %QAM16
radixHeader = 2; %BPSK
radixMax = 16;
bitsPerSymbol = log2(radix);
bitsPerSymbolHeader = log2(radixHeader);
bitsPerSymbolMax = log2(radixMax);

% 0 = BPSK
% 1 = QPSK
% 2 = 16QAM
modKeys = [0, 1, 2];
modBPS  = [1, 2, 4];

mtu_eth = 1500+26+2;%+2 is so that the result fits evenly in 32 bit words

%Set the frame size based on the modulation scheme to maintain the same
%number of symbols per packet.
if(radix == 2) %BPSK
    frames_per_superframe = 1;
elseif(radix == 4) %QPSK
    frames_per_superframe = 1;
else %16QAM
    frames_per_superframe = 1;
end

payload_len_bytes = mtu_eth*frames_per_superframe;
frame_len_bytes = payload_len_bytes + crc_len_bytes;
dataLenSymbols = header_len_bytes*8/bitsPerSymbolHeader + frame_len_bytes*8/bitsPerSymbol; %/2 for QPSK
payload_len_symbols = payload_len_bytes*8/bitsPerSymbol; %/2 for QPSK

lineWidth = 60;

%% Sim Params
carrierFreq = 1e6+.1;
overSampleFreq = 10e6; %300 MHz would be optimal, now targeting 250 MHz
overSample = 4;
slowSample = 2;
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
%rcTxFilt = [-0.00848977273295494 -0.00410375263794876 0.00610325957004339 0.0148423780873929 0.0136814876976658 -1.07218784092424e-17 -0.0189705516775549 -0.0291138954791167 -0.0188689803130457 0.0106324500165036 0.0424488636647747 0.0519808667473508 0.0232973509312447 -0.0360457753550969 -0.0923829913484155 -0.100017778681868 -0.0262777670691454 0.126160213742839 0.313609824035538 0.467827800726157 0.527417705721797 0.467827800726157 0.313609824035538 0.126160213742839 -0.0262777670691454 -0.100017778681868 -0.0923829913484155 -0.0360457753550969 0.0232973509312447 0.0519808667473508 0.0424488636647747 0.0106324500165036 -0.0188689803130457 -0.0291138954791167 -0.0189705516775549 -1.07218784092424e-17 0.0136814876976658 0.0148423780873929 0.00610325957004339 -0.00410375263794876 -0.00848977273295494];
%rcRxFilt = [-0.00848977273295494 -0.00410375263794876 0.00610325957004339 0.0148423780873929 0.0136814876976658 -1.07218784092424e-17 -0.0189705516775549 -0.0291138954791167 -0.0188689803130457 0.0106324500165036 0.0424488636647747 0.0519808667473508 0.0232973509312447 -0.0360457753550969 -0.0923829913484155 -0.100017778681868 -0.0262777670691454 0.126160213742839 0.313609824035538 0.467827800726157 0.527417705721797 0.467827800726157 0.313609824035538 0.126160213742839 -0.0262777670691454 -0.100017778681868 -0.0923829913484155 -0.0360457753550969 0.0232973509312447 0.0519808667473508 0.0424488636647747 0.0106324500165036 -0.0188689803130457 -0.0291138954791167 -0.0189705516775549 -1.07218784092424e-17 0.0136814876976658 0.0148423780873929 0.00610325957004339 -0.00410375263794876 -0.00848977273295494];

%rcTxFilt = [-0.000499311203468195 -0.000281944617368396 0.000194370935922332 0.000546052756574624 0.000469184541331977 -7.60769124162794e-19 -0.000495616782840115 -0.000609854247068838 -0.000231414045970082 0.000346735448639125 0.000652945419919947 0.000423683079904141 -0.000165479006675002 -0.000627553168003672 -0.000561867458874057 3.27044667472531e-18 0.000596663854179901 0.000706656508508336 0.000193636115704223 -0.000547712084559926 -0.000890380118072655 -0.000495493771413319 0.000372749419200455 0.00102136183618411 0.000881466216240461 -7.31848763705207e-19 -0.000950684371053727 -0.0011899828940447 -0.000475820408805859 0.000655106610944222 0.00128610461499384 0.000867803562549484 -0.000293237948642646 -0.00123867286515946 -0.00113430001653721 5.26353374767222e-18 0.00123630420727822 0.00146672310196207 0.000358389840448053 -0.00126760466182703 -0.00202102153784745 -0.00109031729653654 0.000973901245940965 0.00255685513720415 0.00223056504217769 9.76187940522217e-19 -0.00252018920382837 -0.00327631653944774 -0.00145811106332452 0.00167650939144865 0.00363783876812542 0.0026881960931849 -0.000583718738958573 -0.00350383852135383 -0.00340304839489438 1.36469283394417e-17 0.00396624460875044 0.00470080199138154 0.000644026750750334 -0.0055684061930259 -0.00848829045895931 -0.0041030361422296 0.00610219396991088 0.0148397866786751 0.0136790989748962 -1.07200064201975e-17 -0.0189672395093357 -0.0291088123312472 -0.0188656858787043 0.0106305936412312 0.0424414522947966 0.0519717911349082 0.0232932833244266 -0.0360394819339252 -0.092366861716914 -0.100000316052761 -0.0262731790958257 0.126138186768738 0.313555069249802 0.467746120214174 0.527325621095433 0.467746120214174 0.313555069249802 0.126138186768738 -0.0262731790958257 -0.100000316052761 -0.092366861716914 -0.0360394819339252 0.0232932833244266 0.0519717911349082 0.0424414522947966 0.0106305936412312 -0.0188656858787043 -0.0291088123312472 -0.0189672395093357 -1.07200064201975e-17 0.0136790989748962 0.0148397866786751 0.00610219396991088 -0.0041030361422296 -0.00848829045895931 -0.0055684061930259 0.000644026750750334 0.00470080199138154 0.00396624460875044 1.36469283394417e-17 -0.00340304839489438 -0.00350383852135383 -0.000583718738958573 0.0026881960931849 0.00363783876812542 0.00167650939144865 -0.00145811106332452 -0.00327631653944774 -0.00252018920382837 9.76187940522217e-19 0.00223056504217769 0.00255685513720415 0.000973901245940965 -0.00109031729653654 -0.00202102153784745 -0.00126760466182703 0.000358389840448053 0.00146672310196207 0.00123630420727822 5.26353374767222e-18 -0.00113430001653721 -0.00123867286515946 -0.000293237948642646 0.000867803562549484 0.00128610461499384 0.000655106610944222 -0.000475820408805859 -0.0011899828940447 -0.000950684371053727 -7.31848763705207e-19 0.000881466216240461 0.00102136183618411 0.000372749419200455 -0.000495493771413319 -0.000890380118072655 -0.000547712084559926 0.000193636115704223 0.000706656508508336 0.000596663854179901 3.27044667472531e-18 -0.000561867458874057 -0.000627553168003672 -0.000165479006675002 0.000423683079904141 0.000652945419919947 0.000346735448639125 -0.000231414045970082 -0.000609854247068838 -0.000495616782840115 -7.60769124162794e-19 0.000469184541331977 0.000546052756574624 0.000194370935922332 -0.000281944617368396 -0.000499311203468195];
%rcRxFilt = [-0.000499311203468195 -0.000281944617368396 0.000194370935922332 0.000546052756574624 0.000469184541331977 -7.60769124162794e-19 -0.000495616782840115 -0.000609854247068838 -0.000231414045970082 0.000346735448639125 0.000652945419919947 0.000423683079904141 -0.000165479006675002 -0.000627553168003672 -0.000561867458874057 3.27044667472531e-18 0.000596663854179901 0.000706656508508336 0.000193636115704223 -0.000547712084559926 -0.000890380118072655 -0.000495493771413319 0.000372749419200455 0.00102136183618411 0.000881466216240461 -7.31848763705207e-19 -0.000950684371053727 -0.0011899828940447 -0.000475820408805859 0.000655106610944222 0.00128610461499384 0.000867803562549484 -0.000293237948642646 -0.00123867286515946 -0.00113430001653721 5.26353374767222e-18 0.00123630420727822 0.00146672310196207 0.000358389840448053 -0.00126760466182703 -0.00202102153784745 -0.00109031729653654 0.000973901245940965 0.00255685513720415 0.00223056504217769 9.76187940522217e-19 -0.00252018920382837 -0.00327631653944774 -0.00145811106332452 0.00167650939144865 0.00363783876812542 0.0026881960931849 -0.000583718738958573 -0.00350383852135383 -0.00340304839489438 1.36469283394417e-17 0.00396624460875044 0.00470080199138154 0.000644026750750334 -0.0055684061930259 -0.00848829045895931 -0.0041030361422296 0.00610219396991088 0.0148397866786751 0.0136790989748962 -1.07200064201975e-17 -0.0189672395093357 -0.0291088123312472 -0.0188656858787043 0.0106305936412312 0.0424414522947966 0.0519717911349082 0.0232932833244266 -0.0360394819339252 -0.092366861716914 -0.100000316052761 -0.0262731790958257 0.126138186768738 0.313555069249802 0.467746120214174 0.527325621095433 0.467746120214174 0.313555069249802 0.126138186768738 -0.0262731790958257 -0.100000316052761 -0.092366861716914 -0.0360394819339252 0.0232932833244266 0.0519717911349082 0.0424414522947966 0.0106305936412312 -0.0188656858787043 -0.0291088123312472 -0.0189672395093357 -1.07200064201975e-17 0.0136790989748962 0.0148397866786751 0.00610219396991088 -0.0041030361422296 -0.00848829045895931 -0.0055684061930259 0.000644026750750334 0.00470080199138154 0.00396624460875044 1.36469283394417e-17 -0.00340304839489438 -0.00350383852135383 -0.000583718738958573 0.0026881960931849 0.00363783876812542 0.00167650939144865 -0.00145811106332452 -0.00327631653944774 -0.00252018920382837 9.76187940522217e-19 0.00223056504217769 0.00255685513720415 0.000973901245940965 -0.00109031729653654 -0.00202102153784745 -0.00126760466182703 0.000358389840448053 0.00146672310196207 0.00123630420727822 5.26353374767222e-18 -0.00113430001653721 -0.00123867286515946 -0.000293237948642646 0.000867803562549484 0.00128610461499384 0.000655106610944222 -0.000475820408805859 -0.0011899828940447 -0.000950684371053727 -7.31848763705207e-19 0.000881466216240461 0.00102136183618411 0.000372749419200455 -0.000495493771413319 -0.000890380118072655 -0.000547712084559926 0.000193636115704223 0.000706656508508336 0.000596663854179901 3.27044667472531e-18 -0.000561867458874057 -0.000627553168003672 -0.000165479006675002 0.000423683079904141 0.000652945419919947 0.000346735448639125 -0.000231414045970082 -0.000609854247068838 -0.000495616782840115 -7.60769124162794e-19 0.000469184541331977 0.000546052756574624 0.000194370935922332 -0.000281944617368396 -0.000499311203468195];

rcTxFilt = [-0.00202106380626832 -0.00109034009985135 0.000973921614485769 0.00255690861225477 0.0022306116930719 9.7620835689183e-19 -0.00252024191203356 -0.00327638506159052 -0.00145814155881946 0.00167654445461013 0.00363791485128298 0.00268825231515072 -0.000583730947076528 -0.00350391180197875 -0.00340311956755587 1.36472137565437e-17 0.00396632756031391 0.00470090030576031 0.000644040220173217 -0.00556852265281225 -0.00848846798632694 -0.00410312195470376 0.00610232159353986 0.0148400970436747 0.0136793850648273 -1.07202306225301e-17 -0.0189676361974695 -0.0291094211241311 -0.0188660804429064 0.0106308159735506 0.0424423399316347 0.0519728780929142 0.0232937704891027 -0.0360402356774957 -0.0923687935129448 -0.100002407497788 -0.0262737285831867 0.126140824871235 0.31356162706098 0.467755902836228 0.527336649786057 0.467755902836228 0.31356162706098 0.126140824871235 -0.0262737285831867 -0.100002407497788 -0.0923687935129448 -0.0360402356774957 0.0232937704891027 0.0519728780929142 0.0424423399316347 0.0106308159735506 -0.0188660804429064 -0.0291094211241311 -0.0189676361974695 -1.07202306225301e-17 0.0136793850648273 0.0148400970436747 0.00610232159353986 -0.00410312195470376 -0.00848846798632694 -0.00556852265281225 0.000644040220173217 0.00470090030576031 0.00396632756031391 1.36472137565437e-17 -0.00340311956755587 -0.00350391180197875 -0.000583730947076528 0.00268825231515072 0.00363791485128298 0.00167654445461013 -0.00145814155881946 -0.00327638506159052 -0.00252024191203356 9.7620835689183e-19 0.0022306116930719 0.00255690861225477 0.000973921614485769 -0.00109034009985135 -0.00202106380626832];
rcRxFilt = [-0.00202106380626832 -0.00109034009985135 0.000973921614485769 0.00255690861225477 0.0022306116930719 9.7620835689183e-19 -0.00252024191203356 -0.00327638506159052 -0.00145814155881946 0.00167654445461013 0.00363791485128298 0.00268825231515072 -0.000583730947076528 -0.00350391180197875 -0.00340311956755587 1.36472137565437e-17 0.00396632756031391 0.00470090030576031 0.000644040220173217 -0.00556852265281225 -0.00848846798632694 -0.00410312195470376 0.00610232159353986 0.0148400970436747 0.0136793850648273 -1.07202306225301e-17 -0.0189676361974695 -0.0291094211241311 -0.0188660804429064 0.0106308159735506 0.0424423399316347 0.0519728780929142 0.0232937704891027 -0.0360402356774957 -0.0923687935129448 -0.100002407497788 -0.0262737285831867 0.126140824871235 0.31356162706098 0.467755902836228 0.527336649786057 0.467755902836228 0.31356162706098 0.126140824871235 -0.0262737285831867 -0.100002407497788 -0.0923687935129448 -0.0360402356774957 0.0232937704891027 0.0519728780929142 0.0424423399316347 0.0106308159735506 -0.0188660804429064 -0.0291094211241311 -0.0189676361974695 -1.07202306225301e-17 0.0136793850648273 0.0148400970436747 0.00610232159353986 -0.00410312195470376 -0.00848846798632694 -0.00556852265281225 0.000644040220173217 0.00470090030576031 0.00396632756031391 1.36472137565437e-17 -0.00340311956755587 -0.00350391180197875 -0.000583730947076528 0.00268825231515072 0.00363791485128298 0.00167654445461013 -0.00145814155881946 -0.00327638506159052 -0.00252024191203356 9.7620835689183e-19 0.0022306116930719 0.00255690861225477 0.000973921614485769 -0.00109034009985135 -0.00202106380626832];


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

timing_smooth_samples = 16;
%[smooth_num, smooth_denom] = butter(smooth_samples, 0.35, 'low');
%smooth_num = firpm(smooth_samples-1,[0 .01 .04 .5]*2,[1 1 0 0]);
timing_smooth_num = (1/timing_smooth_samples).*ones(1, timing_smooth_samples);
timing_smooth_denom = zeros(1, timing_smooth_samples);

timing_i = 0.25;
timing_p = 45*0.0005;
timing_d = 0;

timing_pre_scale = 0.0001;

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
lnResolution = 2^-5;

agcSaturation = 12;

agc_sat_up  =  agcSaturation;
agc_sat_low = -agcSaturation;

agcExpDomain = agcSaturation;
agcExpResolution = 2^-5;

agcDesired = 0;
%agcStep = 2^-10+2^-11;
%agcStep = 2^-11;
agcStep = 2^-9;
%agcStep = 2^-13;

agcSettleThresh = 0.65;

coarseCFO_averaging_samples = 512;
atanDomainCoarseCFO = 128;
atanResolutionCoarseCFO = 2^-14;

frac_lut_domain_coarse_cfo = 32;
frac_lut_res_coarse_cfo = 2^-14;
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

coarseCFOAdaptDelay = 8;

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
nSpectrum_STFRepCount_short = 28;
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

xSpectrumAck_STF_short = cat(2, Gb_32(mod(nSpectrumAck_STFRep_short, 32)+1), -Gb_32(mod(nSpectrumAck_STFNeg_short, 32)+1), -Ga_32(mod(nSpectrumAck_STFFin_short, 32)+1)); %+1 is for matlab
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
stfLenTol = 50;
cefLen = length(x_CEF);
preLen = length(x_PRE);

cefEarlyWarning = 256;

outBuffer = zeros(1024,1);

agcPwrAvgNum = 128;
agc_delay_lag = 32;

lmsEqDepth = 38;
lmsStep_init =  0.006; %LMS
lmsStep_final = 0.006;
lmsStep_meta = (lmsStep_final - lmsStep_init)/cefLen;

preambleSequentialDetect = 2;
default_channel = 3;
maxMsgSize = length(xSpectrum_PRE)+dataLenSymbols+300;

%Correlator Running Avg
corrAvgLen = 32;

% CRC Settings
% Same poly as Ethernet (IEEE 802.3)
% CRC-32 = 'z^32 + z^26 + z^23 + z^22 + z^16 + z^12 + z^11 + z^10 + z^8 + z^7 + z^5 + z^4 + z^2 + z + 1';
%           32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
crc_poly = [ 1  0  0  0  0  0  1  0  0  1  1  0  0  0  0  0  1  0  0  0  1  1  1  0  1  1  0  1  1  0  0  1  1 ];
crc_init =    [ 1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1 ];
crc_xor  =    [ 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 ];
