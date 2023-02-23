function [yhat, se] = rls(x, y, L, beta, lambda)
% Performs the Filtered Recursive Least Squares (RLS) algorithm
%
% Inputs:
%   x: [Nx1] input signal
%   y: [Nx1] desired signal
%	L: [1x1] filter length (positive integer)
%	beta: [1x1] forget factor (positive scalar)
%   lambda: [1x1] regularization (positive scalar)
%
% Outputs:
%   yhat: [Nx1] filter output
%   se: [Nx1] squared error

% Validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(beta>0 && beta<1, 'Forget factor must be a scalar between 0 and 1')
assert(lambda>0, 'Regularization must be a positive scalar')

% Initialize variables
yhat = zeros(size(y));
e = zeros(size(y));
w = zeros(L,1);
xn = zeros(L,1);
Pn = 1/lambda*eye(L);

% Perform algorithm
for n = 1:length(y)
    xn = [x(n); xn(1:L-1)];      % get xn
    yhat(n) = w'*xn;             % get filter output
    e(n) = y(n)-yhat(n);         % calculate error
    zn = Pn*xn;                  % update iteration
    Kn = zn/(beta+xn'*zn);       % kalman gain, this term may be unstable
    w = w+Kn*e(n);               % update iteration
    Pn = beta^-1*(Pn-Kn*xn'*Pn); % update iteration
end

% Set output variables
se = e.^2; % Squared error
