function C = makeCodecs(L)
% One DL-SCH encoder/decoder per MCS (target code rate is fixed per object).
C.enc = cell(1,15);  C.dec = cell(1,15);
for m = 1:15
    e = nrDLSCH;
    e.MultipleHARQProcesses = true;
    e.TargetCodeRate = L.tcr(m);
    d = nrDLSCHDecoder;
    d.MultipleHARQProcesses = true;
    d.TargetCodeRate = L.tcr(m);
    d.TransportBlockLength = L.tbs(m);
    d.LDPCDecodingAlgorithm = 'Normalized min-sum';
    d.MaximumLDPCIterationCount = 12;
    C.enc{m} = e;  C.dec{m} = d;
end
end