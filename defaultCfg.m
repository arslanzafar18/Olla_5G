function cfg = defaultCfg()
% Default simulation / OLLA configuration (all experiments start from this).
cfg = struct( ...
    'nSlots',   20000, ...   % slots per run
    'snr_dB',   15, ...      % average SNR per RE
    'speed_kmh',30, ...      % UE speed (selects the channel trace)
    'cqiSigma', 2, ...       % CQI estimation error, std in dB
    'cqiDelay', 4, ...       % CQI feedback delay in slots (0.5 ms each at 30 kHz)
    'cqiBias',  0, ...       % constant CQI bias in dB (+ = optimistic)
    'cqiQuant', 1, ...       % CQI quantisation step in dB (0 = off)
    'ackDelay', 4, ...       % HARQ ACK/NACK feedback delay in slots
    'olla',     false, ...   % OLLA on/off
    'stepUp',   0.05, ...    % OLLA ACK step in dB (NACK step = stepUp*(1-t)/t)
    'target',   0.1, ...     % BLER target
    'dMin',    -10, ...      % OLLA offset clamp (dB)
    'dMax',     10, ...
    'seed',     1);
end
