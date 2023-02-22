% Main
clear, clc, clf % clear
rng('default')  % generate the same random numbers

% Load data
load('../data/speech') % load speech
load('../data/noise')  % load noise
load('../data/bpir')   % load filter

% Initializate parameters
play_mode = false;
fs = 8000;     % sample rate
s = speech;    % speech x(n)
T = length(s); % number of observations
x = noise;     % noise
Pw = bpir;     % filter P(z)
fx = filter(Pw,1,x); % filtered noise
d = s+fx;      % speech + filtered noise d(n)
time = T/fs;   % total time of audio
tv = 0:time/T:time-time/T; % time vector

% Define algorithm parameters
L = 10;          % filter length
mu_LMS = 0.05;   % lms step size
delta = 0.1;     % regularization parameter
beta = 0.997;    % forget factor
lambda = 0.1;    % regularization
mu_FxLMS = 0.3;  % fxlms step size

% LMS on white noise - used for filtered algorithms
Sw = Pw*0.9;          % secondary path weights
wn = randn(T,1);      % white noise
yn = filter(Sw,1,wn); % desired signal
mu_wn = 0.1;          % step size
[~, ~, Shw, Shx] = lms(wn, yn, L, mu_wn);

% Algorithms
[yLMS, eLMS] = lms(x, d, L, mu_LMS);
[yNLMS, eNLMS] = nlms(x, d, L, mu_LMS, delta);
[yRLS, eRLS] = rls(x, d, L, beta, lambda);
[yFxLMS, eFxLMS] = fxlms(x, d, L, mu_FxLMS, Sw, Shw, Shx);
[yFxNLMS, eFxNLMS] = fxnlms(x, d, L, mu_FxLMS, Sw, Shw, Shx, delta);
[yFxRLS, eFxRLS] = fxrls(x, d, L, beta, lambda, Sw, Shw, Shx);

% Create table
methods = {'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
mse = [mean(eLMS); mean(eNLMS); mean(eRLS); mean(eFxLMS); mean(eFxNLMS); mean(eFxRLS)];
T = table(methods', mse, 'VariableNames', {'Method', 'MSE'});
disp(T);

% Play sounds
if play_mode == true
    sound(s)           % speech
    sound(fx)          % filtered noise
    sound(d)           % noisy speech
    sound(d-fx)        % ideal
    sound(d-yLMS)      % lms
    sound(d-yNLMS)     % nlms
    sound(d-yRLS)      % rls
    sound(d-yFxLMS)    % fxlms
    sound(d-yFxNLMS)   % fxnlms
    sound(d-yFxRLS)    % fxrls
end

% Plot results
figure(4)
plot(tv,fx-yLMS,'b',tv,fx-yNLMS,'r',tv,fx-yRLS,'g',...
    tv,fx-yFxLMS,'c',tv,fx-yFxNLMS,'m',tv,fx-yFxRLS,'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Time (sec)'); ylabel('Error')
figure(5)
signals = {s, fx, d, d-yFxRLS};
titles = [{'Speech'},{'Noise'},{'Noisy speech'},{'Filtered output'}];
hw = 256; % hamming window size
np = 50;  % amount of overlap
for i = 1:length(signals)
    subplot(length(signals),1,i);
    spectrogram(signals{i},hw,np,'yaxis')
    title(titles(i)); xlabel('time index'); ylabel('freq. index')
end
