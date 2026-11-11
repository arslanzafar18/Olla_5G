function G = genChannelTrace(L, nSlots, speed_kmh, seed)
% Fast TDL-C channel trace: per-slot, per-PRB channel power gain |H|^2
% (averaged over the slot's OFDM symbols and the 12 subcarriers of a PRB).
% No PHY encode/decode, so this is much faster than phySlot.
ch = makeChannel(L, speed_kmh, seed);
carrier = L.carrier;
G = zeros(nSlots, L.nPRB, 'single');
for n = 1:nSlots
    carrier.NSlot = mod(n-1, carrier.SlotsPerFrame);
    nSamp = size(nrOFDMModulate(carrier, nrResourceGrid(carrier, 1)), 1);
    [~, pathGains, sampleTimes] = step(ch.tdl, zeros(nSamp + ch.maxDelay, 1));
    offset = nrPerfectTimingEstimate(pathGains, ch.pathFilters);
    H = nrPerfectChannelEstimate(carrier, pathGains, ch.pathFilters, offset, sampleTimes);
    P = mean(abs(H(:,:,1,1)).^2, 2);                  % K x 1
    G(n,:) = mean(reshape(P, 12, L.nPRB), 1);
    if mod(n, 2000) == 0, fprintf('  trace %d km/h: %d/%d slots\n', speed_kmh, n, nSlots); end
end
end
