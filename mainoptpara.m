% Main
clear, clc, clf % clear
rng('default')  % generate the same random numbers

% Load filter
load('../data/bpir')

% Initializate parameters
T = 2000;     % iterations
Nexp = 1000;  % experiments
c1 = 1;       % counter 1
c2 = 1;       % counter 2
L_vec = 8:16; % filter length vector
mu_vec = 0.01:0.005:0.1; % step size vector
mse_mat = zeros(length(L_vec),length(mu_vec)); % reserve memory

% Compute mean square error for all experiments
for L = L_vec
    for mu_LMS = mu_vec
        eLMS = zeros(T,Nexp);    % reserve memory
        for i = 1:Nexp
            % Initializate parameters
            xn = randn(T,1);     % white noise
            Pw = bpir;           % filter P(z)
            d = filter(Pw,1,xn); % filtered white noise d(n)
            [yLMS, eLMS(:,i)] = lms(xn, d, L, mu_LMS);
        end
        mse_lms = sum(eLMS,2)/Nexp;
        mse_mat(c2,c1) = mean(mse_lms);
        c1 = c1+1;
    end
    c1 = 1;
    c2 = c2+1;
    mprogress(c2/length(L_vec)); % elapsed and remaining time for L
end
% Find the value of the lowest mean square error and its index
[mse_min_v, idx_v] = min(min(mse_mat));

% Find the filter belonging to the lowest mean square error and its index
[mse_min_f, idx_f] = min(mse_mat);
opt_L = L_vec(idx_f(idx_v));

% Plot
figure(1)
for i = 1:length(L_vec)
    plot(mu_vec,10*log10(mse_mat(i,:))); hold on
end
plot(mu_vec(idx_v),10*log10(mse_min_v),'ro')
hold off
title('LMS'); xlabel('step size'); ylabel('log mse')
legend('L=8','L=9','L=10','L=11','L=12','L=13','L=14','L=15','L=16','ME')