clear
clc
close all

%% Load the signal and declare necessary variables

load('signal1');
% sig contains the ECG sequence
% BMP0 contains an array of the true BPM values of all 8 sec segments,
% each separated by a step size of 2 sec from its next

Fs = 125; % sampling frequency in Hz
window_len = 8 * Fs; % window length in samples (1 second = 'Fs' samples, do the math!)
step_size = 2 * Fs; % step size is 2 seconds

window1 = sig(1:window_len);
window2 = sig(1+step_size:1+step_size+window_len);
% window3 = sig(1+2*step_size:1+2*step_size+window_len);
% window4 = ...
%
%
% window148 = ...

plot(window1);

total_windows = floor((length(sig)-window_len)/step_size) + 1; 

BPMC = zeros(size(BPM0)); % array to store the calculated heart rate (BPM)

%% Generate the ecg QRS template

nf=1:12;
cf = (-3*nf+18).*(nf>=5 & nf<=7); % example template

figure;
plot(nf,cf);title('template for the ecg');


%% Main Algorithm
% feel free to add additional variables/arrays etc suited to your need

for i = 1 : total_windows
    START = ??; END = ??
    curSegment = START : END % the samples that should go in the i'th window
    ecg_window = sig(curSegment); %the windowed signal
    
    % DO: perform cross-correlation between qrs template and the ecg window
    
    % DO: obtain the peaks from the cross-correlation sequence (Rc), DO NOT USE
    % the built-in "FINDPEAKS" function, write your own code from scratch
    
    % DO: find the total number of R-peaks in the current ecg window,
    % remember, number of R-peaks = number of peaks in the above
    % cross-correlation sequence (Rc)
    
    % DO: find the bpm value (total beats per 60 sec); Fs is known
    % bpm_calc = ...
    
    BMPC(i) = bmp_calc;
end


%% Calculation of error

mean_error = mean(abs(BPMC-BPM0)) % mean_error must be < 0.1
max_error = max(abs(BPMC-BPM0)) % max error must be < 1

% FOR FULL MARKS, TRY TO ACHIEVE THE GIVEN ERROR BOUNDS

%% Plot the beats per minutes

figure;
plot(BPMC,'b');
hold on, plot(BPM0,'r');
title('Heart Rate Tracking');
xlabel('Window number');
ylabel('Heart Rate (BPM)'); ylim([0, 200]);
legend('Estimated Heart Rate','Ground Truth Heart Rate')