function ch = makeChannel(L, speed_kmh, seed)
% TDL-C channel (nrTDLChannel), SISO, Doppler from UE speed.
tdl = nrTDLChannel;
tdl.DelayProfile = L.profile;
tdl.DelaySpread  = L.delaySpread;
tdl.MaximumDopplerShift = speed_kmh/3.6*L.fc/299792458;
tdl.NumTransmitAntennas = 1;
tdl.NumReceiveAntennas  = 1;
tdl.SampleRate = L.ofdmInfo.SampleRate;
tdl.Seed = seed;
chInfo = info(tdl);
ch.tdl = tdl;
ch.maxDelay = ceil(max(chInfo.PathDelays*tdl.SampleRate)) + chInfo.ChannelFilterDelay;
ch.pathFilters = getPathFilters(tdl);
end
