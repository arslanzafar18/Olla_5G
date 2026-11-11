function s = effSinrFromG(G, snr_dB)
% Capacity-effective SINR (dB) per slot from per-PRB channel power gains.
snr = 10^(snr_dB/10);
s = 10*log10(max(2.^mean(log2(1 + snr*double(G)), 2) - 1, 1e-6));
end
