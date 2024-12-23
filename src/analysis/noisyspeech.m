function Te = noisyspeech(s, x, L, Pw, c, play)
% Noise reduction on noisy speech using different adaptive filters
%
% Inputs:
%	s    : [1xN] vector of the clean speech signal
%   x    : [1xN] vector of the noisy signal
%	L    : [1x1] filter length (positive integer)
%   Pw   : [Lx1] impulse response of the system
%   c    : [struct] containing configuration parameters
%   play : [string] indicating which audio to play, options are:
%         - none   : play nothing
%         - s      : play clean speech signal
%         - fx     : play filtered noise signal
%         - d      : play noisy speech signal
%         - dfx    : play ideal noise-free signal
%         - lms    : play noisy speech signal filtered using LMS algorithm
%         - nlms   : play noisy speech signal filtered using NLMS algorithm
%         - rls    : play noisy speech signal filtered using RLS algorithm
%         - fxlms  : play noisy speech signal filtered using FxLMS algorithm
%         - fxnlms : play noisy speech signal filtered using FxNLMS algorithm
%         - fxrls  : play noisy speech signal filtered using FxRLS algorithm
%
% Output:
%	Te   : [6x2] table containing the error for each adaptive filter algorithm

% validate inputs
assert(nargin == 6, 'Invalid number of input arguments. The function requires 6 input arguments.')
assert(isvector(s), 's must be a vector.')
assert(isvector(x), 'x must be a vector.')
assert(length(s) == length(x), 's and x must have the same length.')
assert(isnumeric(L) && isscalar(L) && L > 0, 'L must be a positive scalar.')
assert(isvector(Pw), 'Pw must be a vector.')
assert(isstruct(c), 'config must be a struct.')
assert(ischar(play), 'play must be a string.')
assert(any(strcmpi(play, {'none', 's', 'fx', 'd', 'dfx', 'lms', 'nlms', 'rls', 'fxlms', 'fxnlms', 'fxrls'})), ...
    'play is invalid. It must be one of the following: ''none'', ''s'', ''fx'', ''d'', ''dfx'', ''lms'', ''nlms'', ''rls'', ''fxlms'', ''fxnlms'', or ''fxrls''.')

% initializate parameters
fs = 8000;                 % sample rate
T = length(s);             % number of observations
fx = filter(Pw,1,x);       % filtered noise
d = s+fx;                  % speech + filtered noise d(n)
time = T/fs;               % total time of audio
tv = 0:time/T:time-time/T; % time vector

% define algorithm parameters
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

% algorithms
[yW,eW] = wiener(x, d, L);
[yLMS,eLMS] = lms(x, d, L, mu_LMS);
[yNLMS,eNLMS] = nlms(x, d, L, mu_LMS, delta);
[yRLS,eRLS] = rls(x, d, L, beta, lambda);
[yFxLMS,eFxLMS] = fxlms(x, d, L, mu_FxLMS, Sw, Shw, Shx);
[yFxNLMS,eFxNLMS] = fxnlms(x, d, L, mu_FxLMS, Sw, Shw, Shx, delta);
[yFxRLS,eFxRLS] = fxrls(x, d, L, beta, lambda, Sw, Shw, Shx);

% create table
methods = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
mse = [mean(eW); mean(eLMS); mean(eNLMS); mean(eRLS); mean(eFxLMS); mean(eFxNLMS); mean(eFxRLS)];

% write table
Te = table(methods', mse, 'VariableNames', {'Method', 'Error'});
writetable(Te, fullfile(c.res_path, c.res3));

% play audio
switch lower(play)
    case 'none'
        % do nothing
    case 's'
        sound(s)
    case 'fx'
        sound(fx)
    case 'd'
        sound(d)
    case 'dfx'
        sound(d-fx)
    case 'w'
        sound(d-yW)
    case 'lms'
        sound(d-yLMS)
    case 'nlms'
        sound(d-yNLMS)
    case 'rls'
        sound(d-yRLS)
    case 'fxlms'
        sound(d-yFxLMS)
    case 'fxnlms'
        sound(d-yFxNLMS)
    case 'fxrls'
        sound(d-yFxRLS)
    otherwise
        warning('Invalid play option. No audio played.')
end

% apply moving average filter
maL = 100; % filter length
eW = movmean(eW, maL);
eLMS = movmean(eLMS, maL);
eNLMS = movmean(eNLMS, maL);
eRLS = movmean(eRLS, maL);
eFxLMS = movmean(eFxLMS, maL);
eFxNLMS = movmean(eFxNLMS, maL);
eFxRLS = movmean(eFxRLS, maL);

% plot
fig4 = figure(4);
plot(1:T,10*log10(eW),'k',1:T,10*log10(eLMS),'b',1:T,10*log10(eNLMS),'r',1:T,10*log10(eRLS),'g',...
    1:T,10*log10(eFxLMS),'c',1:T,10*log10(eFxNLMS),'m',1:T,10*log10(eFxRLS),'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Time (s)'); ylabel('MSE (dB)')
fig5 = figure(5);
plot(tv,fx-yW,'k', tv,fx-yLMS,'b',tv,fx-yNLMS,'r',tv,fx-yRLS,'g',...
    tv,fx-yFxLMS,'c',tv,fx-yFxNLMS,'m',tv,fx-yFxRLS,'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Convergence'); xlabel('Time (s)'); ylabel('Error')
fig6 = figure(6);
signals = {s, fx, d, d-yFxRLS};
titles = [{'Speech'},{'Noise'},{'Noisy Speech'},{'Filtered Output'}];
hw = 256; % hamming window size
np = 50;  % amount of overlap
for i = 1:length(signals)
    subplot(length(signals),1,i);
    [S, F, T] = spectrogram(signals{i}, hw, np, [], fs);
    imagesc(T, F, 20*log10(abs(S)));
    set(gca,'YDir','normal');
    title(titles(i)); xlabel('Time (s)'); ylabel('Frequency (Hz)');
end

% save figures
saveas(fig4, fullfile(c.plot_path, c.fig4));
saveas(fig5, fullfile(c.plot_path, c.fig5));
saveas(fig6, fullfile(c.plot_path, c.fig6));
