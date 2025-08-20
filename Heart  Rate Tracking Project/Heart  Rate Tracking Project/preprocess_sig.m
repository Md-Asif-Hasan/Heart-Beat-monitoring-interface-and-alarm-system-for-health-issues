function x_f = preprocess_sig(x, cfg)
% x: column or row vector
  x = x(:) - mean(x);
  Fs = cfg.Fs;

  % Optional notch(es)
  if ~isempty(cfg.notch)
    for f0 = cfg.notch
      wo = f0/(Fs/2); bw = wo/35;
      [b,a] = iirnotch(wo,bw);
      x = filtfilt(b,a,x);
    end
  end

  % Bandpass
  [b,a] = butter(3, cfg.bpFilt/(Fs/2), 'bandpass');
  x_f = filtfilt(b,a,x);
end
