# 5G NR Link Adaptation with OLLA under Imperfect CQI Feedback
DAT-610 Wireless Communication - semester project

## 1. Introduction
Problem: the gNB picks the MCS from UE-reported CQI, but CQI is delayed, noisy, quantised and
possibly biased. Goal: show how OLLA keeps BLER near 10% and what it costs/gains.

## 2. Background
- CQI/MCS selection (3GPP TS 38.214, CQI table 1, 15 entries, up to 64QAM)
- HARQ ACK/NACK feedback; BLER target 10%
- TDL-C channel (3GPP TR 38.901), delay spread 300 ns, Doppler f_d = v*fc/c

## 3. OLLA model
Offset added to reported SINR: SINR_eff = SINR_rep + Delta
  ACK : Delta <- Delta + s_up
  NACK: Delta <- Delta - s_down,   s_down = s_up (1 - BLER_t) / BLER_t  (= 9 s_up for 10%)
Equilibrium: BLER * s_down = (1 - BLER) * s_up  ->  BLER = BLER_t.  Delta clamped to [-10, +10] dB.

## 4. Simulation setup (table)
Carrier 3.5 GHz, 20 MHz, 51 PRB, SCS 30 kHz (0.5 ms slot), SISO, TDL-C 300 ns, speeds 3/30/120 km/h,
perfect channel estimation + MMSE EQ, LDPC (normalized min-sum), 64QAM CQI table 1, 20000 slots/run,
first 20% discarded, 5 seeds (mean +- std). CQI impairments: sigma, delay, bias, 1 dB quantisation.
ACK/NACK delay 4 slots. Default s_up = 0.05 dB.
Two-level method: (a) real PHY calibration (Fig. 0), (b) fast closed loop using the calibrated BLER curves,
(c) full-PHY validation (Fig. 7 + table_validation.csv).

## 5. Results (one subsection per figure; always say what you SEE, then WHY)
| Figure | File | What to discuss |
|---|---|---|
| 0 | fig0_calibration | measured thresholds vs typical AWGN values; fading shifts them up |
| 1 | fig1_signal_flow | true vs reported vs corrected SINR; Delta goes negative to cancel the +2 dB bias; BLER converges to 10% |
| 2 | fig2_snr_sweep | BLER, throughput, avg MCS vs SNR; OLLA flattens BLER at 10%; low-SNR limit = lowest MCS floor |
| 3 | fig3_step_size + table_stepsize.csv | small step = slow but smooth, large step = fast but jittery; justify chosen s_up |
| 4 | fig4_cqi_error | sigma x delay grid: BLER off/on, throughput gain of OLLA |
| 5 | fig5_cqi_bias | OLLA absorbs bias in both directions; without OLLA over/under-shoot |
| 6 | fig6_mobility | Doppler: delayed CQI hurts more; OLLA fixes BLER but cannot recover throughput lost to fading |
| 7 | fig7_phy_signal_flow + table_validation.csv | full-PHY vs abstraction agreement |

## 6. Discussion
- OLLA corrects *average* bias, not *instantaneous* error: it cannot track fades faster than its loop delay.
- Step-size trade-off: convergence speed vs steady-state jitter of Delta.
- Throughput can be equal or slightly lower with OLLA (it trades throughput for reliability, BLER 30% -> 10%).
- Limitations: SISO, wideband CQI, single transmission per block (no HARQ retransmissions), perfect channel estimation.

## 7. Conclusion
3-4 sentences: OLLA brings BLER to the target for all tested CQI errors and speeds; best step size; main limitation.

## References
3GPP TS 38.214; 3GPP TR 38.901; MATLAB 5G Toolbox documentation (NR PDSCH Throughput example);
add 2-3 OLLA/link-adaptation papers you found.
