function R = evalCase(cfg, cal, G, seeds)
% Runs OLLA off and on for several seeds. R.off / R.on are nSeeds x 3:
% [steady-state BLER, throughput (Mbps), average MCS].
tS = effSinrFromG(G(1:cfg.nSlots,:), cfg.snr_dB);
R.off = zeros(numel(seeds),3);  R.on = R.off;
for i = 1:numel(seeds)
    c = cfg;  c.seed = seeds(i);
    c.olla = false;  r = runLinkSim(c, cal, tS);  R.off(i,:) = [r.bler r.thr_Mbps r.avgMCS];
    c.olla = true;   r = runLinkSim(c, cal, tS);  R.on(i,:)  = [r.bler r.thr_Mbps r.avgMCS];
end
end
