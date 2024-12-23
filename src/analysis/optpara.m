function [opt_L, opt_mu] = optpara(T, Nexp, L_vec, mu_vec, Pw, alg, c)
% Finds the optimal filter length and step size
%
% Inputs:
%	T      : [1x1] number of iterations (positive integer)
%	Nexp   : [1x1] number of experiments (positive integer)
%	L_vec  : [1xM] filter length vector (positive integers)
%	mu_vec : [1xN] step size vector (positive scalars)
%   Pw     : [Lx1] impulse response of the system
%   alg    : [char] algorithm type
%   c      : [struct] containing configuration parameters
%
% Outputs:
%	opt_L  : [1x1] optimal filter length for the lowest mean squared error (positive integer)
%	opt_mu : [1x1] optimal step size for the lowest mean squared error (positive integer)

% validate inputs
assert(nargin == 7, 'Invalid number of input arguments. The function requires 7 input arguments.')
assert(isscalar(T) && T>0, 'T should be a positive scalar')
assert(isscalar(Nexp) && Nexp>0, 'Nexp should be a positive scalar')
assert(isvector(L_vec) && all(L_vec > 0) && all(mod(L_vec, 1) == 0), 'L_vec should be a vector of positive integers')
assert(isvector(mu_vec) && all(mu_vec > 0), 'mu_vec should be a vector of positive values')
assert(isstruct(c), 'config must be a struct.')

% initializate parameters
mse_mat = zeros(length(L_vec),length(mu_vec)); % reserve memory
c1 = 1;         % counter 1
c2 = 1;         % counter 2

% define algorithm parameters
delta = 0.01;   % regularization parameter
beta = 0.997;   % forget factor
lambda = 0.1;   % regularization

% compute mean square error for all experiments
for L = L_vec
    for mu = mu_vec
        eLMS = zeros(T,Nexp);    % reserve memory
        for i = 1:Nexp
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
            if strcmpi(alg,'w')
                [~, eLMS(:,i)] = wiener(xn, d, L);
            elseif strcmpi(alg,'lms')
                [~, eLMS(:,i)] = lms(xn, d, L, mu);
            elseif strcmpi(alg,'nlms')
                [~, eLMS(:,i)] = nlms(xn, d, L, mu, delta);
            elseif strcmpi(alg,'rls')
                [~, eLMS(:,i)] = rls(xn, d, L, beta, lambda);
            elseif strcmpi(alg,'fxlms')
                [~, eLMS(:,i)] = fxlms(xn, d, L, mu, Sw, Shw, Shx);
            elseif strcmpi(alg,'fxnlms')
                [~, eLMS(:,i)] = fxnlms(xn, d, L, mu, Sw, Shw, Shx, delta);
            elseif strcmpi(alg,'fxrls')
                [~, eLMS(:,i)] = fxrls(xn, d, L, beta, lambda, Sw, Shw, Shx);
            end
        end
        mse_lms = sum(eLMS,2)/Nexp;
        mse_mat(c2,c1) = mean(mse_lms);
        c1 = c1+1;
    end
    c1 = 1;
    c2 = c2+1;
end

% find the value of the lowest mean square error and its index
[mse_min_v, idx_v] = min(min(mse_mat));

% find the filter belonging to the lowest mean square error and its index
[~, idx_f] = min(mse_mat);
opt_L = L_vec(idx_f(idx_v));
opt_mu = mu_vec(idx_v);

% write table
Te = table({alg}, opt_L, opt_mu, 'VariableNames', {'Algorithm', 'Filter Length', 'Step Size'});
writetable(Te, fullfile(c.res_path, c.res3));

% plot
fig3 = figure(3);
for i = 1:length(L_vec)
    plot(mu_vec,10*log10(mse_mat(i,:))); hold on
end
plot(mu_vec(idx_v),10*log10(mse_min_v),'ro')
hold off
title(alg); xlabel('Step Size'); ylabel('MSE (dB)')
legend([strcat('L=', cellstr(num2str(L_vec'))); 'Optimal'])

% save figure
saveas(fig3, fullfile(c.plot_path, c.fig3));
