fig1 = figure;
semilogy(dBSnrRange + 10*log10(overSample), idealBer, '-');
hold all;
semilogy(dBSnrRange + 10*log10(overSample), sim_ber, '*-');
semilogy(dBSnrRange + 10*log10(overSample), sim_ber_cfo, 'o-');
hold off;
xlabel('Eb/N0 (dB)')
ylabel('BER')
legend('Theoretical', 'Simulation - No Carrier or Timing Frequency Offset', 'Simulation - CFO: 100 KHz, Timing Frequency Offset: -25 KHz');
title('Baseband Simulation vs. Theoretical (Uncoded Coherent BPSK over AWGN)')
grid on;