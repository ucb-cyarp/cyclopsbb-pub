
close all

prambleCorrCa = conv(x_PRE, flip(Ga_32));
prambleCorrCb = conv(x_PRE, flip(Gb_32));

plot(prambleCorrCa);
hold all
plot(prambleCorrCb);

legend('Correlation A', 'Correlation B', 'location', 'southwest');
title('Golay Correlation of Preamble used in Cyclops')
xlabel('Symbol')
ylabel('Correlation Value')
xlim([1, length(prambleCorrCa)])