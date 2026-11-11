%% main_1b_traces.m  -  STEP 1b (run once, ~5-15 min)
% TDL-C channel power-gain traces for the three UE speeds.
clear; clc;
L = getLinkConfig();
for v = [3 30 120]
    fprintf('Generating TDL-C trace for %d km/h ...\n', v);
    G = genChannelTrace(L, 20000, v, 7);
    save(sprintf('trace_%dkmh.mat', v), 'G');
end
disp('Saved trace_3kmh.mat, trace_30kmh.mat, trace_120kmh.mat');
