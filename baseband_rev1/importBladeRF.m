%Import bladeRF
[bladeRF_re, bladeRF_im] = importbladeRF_rx('bladeRF_rx.csv');

bladeRF.time = [];
bladeRF.signals.values = complex(bladeRF_re, bladeRF_im);
bladeRF.signals.dimensions = 1;