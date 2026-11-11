function out = runPhySim(cfg, cal, L)
% FULL-PHY closed loop: every slot is really encoded, sent through TDL-C,
% equalised and LDPC-decoded (phySlot). Slow - use a few thousand slots.
% CQI is built from the true SINR of slot n-D, so cfg.cqiDelay must be >= 1.
assert(cfg.cqiDelay >= 1, 'runPhySim needs cqiDelay >= 1');
rng(cfg.seed);
N = cfg.nSlots;  D = cfg.cqiDelay;
C  = makeCodecs(L);
ch = makeChannel(L, cfg.speed_kmh, cfg.seed);
noise = cfg.cqiSigma*randn(N,1);
trueSinr = nan(N,1);  repSinr = zeros(N,1);  effSinr = zeros(N,1);
mcs = zeros(N,1);  ack = false(N,1);  dlt = zeros(N,1);  bits = zeros(N,1);
delta = 0;
for n = 1:N
    if n > D, base = trueSinr(n-D); else, base = cfg.snr_dB; end
    rep = base + noise(n) + cfg.cqiBias;
    if cfg.cqiQuant > 0, rep = round(rep/cfg.cqiQuant)*cfg.cqiQuant; end
    repSinr(n) = rep;
    if cfg.olla, d = delta; else, d = 0; end
    effSinr(n) = rep + d;
    m = selectMCS(effSinr(n), cal.thr);
    [ok, trueSinr(n)] = phySlot(L, C, ch, m, cfg.snr_dB, n);
    mcs(n) = m;  ack(n) = ok;  dlt(n) = d;  bits(n) = ok*L.tbs(m);
    k = n - cfg.ackDelay;
    if cfg.olla && k >= 1
        delta = ollaUpdate(delta, ack(k), cfg.stepUp, cfg.target, cfg.dMin, cfg.dMax);
    end
    if mod(n,500) == 0, fprintf('  PHY slot %d/%d (OLLA=%d)\n', n, N, cfg.olla); end
end
out = computeMetrics(ack, mcs, bits, L.slotDur);
out.trueSinr = trueSinr;  out.repSinr = repSinr;  out.effSinr = effSinr;
out.mcs = mcs;  out.ack = ack;  out.delta = dlt;
end
