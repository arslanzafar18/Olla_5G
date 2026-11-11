function plotCalibration(cal)
% Fitted BLER-vs-effective-SINR curves and measured vs typical thresholds.
figure('Name','PHY calibration','Position',[100 100 1100 450]);
tiledlayout(1,2);
nexttile; hold on;
x = -10:0.1:30;
for m = 1:15
    semilogy(x, 1./(1+exp(cal.k(m)*(x-cal.mid(m)))), 'LineWidth', 1);
end
set(gca,'YScale','log'); yline(0.1,'k--'); grid on; ylim([1e-3 1]);
xlabel('Effective SINR (dB)'); ylabel('BLER'); title('Fitted BLER curves, CQI 1-15 (TDL-C, 5G PHY)');
nexttile;
plot(1:15, cal.thrApprox, 'o-', 1:15, cal.thr, 's-'); grid on;
xlabel('CQI / MCS index'); ylabel('SINR at 10% BLER (dB)');
legend('Typical AWGN values','Measured (TDL-C, effective SINR)','Location','northwest');
title('10% BLER thresholds');
end
