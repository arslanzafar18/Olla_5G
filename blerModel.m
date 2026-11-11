function b = blerModel(trueSinr, m, cal)
% PHY-calibrated BLER of MCS m at the slot's true effective SINR.
b = 1/(1 + exp(cal.k(m)*(trueSinr - cal.mid(m))));
end
