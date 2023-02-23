function Te = simulation(T, Nexp, L, Pw, plot_save, plot_path)
% Simulates adaptive filters and evaluate their performance
%
% Inputs:
%	T: the number of iterations (positive integer)
%	Nexp: the number of experiments (positive integer)
%   Pw: [Lx1] impulse response of the system
%	L: [1x1] filter length (positive integer)
%   plot_save: save the figure into a png if set to true (logical)
%   plot_path: path to save the figure (string)
%
% Outputs:
%	Te: [7x2] table containing the error for each adaptive filter algorithm

% Check inputs
assert(nargin == 6, 'Invalid number of input arguments. The function requires 6 input arguments.')
assert(isnumeric(T) && isscalar(T) && T > 0, 'T must be a positive scalar.')
assert(isnumeric(Nexp) && isscalar(Nexp) && Nexp > 0, 'Nexp must be a positive scalar.')
assert(isnumeric(L) && isscalar(L) && L > 0, 'L must be a positive scalar.')
assert(isvector(Pw), 'Pw must be a vector.')
assert(islogical(plot_save), 'plot_save must be a boolean value.');
assert(ischar(plot_path), 'play must be a string.')

% Initialize variables
e = struct();
fields = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
for i = 1:length(fields)
    e.(fields{i}) = zeros(T, Nexp);
end

% Define algorithm parameters
mu_LMS = 0.05;  % lms step size
mu_NLMS = 0.5;  % nlms step size
delta = 0.01;   % regularization parameter
beta = 0.997;   % forget factor
lambda = 0.1;   % regularization
mu_FxLMS = 0.1; % fxlms step size
mu_FxNLMS = 1;  % fxnlms step size

% Compute mean square error for all experiments
for i = 1:Nexp
    % Initializate parameters
    xn = randn(T,1);      % white noise
    d = filter(Pw,1,xn);  % filtered white noise d(n)

    % LMS on white noise used for filtered algorithms
    Sw = Pw*0.9;          % secondary path weights
    wn = randn(T,1);      % white noise
    yn = filter(Sw,1,wn); % desired signal
    mu_wn = 0.1;          % step size
    [~, ~, Shw, Shx] = lms(wn, yn, L, mu_wn);

    % Algorithms
    [yW, eW(:,i)] = wiener(xn, d, L);
    [yLMS, eLMS(:,i)] = lms(xn, d, L, mu_LMS);
    [yNLMS, eNLMS(:,i)] = nlms(xn, d, L, mu_NLMS, delta);
    [yRLS, eRLS(:,i)] = rls(xn, d, L, beta, lambda);
    [yFxLMS, eFxLMS(:,i)] = fxlms(xn, d, L, mu_FxLMS, Sw, Shw, Shx);
    [yFxNLMS, eFxNLMS(:,i)] = fxnlms(xn, d, L, mu_FxNLMS, Sw, Shw, Shx, delta);
    [yFxRLS, eFxRLS(:,i)] = fxrls(xn, d, L, beta, lambda, Sw, Shw, Shx);

    mprogress(i/Nexp);   % elapsed and remaining time
end

% Compute average mean square error for all experiments
mse_w = sum(eW,2)/Nexp;
mse_lms = sum(eLMS,2)/Nexp;
mse_nlms = sum(eNLMS,2)/Nexp;
mse_rls = sum(eRLS,2)/Nexp;
mse_fxlms = sum(eFxLMS,2)/Nexp;
mse_fxnlms = sum(eFxNLMS,2)/Nexp;
mse_fxrls = sum(eFxRLS,2)/Nexp;

% Create table
methods = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
mse = [mse_w(end); mse_lms(end); mse_nlms(end); mse_rls(end); mse_fxlms(end); mse_fxnlms(end); mse_fxrls(end)];
Te = table(methods', mse, 'VariableNames', {'Method', 'Error'});

% Plot results
figure(1)
plot(1:T,10*log10(mse_w),'k',1:T,10*log10(mse_lms),'b',1:T,10*log10(mse_nlms),'r',1:T,10*log10(mse_rls),'g',...
    1:T,10*log10(mse_fxlms),'c',1:T,10*log10(mse_fxnlms),'m',1:T,10*log10(mse_fxrls),'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Performance'); xlabel('Iterations'); ylabel('MSE (dB)')
figure(2)
plot(1:T,d-yW,'k',1:T,d-yLMS,'b',1:T,d-yNLMS,'r',1:T,d-yRLS,'g',...
    1:T,d-yFxLMS,'c',1:T,d-yFxNLMS,'m',1:T,d-yFxRLS,'y')
legend('W','LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Convergence'); xlabel('Iterations'); ylabel('Error')

% Save figures to plot_path
if plot_save == true
    saveas(figure(1), [plot_path 'PerformanceSIM.png']);
    saveas(figure(2), [plot_path 'ConvergenceSIM.png']);
end
