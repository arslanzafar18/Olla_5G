function delta = ollaUpdate(delta, ack, stepUp, target, dMin, dMax)
% Convention: the offset is ADDED to the reported SINR.
% ACK raises it by stepUp, NACK lowers it by stepUp*(1-target)/target.
% Equilibrium: BLER*stepDown = (1-BLER)*stepUp  ->  BLER = target.
stepDown = stepUp*(1 - target)/target;
if ack, delta = delta + stepUp; else, delta = delta - stepDown; end
delta = min(max(delta, dMin), dMax);          % anti-windup clamp
end
