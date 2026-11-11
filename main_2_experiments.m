%% main_2_experiments.m  -  STEP 2 (fast, a few minutes): all results for the report
% Needs calibration.mat and trace_*.mat from steps 1a / 1b.
clear; clc; close all;
if ~exist('results','dir'), mkdir results; end
load('calibration.mat','cal');
speeds = [3 30 120];
for v = speeds
    T = load(sprintf('trace_%dkmh.mat', v), 'G');  Gs.(sprintf('v%d', v)) = T.G;
end
cfg = defaultCfg();  G30 = Gs.v30;  seeds = 1:5;

%% A) Signal flow, OLLA off vs on (optimistic CQI bias makes the effect visible)
cA = cfg;  cA.cqiBias = 2;
tS = effSinrFromG(G30(1:cA.nSlots,:), cA.snr_dB);
cA.olla = false;  off = runLinkSim(cA, cal, tS);
cA.olla = true;   on  = runLinkSim(cA, cal, tS);
plotSignalFlow(off, on, 400);  saveas(gcf, 'results/fig1_signal_flow.png');
fprintf('A) bias +2 dB | OLLA off: BLER %.3f, %.1f Mbps | OLLA on: BLER %.3f, %.1f Mbps\n', ...
    off.bler, off.thr_Mbps, on.bler, on.thr_Mbps);

%% B) SNR sweep (mean +/- std over seeds)
snrs = 0:2:26;  nS = numel(snrs);
B = zeros(nS,2,3);  Bs = B;
for i = 1:nS
    c = cfg;  c.snr_dB = snrs(i);  R = evalCase(c, cal, G30, seeds);
    B(i,1,:) = mean(R.off,1);  B(i,2,:) = mean(R.on,1);
    Bs(i,1,:) = std(R.off,0,1);  Bs(i,2,:) = std(R.on,0,1);
end
lab = {'BLER','Throughput (Mbps)','Average MCS index'};
figure('Name','SNR sweep','Position',[100 100 1300 420]);  tiledlayout(1,3);
for k = 1:3
    nexttile; hold on;
    errorbar(snrs, B(:,1,k), Bs(:,1,k), 'b-o', 'DisplayName','OLLA off');
    errorbar(snrs, B(:,2,k), Bs(:,2,k), 'r-s', 'DisplayName','OLLA on');
    if k == 1, yline(0.1, 'k--', 'HandleVisibility','off'); end
    grid on; xlabel('SNR (dB)'); ylabel(lab{k}); legend('Location','best');
end
saveas(gcf, 'results/fig2_snr_sweep.png');

%% C) OLLA step-size study (CQI bias +2 dB to force a convergence transient)
steps = [0.01 0.05 0.1 0.5];
cS = cfg;  cS.cqiBias = 2;  cS.olla = true;
tS = effSinrFromG(G30(1:cS.nSlots,:), cS.snr_dB);
figure('Name','Step size','Position',[100 100 1100 700]);  tiledlayout(2,1);
ax1 = nexttile; hold(ax1,'on');  ax2 = nexttile; hold(ax2,'on');
T = zeros(numel(steps),5);
for i = 1:numel(steps)
    bl = zeros(1,3);  th = zeros(1,3);
    for sd = 1:3
        c = cS;  c.stepUp = steps(i);  c.seed = sd;  r = runLinkSim(c, cal, tS);
        bl(sd) = r.bler;  th(sd) = r.thr_Mbps;
        if sd == 1
            n0 = round(0.2*numel(r.delta));
            conv = convergenceSlot(r.ack, c.target, 200);
            dsd  = std(r.delta(n0+1:end));
            nm = sprintf('stepUp = %.2f dB', steps(i));
            plot(ax1, movmean(r.delta,500), 'DisplayName', nm);
            plot(ax2, movmean(double(~r.ack),500), 'DisplayName', nm);
        end
    end
    T(i,:) = [steps(i) mean(bl) mean(th) conv dsd];
