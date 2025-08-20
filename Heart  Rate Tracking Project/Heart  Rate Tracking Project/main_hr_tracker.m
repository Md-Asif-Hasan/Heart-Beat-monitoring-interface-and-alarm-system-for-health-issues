clear; clc; close all;

% Configuration
cfg = struct( ...
  'Fs',125, ...
  'sigType','ECG', ...
  'winSec',8, ...
  'hopSec',2, ...
  'bpFilt',[5 20], ...       % ECG QRS band
  'notch',[], ...            % e.g., [50] or 
  'qrsTemplate','wavelet', ... % 'wavelet' or 'pan'
  'peakLockout',0.200, ...
  'promFrac',0.6, ...
  'baselineWinMin',5, ...
  'zThresh',3, ...
  'bradyThresh',50, ...
  'tachyThresh',120);

% Load data
load('signal1');             % variables: sig, BPM0
Fs = cfg.Fs;

% Derived sizes
winLen = cfg.winSec*Fs;
hop    = cfg.hopSec*Fs;
nWins  = floor((numel(sig)-winLen)/hop)+1;

% Precompute template (for template path)
tmpl = make_qrs_template();

BPMC = nan(1,nWins);
BaselineBuf = [];
prevBpm = NaN;

% Optional figures
f1 = figure('Name','Heart Rate Tracking'); 
ax1 = subplot(2,1,1); title(ax1,'ECG Window'); xlabel(ax1,'Samples'); ylabel(ax1,'Amplitude');
ax2 = subplot(2,1,2); title(ax2,'Heart Rate Tracking'); xlabel(ax2,'Window #'); ylabel(ax2,'BPM'); ylim(ax2,[0 200]); hold(ax2,'on');

for i = 1:nWins
  START = 1 + (i-1)*hop;
  END_  = START + winLen - 1;
  xw = sig(START:END_);

  % Preprocess
  xw_f = preprocess_sig(xw, cfg);

  % Peaks
  switch lower(cfg.qrsTemplate)
    case 'wavelet'
      pk = peak_locs_from_xcorr(xw_f, tmpl, cfg, Fs);
    case 'pan'
      pk = pan_tompkins_ecg(xw_f, cfg);
    otherwise
      error('Unknown qrsTemplate: %s', cfg.qrsTemplate);
  end

  % BPM
  bpm = bpm_from_peaks(pk, winLen, Fs);
  BPMC(i) = bpm;

  % Baseline + alerts
  [baseline, BaselineBuf] = update_baseline(BaselineBuf, bpm, cfg);
  alert = detect_anomaly(bpm, baseline, cfg, prevBpm);
  prevBpm = bpm;

  % Plot
  if ishandle(f1)
    cla(ax1);
    plot(ax1, xw_f, 'k'); hold(ax1,'on');
    if ~isempty(pk), stem(ax1, pk, xw_f(pk), 'r'); end
    text(ax1, 10, 0.9*max(abs(xw_f)), sprintf('BPM: %.1f', bpm), 'Color','b');
    plot(ax2, 1:i, BPMC(1:i), 'b-'); 
    if exist('BPM0','var') && numel(BPM0)>=i, plot(ax2, 1:i, BPM0(1:i), 'r-'); end
    legend(ax2, {'Estimated','Ground Truth'}, 'Location','best'); drawnow;
  end

  % Log (optional)
  append_log('hr_log.csv', i, bpm, alert);
end

% Metrics vs ground truth if available
if exist('BPM0','var')
  mean_error = mean(abs(BPMC - BPM0), 'omitnan')
  max_error  = max(abs(BPMC - BPM0))
end
