function qrsT = make_qrs_template()
% Wavelet-based compact QRS-like template
  fb  = dwtfilterbank('Wavelet','sym4','SignalLength',1000,'Level',3);
  psi = wavelets(fb);
  qrsT = -2*circshift(psi(3,:),[0 -38]);
  qrsT = qrsT - mean(qrsT);
  qrsT = qrsT / norm(qrsT);
end
