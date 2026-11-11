function m = computeMetrics(ack, mcs, bits, Ts)
% Steady-state metrics; the first 20% of slots (OLLA convergence) is discarded.
N = numel(ack);  s = (round(0.2*N)+1):N;
m.bler     = 1 - mean(ack(s));
m.thr_Mbps = sum(bits(s))/(numel(s)*Ts)/1e6;
m.avgMCS   = mean(mcs(s));
end
