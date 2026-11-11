function out = runLinkSim(cfg, cal, trueSinr)
% Fast closed-loop link adaptation using the PHY-calibrated BLER curves.
% trueSinr: effective SINR (dB) per slot. Same cfg.seed => identical CQI errors
% and random draws, so OLLA on/off runs are directly comparable.
rng(cfg.seed);
N = cfg.nSlots;  trueSinr = trueSinr(1:N);
repSinr = impairCQI(trueSinr, cfg.cqiSigma, cfg.cqiDelay, cfg.cqiBias, cfg.cqiQuant);
delta = 0;
mcs = zeros(N,1);  ack = false(N,1);  dlt = zeros(N,1);
bits = zeros(N,1);  effSinr = zeros(N,1);
for n = 1:N
    if cfg.olla, d = delta; else, d = 0; end
    effSinr(n) = repSinr(n) + d;
    m  = selectMCS(effSinr(n), cal.thr);
    ok = rand > blerModel(trueSinr(n), m, cal);       % ACK if no block error
    mcs(n) = m;  ack(n) = ok;  dlt(n) = d;  bits(n) = ok*cal.tbs(m);
    k = n - cfg.ackDelay;                             % delayed HARQ feedback
    if cfg.olla && k >= 1
        delta = ollaUpdate(delta, ack(k), cfg.stepUp, cfg.target, cfg.dMin, cfg.dMax);
    end
end
out = computeMetrics(ack, mcs, bits, cal.slotDur);
out.trueSinr = trueSinr;  out.repSinr = repSinr;  out.effSinr = effSinr;
out.mcs = mcs;  out.ack = ack;  out.delta = dlt;
end
