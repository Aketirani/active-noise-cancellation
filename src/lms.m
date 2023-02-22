function [yhat, se, w, xn] = lms(x, y, L, mu)
% Performs the Least Mean Squares (LMS) algorithm
%
% Inputs:
%   x: [Nx1] input signal
%	y: [Nx1] desired signal
%	L: [1x1] filter length (positive integer)
%	mu: [1x1] step size (positive scalar)
%
% Outputs:
%	yhat: [Nx1] filter output
%	se: [Nx1] squared error
%   w: [Lx1] weighting coefficients for the filtered reference signal
%   xn: [Lx1] delayed input signal

% Validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(mu>0, 'Step size must be a positive scalar')

% Initialize variables
yhat = zeros(size(y));
e = zeros(size(y));
w = zeros(L,1);
xn = zeros(L,1);

% Perform algorithm
for n = 1:length(y)
    xn = [x(n); xn(1:L-1)]; % get xn
    yhat(n) = w'*xn;        % get filter output
    e(n) = y(n)-yhat(n);    % calculate error
    w = w+mu*e(n)*xn;       % update iteration
end

% Set output variables
se = e.^2; % Squared error
