function [ack, effSinr_dB] = phySlot(L, C, ch, m, snr_dB, n)
% One full-PHY PDSCH slot over TDL-C: DL-SCH encode -> PDSCH -> OFDM -> channel
% -> AWGN -> OFDM demod -> perfect channel estimate -> MMSE EQ -> LDPC decode.
% Returns the CRC result (ack) and the genie capacity-effective SINR of the slot.
carrier = L.carrier;  carrier.NSlot = mod(n-1, carrier.SlotsPerFrame);
pdsch = L.pdsch;      pdsch.Modulation = L.mod{m};
[pdschInd, pdschInfo] = nrPDSCHIndices(carrier, pdsch);

tb = randi([0 1], L.tbs(m), 1, 'int8');
setTransportBlock(C.enc{m}, tb, 0);
cw  = step(C.enc{m}, pdsch.Modulation, pdsch.NumLayers, pdschInfo.G, 0, 0);
sym = nrPDSCH(carrier, pdsch, cw);

txGrid = nrResourceGrid(carrier, 1);
txGrid(pdschInd) = sym;
txGrid(nrPDSCHDMRSIndices(carrier, pdsch)) = nrPDSCHDMRS(carrier, pdsch);
[txWave, ofdmInfo] = nrOFDMModulate(carrier, txGrid);

[rx, pathGains, sampleTimes] = step(ch.tdl, [txWave; zeros(ch.maxDelay, 1)]);
snr = 10^(snr_dB/10);
N0  = 1/sqrt(2.0*double(ofdmInfo.Nfft)*snr);
rx  = rx + N0*complex(randn(size(rx)), randn(size(rx)));

offset = nrPerfectTimingEstimate(pathGains, ch.pathFilters);
rx     = rx(1+offset:end, :);
rxGrid = nrOFDMDemodulate(carrier, rx);
H      = nrPerfectChannelEstimate(carrier, pathGains, ch.pathFilters, offset, sampleTimes);

[pRx, pH] = nrExtractResources(pdschInd, rxGrid, H);
noiseEst  = 1/snr;
[pEq, csi] = nrEqualizeMMSE(pRx, pH, noiseEst);
[llr, rxSym] = nrPDSCHDecode(carrier, pdsch, pEq, noiseEst);
csi = nrLayerDemap(csi);
Qm  = length(llr{1})/length(rxSym{1});
csi = repmat(csi{1}.', Qm, 1);
llr{1} = llr{1} .* csi(:);

resetSoftBuffer(C.dec{m}, 0);                 % new data every slot (no HARQ combining)
[~, blkerr] = step(C.dec{m}, llr, pdsch.Modulation, pdsch.NumLayers, 0, 0);
ack = ~blkerr;

g = snr*abs(pH(:)).^2;                        % per-RE SNR after equalisation
effSinr_dB = 10*log10(max(2^mean(log2(1+g)) - 1, 1e-6));   % capacity mapping
end
