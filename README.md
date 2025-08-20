# Heart Rate Tracking System (MATLAB)

A modular MATLAB implementation for estimating heart rate from ECG (or PPG) signals, designed for wearable-device constraints and real-time simulation. The system performs preprocessing, peak detection, BPM computation, baseline calibration, anomaly detection, visualization, and logging.

## Project Structure

- main_hr_tracker.m — orchestrates the pipeline, visualization, metrics, and logging
- preprocess_sig.m — filtering and conditioning (notch + band-pass)
- make_qrs_template.m — builds a compact QRS-like template (wavelet-based)
- peak_locs_from_xcorr.m — template-matching peak detector with custom peak logic
- pan_tompkins_ecg.m — alternative Pan–Tompkins-style detector (derivative → square → integration)
- bpm_from_peaks.m — BPM estimation from inter-peak intervals
- update_baseline.m — rolling baseline statistics for personalization
- detect_anomaly.m — rule- and z-score-based anomaly detection
- append_log.m — CSV logging (timestamp, window index, BPM, alert)

Optional data file:
- signal1.mat — example dataset expected to contain variables sig (ECG vector) and BPM0 (ground-truth BPM per window)

## Requirements

- MATLAB R2020b or newer recommended
- Signal Processing Toolbox (for filters and filtfilt)
- Wavelet Toolbox (for make_qrs_template). If unavailable, switch detector to 'pan' in main_hr_tracker.m.

## Quick Start

1) Place all .m files and signal1.mat in the same folder.

2) In MATLAB:
   - cd into the project folder
   - run:
     - main_hr_tracker

3) The script will:
   - Filter and window the signal
   - Detect peaks and compute BPM for each window
   - Plot ECG window with detected peaks and a rolling BPM trace
   - Compare with BPM0 (if present), reporting mean and max errors
   - Log results to hr_log.csv

## Configuration

Adjust parameters at the top of main_hr_tracker.m:

- Fs: sampling rate (Hz). Example: 125 for provided dataset
- sigType: 'ECG' or 'PPG' (informational)
- winSec, hopSec: analysis window length and hop size (s)
- bpFilt: band-pass cutoffs
  - ECG: [5 20] Hz targets QRS energy
  - PPG: [0.5 8] Hz for cardiac pulsations
- notch: [] to disable; use  or  to suppress mains hum
- qrsTemplate: 'wavelet' (template matching) or 'pan' (Pan–Tompkins)
- peakLockout: refractory period in seconds (ECG ~0.20s; PPG ~0.35s)
- promFrac: correlation prominence fraction (0.4–0.7 typical)
- Baseline and alerts:
  - baselineWinMin: minutes of rolling baseline
  - zThresh: z-score threshold for anomalies
  - bradyThresh, tachyThresh: hard BPM thresholds

Example:
Fs=125, winSec=8, hopSec=2 yields ~2s update cadence with 8s context.

## How It Works

1) Preprocessing
   - Optional notch (50/60Hz), then 3rd-order Butterworth band-pass
   - Zero-phase filtering for offline analysis (filtfilt)

2) Feature Extraction
   - Option A: Cross-correlation with a compact QRS template
     - Half-wave rectification, dynamic thresholding
     - Custom local-maximum search with lockout (no findpeaks)
   - Option B: Pan–Tompkins-inspired detector
     - Derivative → squaring → moving-window integration → custom peak logic

3) Heart Rate Calculation
   - Compute RR intervals from consecutive peaks
   - Filter physiologic intervals (0.3–2.0s ≈ 30–200BPM)
   - BPM = 60/median(RR) for robustness

4) Baseline Calibration
   - Rolling mean and std over baselineWinMin minutes
   - Personalized bands for anomaly detection

5) Deviation Detection
   - Hard limits (brady/tachy)
   - Z-score vs. baseline
   - Sudden-change guard (e.g., |ΔBPM|>30 within one hop)

6) Visualization and Logging
   - Live ECG window with detected peaks
   - BPM trace with optional ground truth overlay
   - CSV log: timestamp, window index, BPM, alert type/message

## Switching to PPG

- Set bpFilt = [0.5 8], peakLockout ≈ 0.35
- Prefer 'pan' path or implement a PPG-specific systolic-peak detector
- Validate thresholds against typical PPG morphology and sampling rate

## Evaluation

If BPM0 is present in signal1.mat:
- mean_error = mean(abs(Estimated - BPM0), 'omitnan')
- max_error = max(abs(Estimated - BPM0))
Tune:
- Filter band edges (ECG 5–15 or 5–20Hz)
- promFrac (0.4–0.7), peakLockout (0.18–0.25s)
- Use median RR and remove outlier intervals

## Common Issues and Fixes

- Off-by-one window indexing: END_ = START + winLen − 1
- Empty BPM values: detector thresholds too high; reduce promFrac or relax band-pass
- Excess peaks: increase peakLockout or raise promFrac slightly
- Phase distortion in real time: replace filtfilt with filter and accept delay, or compensate

## Extending to Real Time

- Replace file-based input with streaming from serial/BLE into a ring buffer
- Port peak detector into a MATLAB Function block in Simulink
- Add Stateflow for alert state management
- Optimize for low power: simplify filters, reuse buffers, avoid heavy graphics

## Outputs

- Plots: ECG window with detected peaks; BPM vs. window index
- Console: mean and max error (when BPM0 available)
- File: hr_log.csv with per-window BPM and alerts

## License

For academic and research use. Provide attribution in derivative works.

## Contact

If a zipped package is preferred or if an App Designer UI/Simulink model is needed, mention the target MATLAB version and desired features, and a packaged bundle can be prepared.
