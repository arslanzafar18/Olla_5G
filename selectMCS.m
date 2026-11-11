function m = selectMCS(sinrEff, thr)
% Highest CQI/MCS whose 10%-BLER threshold is below the effective SINR.
% Below the lowest threshold the lowest MCS (CQI 1) is used.
m = find(sinrEff >= thr, 1, 'last');
if isempty(m), m = 1; end
end
