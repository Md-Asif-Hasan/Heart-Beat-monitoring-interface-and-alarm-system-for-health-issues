function idx = pan_tompkins_ecg(x, cfg)
  Fs = cfg.Fs;
  % Derivative filter (approximate)
  d = filter([1 2 0 -2 -1]*(Fs/8), 1, x);
  s = d.^2;
  M = round(0.15*Fs);
  m = movmean(s, M);

  thr = 0.4*max(m);
  lock = round(cfg.peakLockout*Fs);

  idx = [];
  k = 2; N = numel(m);
  while k < N
    if m(k) > thr && m(k) >= m(k-1) && m(k) >= m(k+1)
      left = k; right = min(k+lock, N);
      [~, rel] = max(m(left:right));
      kpeak = left + rel - 1;
      idx(end+1) = kpeak; %#ok<AGROW>
      k = kpeak + lock;
    else
      k = k + 1;
    end
  end
end