end
ylabel(ax1,'\Delta, 500-slot mean (dB)'); grid(ax1,'on'); legend(ax1,'Location','best');
title(ax1,'OLLA offset for different step sizes');
ylabel(ax2,'BLER, 500-slot window'); xlabel(ax2,'Slot'); grid(ax2,'on'); yline(0.1,'k--','Parent',ax2,'HandleVisibility','off');
legend(ax2,'Location','best'); ylim(ax2,[0 0.6]);
saveas(gcf, 'results/fig3_step_size.png');
fprintf('\nC) Step-size study (bias +2 dB)\n  stepUp   BLER    Mbps   conv.slot  std(Delta)\n');
fprintf('  %5.2f   %.3f   %5.1f   %8.0f   %6.2f\n', T');
writetable(array2table(T,'VariableNames',{'stepUp_dB','BLER','Throughput_Mbps','ConvergenceSlot','StdDelta_dB'}), ...
    'results/table_stepsize.csv');

%% D) CQI error magnitude: sigma x feedback delay
sig = [0 1 2 3 4];  del = [0 2 4 8];
Boff = zeros(numel(sig),numel(del));  Bon = Boff;  Gain = Boff;
for i = 1:numel(sig)
    for j = 1:numel(del)
        c = cfg;  c.cqiSigma = sig(i);  c.cqiDelay = del(j);
        R = evalCase(c, cal, G30, 1:3);
        Boff(i,j) = mean(R.off(:,1));  Bon(i,j) = mean(R.on(:,1));
        Gain(i,j) = 100*(mean(R.on(:,2))/mean(R.off(:,2)) - 1);
    end
end
figure('Name','CQI error','Position',[100 100 1400 420]);  tiledlayout(1,3);
nexttile; plotGrid(Boff, del, sig, 'BLER, OLLA off', '%.2f'); xlabel('CQI delay (slots)'); ylabel('\sigma (dB)');
nexttile; plotGrid(Bon,  del, sig, 'BLER, OLLA on',  '%.2f'); xlabel('CQI delay (slots)'); ylabel('\sigma (dB)');
nexttile; plotGrid(Gain, del, sig, 'Throughput gain of OLLA (%)', '%.1f'); xlabel('CQI delay (slots)'); ylabel('\sigma (dB)');
saveas(gcf, 'results/fig4_cqi_error.png');

%% E) Constant CQI bias
bias = -3:1:3;  Eb = zeros(numel(bias),2,2);
for i = 1:numel(bias)
    c = cfg;  c.cqiBias = bias(i);  R = evalCase(c, cal, G30, 1:3);
    Eb(i,1,:) = [mean(R.off(:,1)) mean(R.on(:,1))];
    Eb(i,2,:) = [mean(R.off(:,2)) mean(R.on(:,2))];
end
figure('Name','CQI bias','Position',[100 100 1000 420]);  tiledlayout(1,2);
nexttile; plot(bias, squeeze(Eb(:,1,1)), 'b-o', bias, squeeze(Eb(:,1,2)), 'r-s'); yline(0.1,'k--');
grid on; xlabel('CQI bias (dB)'); ylabel('BLER'); legend('OLLA off','OLLA on','Location','best');
nexttile; plot(bias, squeeze(Eb(:,2,1)), 'b-o', bias, squeeze(Eb(:,2,2)), 'r-s');
grid on; xlabel('CQI bias (dB)'); ylabel('Throughput (Mbps)'); legend('OLLA off','OLLA on','Location','best');
saveas(gcf, 'results/fig5_cqi_bias.png');

%% F) UE mobility (Doppler)
Mv = zeros(3,2,3);  Sv = Mv;
for i = 1:3
    c = cfg;  c.speed_kmh = speeds(i);
    R = evalCase(c, cal, Gs.(sprintf('v%d', speeds(i))), seeds);
    Mv(i,1,:) = mean(R.off,1);  Mv(i,2,:) = mean(R.on,1);
end
figure('Name','Mobility','Position',[100 100 1300 420]);  tiledlayout(1,3);
for k = 1:3
    nexttile; bar(Mv(:,:,k)); xticklabels(string(speeds)); grid on;
    xlabel('UE speed (km/h)'); ylabel(lab{k}); legend('OLLA off','OLLA on','Location','best');
    if k == 1, yline(0.1,'k--','HandleVisibility','off'); end
end
saveas(gcf, 'results/fig6_mobility.png');
fprintf('\nF) Mobility: speed | off [BLER Mbps MCS] | on [BLER Mbps MCS]\n');
for i = 1:3, fprintf('  %3d km/h | %.3f %5.1f %5.2f | %.3f %5.1f %5.2f\n', speeds(i), Mv(i,1,:), Mv(i,2,:)); end

save('results/all_results.mat','B','Bs','T','Boff','Bon','Gain','Eb','Mv','snrs','steps','sig','del','bias','speeds');
disp('Done. Figures and tables are in the results folder.');
