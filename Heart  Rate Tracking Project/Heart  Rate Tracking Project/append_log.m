function append_log(filename, winIdx, bpm, alert)
% Append a CSV log row; creates file with header if absent
  if ~exist(filename,'file')
    fid = fopen(filename,'w');
    fprintf(fid,'timestamp,window_idx,bpm,alert_type,alert_msg\n');
  else
    fid = fopen(filename,'a');
  end
  ts = datetime("now",'yyyy-mm-ddTHH:MM:SS');
  if isempty(alert), alert.type='none'; alert.msg=''; end
  fprintf(fid,'%s,%d,%.3f,%s,%s\n', ts, winIdx, bpm, alert.type, alert.msg);
  fclose(fid);
end
