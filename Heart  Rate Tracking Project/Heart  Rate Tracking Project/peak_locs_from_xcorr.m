function idx_sig = peak_locs_from_xcorr(x_win, tmpl, cfg, Fs)
% Cross-correlate window with template and return peak indices in signal coordinates
  if nargin<4, Fs = cfg.Fs; end
  r = xcorr(x_win, tmpl, 'biased');
  r(r<0) = 0;

  thr = cfg.promFrac * max(r);
  lock = round(cfg.peakLockout * Fs);

  peaks = [];
  k = 2; N = numel(r);
  while k < N
    if r(k) > thr && r(k) >= r(k-1) && r(k) >= r(k+1)
      left  = k;
      right = min(k+lock, N);
      [~, rel] = max(r(left:right));
      kpeak = left + rel - 1;
      peaks(end+1) = kpeak; %#ok<AGROW>
      k = kpeak + lock;
    else
      k = k + 1;
    end
  end

  Nt = numel(tmpl);
  idx_sig = peaks - Nt + 1;
  idx_sig = idx_sig(idx_sig>=1 & idx_sig<=numel(x_win));
end
