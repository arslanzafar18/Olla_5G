function rep = impairCQI(trueSinr, sigma, D, bias, q)
% Imperfect CQI: feedback delay (D slots), Gaussian error (sigma dB),
% constant bias (dB) and quantisation step q (dB, 0 = off).
trueSinr = trueSinr(:);
delayed  = [repmat(trueSinr(1), D, 1); trueSinr(1:end-D)];
rep = delayed + sigma*randn(size(delayed)) + bias;
if q > 0, rep = round(rep/q)*q; end
end
