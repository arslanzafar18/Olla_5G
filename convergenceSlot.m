function n = convergenceSlot(ack, target, win)
% First slot at which the trailing-window (win slots) BLER is within target+0.03.
e  = double(~ack(:));
mv = movmean(e, [win-1 0]);
i  = find(mv(win:end) <= target + 0.03, 1);
if isempty(i), n = NaN; else, n = i + win - 1; end
end
