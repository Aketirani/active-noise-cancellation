% Main
clear, clc, clf  % clear
rng('default')   % generate the same random numbers

% Load data
load('../data/speech') % load speech
load('../data/noise')  % load noise
load('../data/bpir')   % load filter

% Initializate parameters
fs = 8000;     % sample rate
s = speech;    % speech x(n)
T = length(s); % number of observations
x = noise;     % noise
Pw = bpir;     % filter P(z)
fx = filter(Pw,1,x); % filtered noise
d = s+fx;      % speech + filtered noise d(n)
L = 10;        % filter length
time = T/fs;   % total time of audio
tv = 0:time/T:time-time/T; % time vector

% LMS on white noise - used for filtered algorithms
Sw = Pw*0.9;          % secondary path weights
wn = randn(T,1);      % white noise
yn = filter(Sw,1,wn); % desired signal
mu_wn = 0.1;          % step size
[~, ~, Shx, Shw] = lms(wn, yn, L, mu_wn);

% Adaptive filters
% LMS
mu_LMS = 0.05;       % step size
[yLMS, eLMS] = lms(x, d, L, mu_LMS);
fprintf('MSE: %f - LMS\n',mean(eLMS));
% NLMS
mu_NLMS = 0.05;      % step-size
delta = 0.1;         % regularization parameter
[yNLMS, eNLMS] = nlms(x, d, L, mu_NLMS, delta);
fprintf('MSE: %f - NLMS\n',mean(eNLMS));
% RLS
beta_RLS = 0.997;    % forget factor
lambda_RLS = 0.1;    % regularization
[yRLS, eRLS] = rls(x, d, L, beta_RLS, lambda_RLS);
fprintf('MSE: %f - RLS\n',mean(eRLS));
% FxLMS
mu_FxLMS = 0.3;      % step size
[yFxLMS, eFxLMS] = fxlms(x, d, L, mu_FxLMS, Sw, Shw, Shx);
fprintf('MSE: %f - FxLMS\n',mean(eFxLMS));
% FxNLMS
mu_FxNLMS = 0.3;     % step size
delta = 0.1;         % regularization parameter
[yFxNLMS, eFxNLMS] = fxnlms(x, d, L, mu_FxNLMS, Sw, Shw, Shx, delta);
fprintf('MSE: %f - FxNLMS\n',mean(eFxNLMS));
% FxRLS
beta_FxRLS = 0.997;  % forget factor
lambda_FxRLS = 0.1;  % regularization
[yFxRLS, eFxRLS] = fxrls(x, d, L, beta_FxRLS, lambda_FxRLS, Sw, Shw, Shx);
fprintf('MSE: %f - FxRLS\n',mean(eFxRLS));

% Plot
figure(1)
plot(tv,fx-yLMS,'b',tv,fx-yNLMS,'r',tv,fx-yRLS,'g',...
    tv,fx-yFxLMS,'c',tv,fx-yFxNLMS,'m',tv,fx-yFxRLS,'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Time (sec)'); ylabel('Error')

% Play sounds
% sound(s)           % play speech
% sound(fx)          % play filtered noise
% sound(d)           % play speech + filtered noise

% Play results
% sound(d-fx)        % Ideal
% sound(d-yLMS)      % LMS
% sound(d-yNLMS)     % NLMS
% sound(d-yRLS)      % RLS
% sound(d-yFxLMS)    % FxLMS
% sound(d-yFxNLMS)   % FxNLMS
% sound(d-yFxRLS)    % FxRLS

% Plot
figure(2)
signals = {s, fx, d, d-yFxRLS};
titles = [{'Speech'},{'Noise'},{'Noisy speech'},{'Filtered output'}];
hw = 256; % hamming window size
np = 50;  % number of overlap
for i = 1:length(signals)
    subplot(length(signals),1,i);
    spectrogram(signals{i},hw,np,'yaxis')
    title(titles(i)); xlabel('time index'); ylabel('freq. index')
end