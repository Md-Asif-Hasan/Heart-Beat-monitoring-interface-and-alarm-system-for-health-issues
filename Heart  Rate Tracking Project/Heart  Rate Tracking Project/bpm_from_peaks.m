function bpm = bpm_from_peaks(peakIdx, ~ , Fs)
  bpm = NaN;
  if numel(peakIdx) < 2, return; end
  rr = diff(peakIdx)/Fs;
  rr = rr(rr>0.3 & rr<2.0); % 30–200 bpm
  if isempty(rr), return; end
  bpm = 60/median(rr);
  % Alternative robust count method:
  % bpm = 60 * (numel(peakIdx)-1) / ((peakIdx(end)-peakIdx(1))/Fs);
end
