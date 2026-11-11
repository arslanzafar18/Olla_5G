function [mod, tcr, thrApprox] = cqiTable()
% 3GPP TS 38.214 Table 5.2.2.1-2 (CQI table 1, up to 64QAM), 15 entries.
% Each CQI index is used directly as the MCS (modulation + target code rate).
mod  = [repmat({'QPSK'},1,6), repmat({'16QAM'},1,3), repmat({'64QAM'},1,6)];
rate1024 = [78 120 193 308 449 602 378 490 616 466 567 666 772 873 948];
tcr  = rate1024/1024;
% Typical AWGN SINR (dB) for 10% BLER per CQI - only used as a starting
% point for the calibration sweep; the real thresholds are measured.
thrApprox = [-6.7 -4.7 -2.3 0.2 2.4 4.3 5.9 8.1 10.3 11.7 14.1 16.3 18.7 21.0 22.7];
end
