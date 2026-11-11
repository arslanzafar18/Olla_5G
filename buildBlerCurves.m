function cal = buildBlerCurves(L, nPerPoint, speed_kmh)
% OFFLINE LINK-LEVEL CALIBRATION with the real 5G PHY over TDL-C.
% For every CQI/MCS entry: run PDSCH slots at several average SNRs, record the
% slot's effective SINR and CRC result, then fit BLER(sinr) = 1/(1+exp(k*(sinr-mid))).
% The 10%-BLER threshold is thr = mid + ln(9)/k.
C  = makeCodecs(L);
ch = makeChannel(L, speed_kmh, 99);
offs = -6:2:12;                                   % average SNR relative to approx. threshold
cal.thr = zeros(1,15);  cal.mid = zeros(1,15);  cal.k = zeros(1,15);
cal.tbs = L.tbs;  cal.thrApprox = L.thrApprox;  cal.slotDur = L.slotDur;
cal.S = cell(1,15);  cal.E = cell(1,15);
n = 0;  t0 = tic;
for m = 1:15
    nTot = numel(offs)*nPerPoint;
    S = zeros(nTot,1);  E = zeros(nTot,1);  j = 0;
    for o = offs
        snr = L.thrApprox(m) + o;
        for i = 1:nPerPoint
            n = n + 1;  j = j + 1;
            [ok, S(j)] = phySlot(L, C, ch, m, snr, n);
            E(j) = ~ok;
        end
    end
    [mid, k] = fitLogistic(S, E, L.thrApprox(m));
    cal.mid(m) = mid;  cal.k(m) = k;  cal.thr(m) = mid + log(9)/k;
    cal.S{m} = S;  cal.E{m} = E;
    fprintf('CQI %2d (%s, R=%.3f): thr(10%% BLER) = %6.2f dB, slope k = %.2f  [%.0f s]\n', ...
        m, L.mod{m}, L.tcr(m), cal.thr(m), cal.k(m), toc(t0));
end
if any(diff(cal.thr) <= 0)
    warning('Thresholds are not strictly increasing - increase nPerPoint.');
end
end

function [mid, k] = fitLogistic(S, E, thr0)
pe  = @(p) 1./(1 + exp(exp(p(2)).*(S - p(1))));
nll = @(p) -sum(E.*log(max(pe(p),1e-9)) + (1-E).*log(max(1-pe(p),1e-9)));
p = fminsearch(nll, [thr0 - log(9)/2.5, log(2.5)], ...
    optimset('Display','off','MaxIter',3000,'MaxFunEvals',6000));
mid = p(1);  k = exp(p(2));
end
