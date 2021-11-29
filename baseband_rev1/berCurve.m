overSample =3;
awgnSNR = -4:1:35;

[EbN0BPSK, ~, idealBerBPSK, idealEVMBPSK] = getIdealBER(awgnSNR, overSample, 2);
[EbN0QPSK, ~, idealBerQPSK, idealEVMQPSK] = getIdealBER(awgnSNR, overSample, 4);
[EbN016, ~, idealBer16QAM, idealEVM16QAM] = getIdealBER(awgnSNR, overSample, 16);
[EbN064, ~, idealBer64QAM, idealEVM64QAM] = getIdealBER(awgnSNR, overSample, 64);
[EbN0256, ~, idealBer256QAM, idealEVM256QAM] = getIdealBER(awgnSNR, overSample, 256);


figure;
subplot(3, 1, 1);
semilogy(EbN0BPSK, idealBerBPSK, 'k-');
hold on;
semilogy(EbN0QPSK, idealBerQPSK, 'r--');
semilogy(EbN016, idealBer16QAM, 'b-');
semilogy(EbN064, idealBer64QAM, 'g-');
semilogy(EbN0256, idealBer256QAM, 'm-');
legend('BPSK', 'QPSK', '16QAM', '64QAM', '256QAM');
xlabel('EbN0');
ylabel('BER');
title('BER vs. EbN0');
grid on;

subplot(3, 1, 2);
semilogy(awgnSNR, idealBerBPSK, 'k-');
hold on;
semilogy(awgnSNR, idealBerQPSK, 'r--');
semilogy(awgnSNR, idealBer16QAM, 'b-');
semilogy(awgnSNR, idealBer64QAM, 'g-');
semilogy(awgnSNR, idealBer256QAM, 'm-');
legend('BPSK', 'QPSK', '16QAM', '64QAM', '256QAM');
xlabel('SNR');
ylabel('BER');
title('BER vs. SNR');
grid on;

subplot(3, 1, 3);
semilogy(idealEVMBPSK, idealBerBPSK, 'k-');
hold on;
semilogy(idealEVMQPSK, idealBerQPSK, 'r--');
semilogy(idealEVM16QAM, idealBer16QAM, 'b-');
semilogy(idealEVM64QAM, idealBer64QAM, 'g-');
semilogy(idealEVM256QAM, idealBer256QAM, 'm-');
legend('BPSK', 'QPSK', '16QAM', '64QAM', '256QAM');
xlabel('EVM');
ylabel('BER');
title('BER vs. EVM');
grid on;