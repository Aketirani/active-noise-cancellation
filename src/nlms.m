function [yhat, se] = nlms(x, y, L, mu, delta)
% Performs the Normalized Least Mean Squares (NLMS) algorithm
%
% Inputs:
%	x    : [Nx1] input signal
%	y    : [Nx1] desired signal
%	L    : [1x1] filter length (positive integer)
%	mu   : [1x1] step size (positive scalar)
%	delta: [1x1] small stability value
%
% Outputs:
%	yhat : [Nx1] filter output
%	se   : [Nx1] squared error

% validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(mu>0, 'Step size must be a positive scalar')
assert(delta>0, 'Stability value delta must be a positive scalar')

% initialize variables
yhat = zeros(size(y));
e = zeros(size(y));
w = zeros(L,1);
xn = zeros(L,1);

% perform algorithm
for n = 1:length(y)
    xn = [x(n); xn(1:L-1)];  % get xn
    yhat(n) = w'*xn;         % get filter output
    e(n) = y(n)-yhat(n);     % calculate error
    umu = mu/(delta+xn'*xn); % calculate normalized step size
    w = w+umu*xn*e(n);       % update iteration
end

% set output variables
se = e.^2; % squared error
