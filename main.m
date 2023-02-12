% Main
clear, clc, clf % clear
rng('default')  % generate the same random numbers

% Load filter
load('../data/bpir')

% Initializate parameters
T = 2000;    % iterations
Nexp = 1000; % experiments
L = 10;      % filter length

% Reserve memory
eW = zeros(T,Nexp);
eLMS = zeros(T,Nexp);
eNLMS = zeros(T,Nexp);
eRLS  = zeros(T,Nexp);
eFxLMS = zeros(T,Nexp);
eFxNLMS = zeros(T,Nexp);
eFxRLS  = zeros(T,Nexp);

for i = 1:Nexp
    % Initializate parameters
    xn = randn(T,1);      % white noise
    Pw = bpir;            % filter P(z)
    d = filter(Pw,1,xn);  % filtered white noise d(n)
    
    % LMS on white noise used for filtered algorithms
    Sw = Pw*0.9;          % secondary path weights
    wn = randn(T,1);      % white noise
    yn = filter(Sw,1,wn); % desired signal
    mu_wn = 0.1;          % step size
    [~, ~, Shx, Shw] = lms(wn, yn, L, mu_wn);
    
    % Algorithms
    % Wiener
    [yW, eW(:,i)] = wiener(xn, d, L);
    % LMS
    mu_LMS = 0.05;       % step size
    [yLMS, eLMS(:,i)] = lms(xn, d, L, mu_LMS);
    % NLMS
    mu_NLMS = 0.5;       % step-size
    delta = 0.01;        % regularization parameter
    [yNLMS, eNLMS(:,i)] = nlms(xn, d, L, mu_NLMS, delta);
    % RLS
    beta_RLS = 0.997;    % forget factor
    lambda_RLS = 0.1;    % regularization
    [yRLS, eRLS(:,i)] = rls(xn, d, L, beta_RLS, lambda_RLS);
    % FxLMS
    mu_FxLMS = 0.1;      % step size
    [yFxLMS, eFxLMS(:,i)] = fxlms(xn, d, L, mu_FxLMS, Sw, Shw, Shx);
    % FxNLMS
    mu_FxNLMS = 1;       % step size
    delta = 0.01;        % regularization parameter
    [yFxNLMS, eFxNLMS(:,i)] = fxnlms(xn, d, L, mu_FxNLMS, Sw, Shw, Shx, delta);
    % FxRLS
    beta_FxRLS = 0.997;  % forget factor
    lambda_FxRLS = 0.1;  % regularization
    [yFxRLS, eFxRLS(:,i)] = fxrls(xn, d, L, beta_FxRLS, lambda_FxRLS, Sw, Shw, Shx);
    
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

% Plot
figure(1)
plot(1:T,10*log10(mse_lms),'b',1:T,10*log10(mse_nlms),'r',...
    1:T,10*log10(mse_rls),'g',1:T,10*log10(mse_fxlms),'c',...
    1:T,10*log10(mse_fxnlms),'m',1:T,10*log10(mse_fxrls),'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Converge'); xlabel('iterations'); ylabel('log mse')

figure(2)
plot(1:T,d-yLMS,'b',1:T,d-yNLMS,'r',1:T,d-yRLS,'g',...
    1:T,d-yFxLMS,'c',1:T,d-yFxNLMS,'m',1:T,d-yFxRLS,'y')
legend('LMS','NLMS','RLS','FxLMS','FxNLMS','FxRLS')
title('Converge'); xlabel('iterations'); ylabel('error')