function Te = simulation(T, N, L, Pw, c)
% Simulates adaptive filters and evaluate their performance
%
% Inputs:
%	T  : [1x1] number of iterations (positive integer)
%	N  : [1x1] number of experiments (positive integer)
%   Pw : [Lx1] impulse response of the system
%	L  : [1x1] filter length (positive integer)
%   c  : [struct] containing configuration parameters
%
% Output:
%	Te : [5x2] table containing the error for each adaptive filter algorithm

% check inputs
assert(nargin == 5, 'Invalid number of input arguments. The function requires 5 input arguments.')
assert(isnumeric(T) && isscalar(T) && T > 0, 'T must be a positive scalar.')
assert(isnumeric(N) && isscalar(N) && N > 0, 'N must be a positive scalar.')
assert(isnumeric(L) && isscalar(L) && L > 0, 'L must be a positive scalar.')
assert(isvector(Pw), 'Pw must be a vector.')
assert(isstruct(c), 'config must be a struct.')

% initialize variables
e = struct();
fields = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
for i = 1:length(fields)
    e.(fields{i}) = zeros(T, N);
end

% define algorithm parameters
mu_LMS = 0.05;  % lms step size
mu_NLMS = 0.5;  % nlms step size
delta = 0.01;   % regularization parameter
beta = 0.997;   % forget factor
lambda = 0.1;   % regularization
mu_FxLMS = 0.1; % fxlms step size
mu_FxNLMS = 1;  % fxnlms step size

% compute mean square error for all experiments
for i = 1:N
    % initializate parameters
    xn = randn(T,1);      % white noise x(n)
    d = filter(Pw,1,xn);  % filtered white noise d(n)

    % LMS on white noise used for filtered algorithms
    Sw = Pw*0.9;          % secondary path weights
    wn = randn(T,1);      % white noise
    yn = filter(Sw,1,wn); % desired signal
    mu_wn = 0.1;          % step size
    [~, ~, Shw, Shx] = lms(wn, yn, L, mu_wn);

    % algorithms
    [yW, eW(:,i)] = wiener(xn, d, L);
    [yLMS, eLMS(:,i)] = lms(xn, d, L, mu_LMS);
    [yNLMS, eNLMS(:,i)] = nlms(xn, d, L, mu_NLMS, delta);
    [yRLS, eRLS(:,i)] = rls(xn, d, L, beta, lambda);
    [yFxLMS, eFxLMS(:,i)] = fxlms(xn, d, L, mu_FxLMS, Sw, Shw, Shx);
    [yFxNLMS, eFxNLMS(:,i)] = fxnlms(xn, d, L, mu_FxNLMS, Sw, Shw, Shx, delta);
    [yFxRLS, eFxRLS(:,i)] = fxrls(xn, d, L, beta, lambda, Sw, Shw, Shx);
end

% compute average mean square error for all experiments
mse_w = sum(eW,2)/N;
mse_lms = sum(eLMS,2)/N;
mse_nlms = sum(eNLMS,2)/N;
mse_rls = sum(eRLS,2)/N;
mse_fxlms = sum(eFxLMS,2)/N;
mse_fxnlms = sum(eFxNLMS,2)/N;
mse_fxrls = sum(eFxRLS,2)/N;

% create table
methods = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
mse = [mse_w(end); mse_lms(end); mse_nlms(end); mse_rls(end); mse_fxlms(end); mse_fxnlms(end); mse_fxrls(end)];

% write table
Te = table(methods', mse, 'VariableNames', {'Method', 'Error'});
writetable(Te, fullfile(c.res_path, c.res1));

% plot
fig1 = figure(1);
plot(1:T,10*log10(mse_w),'k',1:T,10*log10(mse_lms),'b',1:T,10*log10(mse_nlms),'r',1:T,10*log10(mse_rls),'g',...
    1:T,10*log10(mse_fxlms),'c',1:T,10*log10(mse_fxnlms),'m',1:T,10*log10(mse_fxrls),'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Iterations'); ylabel('MSE (dB)')
fig2 = figure(2);
plot(1:T,d-yW,'k',1:T,d-yLMS,'b',1:T,d-yNLMS,'r',1:T,d-yRLS,'g',...
    1:T,d-yFxLMS,'c',1:T,d-yFxNLMS,'m',1:T,d-yFxRLS,'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Convergence'); xlabel('Iterations'); ylabel('Error')

% save figures
saveas(fig1, fullfile(c.plot_path, c.fig1));
saveas(fig2, fullfile(c.plot_path, c.fig2));
