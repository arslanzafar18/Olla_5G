%% main_1a_calibrate.m  -  STEP 1a (run once, ~10-20 min)
% Real 5G Toolbox PHY over TDL-C -> measured BLER-vs-SINR curves per CQI/MCS.
clear; clc; close all;
L   = getLinkConfig();
cal = buildBlerCurves(L, 200, 120);      % 200 slots per SNR point, UE at 120 km/h
save('calibration.mat', 'cal');
plotCalibration(cal);
if ~exist('results','dir'), mkdir results; end
saveas(gcf, 'results/fig0_calibration.png');
disp('Saved calibration.mat');
