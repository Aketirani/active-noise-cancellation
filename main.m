% Active Noise Cancelling Using Filtered Adaptive Algorithms
clear, clc, clf % clear
rng('default')  % generate the same random numbers

% Load data
load('../data/speech') % load speech
load('../data/noise')  % load noise
load('../data/bpir')   % load filter

% Initializate parameters
T = 2000;   % iterations
Nexp = 500; % experiments
optpara_mode = false;

% Initialize variables
e = struct();
fields = {'W', 'LMS', 'NLMS', 'RLS', 'FxLMS', 'FxNLMS', 'FxRLS'};
for i = 1:length(fields)
    e.(fields{i}) = zeros(T, Nexp);
end

% Define algorithm parameters
Pw = bpir;      % filter P(z)
L = 10;         % filter length
mu_LMS = 0.05;  % lms step size
mu_NLMS = 0.5;  % nlms step size
delta = 0.01;   % regularization parameter
beta = 0.997;   % forget factor
lambda = 0.1;   % regularization
mu_FxLMS = 0.1; % fxlms step size
mu_FxNLMS = 1;  % fxnlms step size

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

% Compute mean square error for all experiments
mse_w = sum(eW,2)/Nexp;
mse_lms = sum(eLMS,2)/Nexp;
mse_nlms = sum(eNLMS,2)/Nexp;
mse_rls = sum(eRLS,2)/Nexp;
mse_fxlms = sum(eFxLMS,2)/Nexp;
mse_fxnlms = sum(eFxNLMS,2)/Nexp;
mse_fxrls = sum(eFxRLS,2)/Nexp;

% Plot results
figure(1)
plot(1:T,10*log10(mse_lms),'b',1:T,10*log10(mse_nlms),'r',...
     1:T,10*log10(mse_rls),'g',1:T,10*log10(mse_fxlms),'c',...
     1:T,10*log10(mse_fxnlms),'m',1:T,10*log10(mse_fxrls),'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Converge'); xlabel('Iterations'); ylabel('MSE (dB)')
figure(2)
plot(1:T,d-yLMS,'b',1:T,d-yNLMS,'r',1:T,d-yRLS,'g',...
     1:T,d-yFxLMS,'c',1:T,d-yFxNLMS,'m',1:T,d-yFxRLS,'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Converge'); xlabel('Iterations'); ylabel('Error')

if optpara_mode == true
    % Initializate parameters
    L_vec = 8:16; % filter length vector
    alg = 'LMS';  % algorithm
    mu_vec = 0.01:0.01:0.1; % step size vector

    % Optimize Parameters
    [opt_L, opt_mu] = optpara(T, Nexp, L_vec, mu_vec, Pw, alg);
    fprintf('Algorithm %s has optimal filter length L=%d\n', alg, opt_L);
    fprintf('Algorithm %s has optimal step size mu=%.2f\n', alg, opt_mu);
end
