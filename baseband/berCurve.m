overSample =3;
awgnSNR = -4:1:35;
EsN0 = awgnSNR + 10*log10(overSample);
infoBitsPerSymbol64 = log2(64); %Change when coding introduced
infoBitsPerSymbol16 = log2(16); %Change when coding introduced
infoBitsPerSymbolBPSK = log2(2); %Change when coding introduced
infoBitsPerSymbolQPSK = log2(4); %Change when coding introduced
EbN064 = EsN0 - 10*log10(infoBitsPerSymbol64);
EbN016 = EsN0 - 10*log10(infoBitsPerSymbol16);
EbN0BPSK = EsN0 - 10*log10(infoBitsPerSymbolBPSK);
EbN0QPSK = EsN0 - 10*log10(infoBitsPerSymbolQPSK);
idealBerBPSK = berawgn(EbN0BPSK, 'psk', 2, 'nondiff');
idealBerQPSK = berawgn(EbN0QPSK, 'psk', 4, 'nondiff');
idealBer16QAM = berawgn(EbN016, 'qam', 16, 'nondiff');
idealBer64QAM = berawgn(EbN016, 'qam', 64, 'nondiff');
idealBer256QAM = berawgn(EbN016, 'qam', 256, 'nondiff');

figure;
subplot(2, 1, 1);
semilogy(EbN0BPSK, idealBerBPSK, 'k-');
hold on;
semilogy(EbN0QPSK, idealBerQPSK, 'r--');
semilogy(EbN016, idealBer16QAM, 'b-');
semilogy(EbN064, idealBer64QAM, 'g-');
semilogy(EbN064, idealBer256QAM, 'm-');
legend('BPSK', 'QPSK', '16QAM', '64QAM', '256QAM');
xlabel('EbN0');
ylabel('BER');
title('BER vs. EbN0');
grid on;

subplot(2, 1, 2);
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
