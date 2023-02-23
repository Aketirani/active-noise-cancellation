function Te = noisyspeech(s, x, L, Pw, play, plot_save, plot_path)
% Noise reduction on noisy speech using different adaptive filters
%
% Inputs:
%	s: [1xN] vector of the clean speech signal
%   x: [1xN] vector of the noisy signal
%	L: [1x1] filter length (positive integer)
%   Pw: [Lx1] impulse response of the system
%   play: string indicating which audio to play, options are:
%         - 'none': play nothing
%         - 's': play clean speech signal
%         - 'fx': play filtered noise signal
%         - 'd': play noisy speech signal
%         - 'dfx': play ideal noise-free signal
%         - 'lms': play noisy speech signal filtered using LMS algorithm
%         - 'nlms': play noisy speech signal filtered using NLMS algorithm
%         - 'rls': play noisy speech signal filtered using RLS algorithm
%         - 'fxlms': play noisy speech signal filtered using FxLMS algorithm
%         - 'fxnlms': play noisy speech signal filtered using FxNLMS algorithm
%         - 'fxrls': play noisy speech signal filtered using FxRLS algorithm
%   plot_save: save the figure into a png if set to true (logical)
%   plot_path: path to save the figure (string)
%
% Outputs:
%	Te: [7x2] table containing the error for each adaptive filter algorithm

% Validate inputs
assert(nargin == 7, 'Invalid number of input arguments. The function requires 7 input arguments.')
assert(isvector(s), 's must be a vector.')
assert(isvector(x), 'x must be a vector.')
assert(isnumeric(L) && isscalar(L) && L > 0, 'L must be a positive scalar.')
assert(isvector(Pw), 'Pw must be a vector.')
assert(ischar(play), 'play must be a string.')
assert(islogical(plot_save), 'plot_save must be a boolean value.');
assert(ischar(plot_path), 'play must be a string.')
assert(length(s) == length(x), 's and x must have the same length.')
assert(any(strcmpi(play, {'none', 's', 'fx', 'd', 'dfx', 'lms', 'nlms', 'rls', 'fxlms', 'fxnlms', 'fxrls'})), ...
    'play is invalid. It must be one of the following: ''none'', ''s'', ''fx'', ''d'', ''dfx'', ''lms'', ''nlms'', ''rls'', ''fxlms'', ''fxnlms'', or ''fxrls''.')

% Initializate parameters
fs = 8000;                 % sample rate
T = length(s);             % number of observations
fx = filter(Pw,1,x);       % filtered noise
d = s+fx;                  % speech + filtered noise d(n)
time = T/fs;               % total time of audio
tv = 0:time/T:time-time/T; % time vector

% Define algorithm parameters
mu_LMS = 0.05;  % lms step size
delta = 0.1;    % regularization parameter
beta = 0.997;   % forget factor
lambda = 0.1;   % regularization
mu_FxLMS = 0.3; % fxlms step size

% LMS on white noise - used for filtered algorithms
Sw = Pw*0.9;          % secondary path weights
wn = randn(T,1);      % white noise
yn = filter(Sw,1,wn); % desired signal
mu_wn = 0.1;          % step size
[~, ~, Shw, Shx] = lms(wn, yn, L, mu_wn);

% Algorithms
[yW,eW] = wiener(x, d, L);
[yLMS,eLMS] = lms(x, d, L, mu_LMS);
[yNLMS,eNLMS] = nlms(x, d, L, mu_LMS, delta);
[yRLS,eRLS] = rls(x, d, L, beta, lambda);
[yFxLMS,eFxLMS] = fxlms(x, d, L, mu_FxLMS, Sw, Shw, Shx);
[yFxNLMS,eFxNLMS] = fxnlms(x, d, L, mu_FxLMS, Sw, Shw, Shx, delta);
[yFxRLS,eFxRLS] = fxrls(x, d, L, beta, lambda, Sw, Shw, Shx);

% Create table
methods = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
mse = [mean(eW); mean(eLMS); mean(eNLMS); mean(eRLS); mean(eFxLMS); mean(eFxNLMS); mean(eFxRLS)];
Te = table(methods', mse, 'VariableNames', {'Method', 'Error'});

% Play audio
if strcmpi(play,'none')
    % nothing
elseif strcmpi(play,'s')
    sound(s)         % speech
elseif strcmpi(play,'fx')
    sound(fx)        % filtered noise
elseif strcmpi(play,'d')
    sound(d)         % noisy speech
elseif strcmpi(play,'dfx')
    sound(d-fx)      % ideal
elseif strcmpi(play,'w')
    sound(d-yW)      % weiner
elseif strcmpi(play,'lms')
    sound(d-yLMS)    % lms
elseif strcmpi(play,'nlms')
    sound(d-yNLMS)   % nlms
elseif strcmpi(play,'rls')
    sound(d-yRLS)    % rls
elseif strcmpi(play,'fxlms')
    sound(d-yFxLMS)  % fxlms
elseif strcmpi(play,'fxnlms')
    sound(d-yFxNLMS) % fxnlms
elseif strcmpi(play,'fxrls')
    sound(d-yFxRLS)  % fxrls
end

% Apply moving average filter
maL = 100; % filter length
eW = movmean(eW, maL);
eLMS = movmean(eLMS, maL);
eNLMS = movmean(eNLMS, maL);
eRLS = movmean(eRLS, maL);
eFxLMS = movmean(eFxLMS, maL);
eFxNLMS = movmean(eFxNLMS, maL);
eFxRLS = movmean(eFxRLS, maL);

% Plot results
figure(4)
plot(1:T,10*log10(eW),'k',1:T,10*log10(eLMS),'b',1:T,10*log10(eNLMS),'r',1:T,10*log10(eRLS),'g',...
    1:T,10*log10(eFxLMS),'c',1:T,10*log10(eFxNLMS),'m',1:T,10*log10(eFxRLS),'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Time (s)'); ylabel('MSE (dB)')
figure(5)
plot(tv,fx-yW,'k', tv,fx-yLMS,'b',tv,fx-yNLMS,'r',tv,fx-yRLS,'g',...
    tv,fx-yFxLMS,'c',tv,fx-yFxNLMS,'m',tv,fx-yFxRLS,'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Convergence'); xlabel('Time (s)'); ylabel('Error')
figure(6)
signals = {s, fx, d, d-yFxRLS};
titles = [{'Speech'},{'Noise'},{'Noisy speech'},{'Filtered output'}];
hw = 256; % hamming window size
np = 50;  % amount of overlap
for i = 1:length(signals)
    subplot(length(signals),1,i);
    [S, F, T] = spectrogram(signals{i}, hw, np, [], fs);
    imagesc(T, F, 20*log10(abs(S))); % convert to dB
    set(gca,'YDir','normal');        % flip y-axis direction
    title(titles(i)); xlabel('Time (s)'); ylabel('Frequency (Hz)');
end

% Save figures to plot_path
if plot_save == true
    saveas(figure(4), [plot_path 'PerformanceNS.png']);
    saveas(figure(5), [plot_path 'ConvergenceNS.png']);
    saveas(figure(6), [plot_path 'NoiseSpeech.png']);
end
