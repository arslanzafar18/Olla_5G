5G NR link adaptation with OLLA under imperfect CQI feedback  (DAT-610)
MATLAB R2022a + 5G Toolbox 2.4 + Communications Toolbox
=========================================================================
Put ALL files in one folder, set it as the MATLAB current folder, then run IN ORDER:

  1) main_1a_calibrate.m     (once, ~10-20 min)  real 5G PHY over TDL-C -> BLER-vs-SINR curves per CQI/MCS
                             creates calibration.mat and results/fig0_calibration.png
  2) main_1b_traces.m        (once, ~5-15 min)   TDL-C channel traces for 3, 30, 120 km/h
                             creates trace_3kmh.mat, trace_30kmh.mat, trace_120kmh.mat
  3) main_2_experiments.m    (a few min)         ALL report figures/tables (OLLA on/off, SNR, step size,
                             CQI sigma x delay, CQI bias, mobility) -> results/
  4) main_3_phy_validation.m (~5-15 min)         full-PHY closed loop vs the fast simulator (validation)

Method (say this in the report):
  * Link level (real PHY): nrDLSCH/nrPDSCH/nrTDLChannel (TDL-C, 300 ns, 30 kHz SCS, 51 PRB),
    perfect channel estimation, MMSE equalisation, LDPC decoding -> BLER(eff. SINR) per MCS.
  * Link adaptation level: long closed-loop runs use those calibrated curves with the TDL-C
    channel trace (link-to-system abstraction); main_3 validates it against full-PHY runs.

File roles
  defaultCfg, cqiTable, getLinkConfig       configuration and 3GPP CQI table 1
  makeChannel, makeCodecs, phySlot          5G Toolbox PHY chain (one slot)
  buildBlerCurves, plotCalibration          offline calibration
  genChannelTrace, effSinrFromG             channel trace and capacity-effective SINR
  impairCQI, selectMCS, ollaUpdate, blerModel   CQI errors, MCS lookup, OLLA, BLER model
  runLinkSim, runPhySim, evalCase           simulators (fast / full PHY / on-off multi-seed)
  computeMetrics, convergenceSlot           metrics
  plotSignalFlow, plotGrid                  plots

If a 5G Toolbox call errors on the first run, the error message names the exact line:
send me the message and the line and I will fix it.
