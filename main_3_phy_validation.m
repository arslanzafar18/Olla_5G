%% main_3_phy_validation.m  -  STEP 3 (slow, ~5-15 min): full-PHY closed loop
% Every slot is really encoded / transmitted over TDL-C / decoded.
% The calibrated fast simulator is then run on the SAME true-SINR trace and compared.
clear; clc; close all;
if ~exist('results','dir'), mkdir results; end
load('calibration.mat','cal');  L = getLinkConfig();
cfg = defaultCfg();  cfg.nSlots = 4000;  cfg.snr_dB = 15;  cfg.speed_kmh = 30;  cfg.cqiBias = 2;

cfg.olla = false;  pOff = runPhySim(cfg, cal, L);
cfg.olla = true;   pOn  = runPhySim(cfg, cal, L);
cfg.olla = false;  aOff = runLinkSim(cfg, cal, pOff.trueSinr);
cfg.olla = true;   aOn  = runLinkSim(cfg, cal, pOn.trueSinr);

plotSignalFlow(pOff, pOn, 400);  saveas(gcf, 'results/fig7_phy_signal_flow.png');
fprintf('\nValidation (SNR %d dB, %d km/h, bias +2 dB, %d slots)\n', cfg.snr_dB, cfg.speed_kmh, cfg.nSlots);
fprintf('                    BLER    Mbps    avg MCS\n');
fprintf('Full PHY, OLLA off  %.3f   %5.1f   %5.2f\n', pOff.bler, pOff.thr_Mbps, pOff.avgMCS);
fprintf('Abstraction, off    %.3f   %5.1f   %5.2f\n', aOff.bler, aOff.thr_Mbps, aOff.avgMCS);
fprintf('Full PHY, OLLA on   %.3f   %5.1f   %5.2f\n', pOn.bler,  pOn.thr_Mbps,  pOn.avgMCS);
fprintf('Abstraction, on     %.3f   %5.1f   %5.2f\n', aOn.bler,  aOn.thr_Mbps,  aOn.avgMCS);
V = [pOff.bler pOff.thr_Mbps pOff.avgMCS; aOff.bler aOff.thr_Mbps aOff.avgMCS; ...
     pOn.bler pOn.thr_Mbps pOn.avgMCS;   aOn.bler aOn.thr_Mbps aOn.avgMCS];
writetable(array2table(V,'VariableNames',{'BLER','Throughput_Mbps','AvgMCS'}, ...
    'RowNames',{'PHY_off','Abstraction_off','PHY_on','Abstraction_on'}), ...
    'results/table_validation.csv','WriteRowNames',true);
