function alert = detect_anomaly(bpm, baseline, cfg, prevBpm)
  if nargin<4, prevBpm = NaN; end
  alert = struct('type','none','msg','');

  if isnan(bpm)
    alert.type='noisy'; alert.msg='No reliable peaks'; return;
  end
  if bpm < cfg.bradyThresh
    alert.type='brady'; alert.msg='Bradycardia threshold'; return;
  elseif bpm > cfg.tachyThresh
    alert.type='tachy'; alert.msg='Tachycardia threshold'; return;
  end

  if isfinite(baseline.mean) && baseline.std>0
    z = (bpm - baseline.mean)/baseline.std;
    if abs(z) >= cfg.zThresh
      alert.type='z-anomaly'; alert.msg=sprintf('Z=%.2f',z); return;
    end
  end

  if isfinite(prevBpm)
    if abs(bpm - prevBpm) > 30
      alert.type='sudden-change'; alert.msg='Rapid BPM change'; return;
    end
  end
end
