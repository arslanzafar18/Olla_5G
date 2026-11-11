function L = getLinkConfig()
% Carrier, PDSCH and per-MCS transport-block parameters (5G Toolbox).
L.scs_kHz = 30;  L.nPRB = 51;  L.fc = 3.5e9;       % 20 MHz, 30 kHz SCS
L.profile = 'TDL-C';  L.delaySpread = 300e-9;
L.slotDur = 1e-3/(L.scs_kHz/15);                    % 0.5 ms

carrier = nrCarrierConfig;
carrier.SubcarrierSpacing = L.scs_kHz;
carrier.NSizeGrid = L.nPRB;
carrier.CyclicPrefix = 'normal';
carrier.NCellID = 1;

pdsch = nrPDSCHConfig;
pdsch.PRBSet = 0:L.nPRB-1;
pdsch.SymbolAllocation = [0 14];
pdsch.MappingType = 'A';
pdsch.NumLayers = 1;
pdsch.DMRS.DMRSConfigurationType = 1;
pdsch.DMRS.DMRSTypeAPosition = 2;
pdsch.DMRS.DMRSAdditionalPosition = 1;

L.carrier = carrier;  L.pdsch = pdsch;
L.ofdmInfo = nrOFDMInfo(carrier);
[L.mod, L.tcr, L.thrApprox] = cqiTable();
L.G = zeros(1,15);  L.tbs = zeros(1,15);
for m = 1:15
    p = pdsch;  p.Modulation = L.mod{m};
    [~, info] = nrPDSCHIndices(carrier, p);
    L.G(m)   = info.G;                               % coded bits per slot
    L.tbs(m) = nrTBS(L.mod{m}, 1, L.nPRB, info.NREPerPRB, L.tcr(m), 0);
end
end
