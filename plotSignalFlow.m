function plotSignalFlow(off, on, nShow)
% Signal flow, OLLA off vs on: SINR chain, selected MCS, OLLA offset, BLER convergence.
idx = 1:nShow;
cB = [0 0.447 0.741];  cR = [0.85 0.325 0.098];
runBLER = @(a) 1 - cumsum(double(a(:)))./(1:numel(a))';
figure('Name','Signal flow: OLLA off vs on','Position',[100 100 1100 850]);
tiledlayout(4,1,'TileSpacing','compact');

nexttile; hold on;
plot(idx, off.trueSinr(idx), 'k',  'DisplayName','True effective SINR');
plot(idx, off.repSinr(idx),  '--', 'Color',cB, 'DisplayName','Reported SINR (imperfect CQI)');
plot(idx, on.effSinr(idx),   'Color',cR, 'DisplayName','Reported + OLLA offset');
ylabel('SINR (dB)'); grid on; legend('Location','eastoutside');
title('1) Channel -> imperfect CQI -> OLLA-corrected SINR (first slots)');

nexttile; hold on;
stairs(idx, off.mcs(idx), 'Color',cB, 'DisplayName','OLLA off');
stairs(idx, on.mcs(idx),  'Color',cR, 'DisplayName','OLLA on');
ylabel('CQI / MCS index'); grid on; legend('Location','eastoutside');
title('2) Selected MCS');

nexttile; hold on;
plot(on.delta, 'Color',[1 0.75 0.7], 'DisplayName','\Delta per slot');
plot(movmean(on.delta,200), 'Color',cR, 'LineWidth',1.5, 'DisplayName','\Delta (200-slot mean)');
ylabel('\Delta (dB)'); grid on; legend('Location','eastoutside');
title('3) OLLA offset trajectory');

nexttile; hold on;
plot(runBLER(off.ack), 'Color',cB, 'DisplayName','OLLA off');
plot(runBLER(on.ack),  'Color',cR, 'DisplayName','OLLA on');
yline(0.1, 'k--', 'HandleVisibility','off');
ylabel('Running BLER'); xlabel('Slot'); grid on; ylim([0 0.6]);
legend('Location','eastoutside'); title('4) BLER convergence (dashed = 10% target)');
end
