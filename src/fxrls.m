function [yhat, se] = fxrls(x, y, L, beta, lam, Sw, Shw, Shx)
% Performs the Filtered Recursive Least Squares (FxRLS) algorithm
%
% Inputs:
%   x    : [Nx1] input signal
%   y    : [Nx1] desired signal
%	L    : [1x1] filter length (positive integer)
%	beta : [1x1] forget factor (positive scalar)
%   lam  : [1x1] regularization (positive scalar)
%   Sw   : [Lx1] weighting coefficients for the reference signal (optional, default=zeros(L,1))
%   Shw  : [Lx1] weighting coefficients for the filtered reference signal (optional, default=zeros(L,1))
%   Shx  : [Lx1] delayed input signal (optional, default=zeros(L,1))
%
% Outputs:
%   yhat : [Nx1] filter output
%   se   : [Nx1] squared error

% validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(beta>0 && beta<1, 'Forget factor must be a scalar between 0 and 1')
assert(lam>0, 'Regularization must be a positive scalar')

% set default values for optional inputs
if nargin<6 || isempty(Sw)
    Sw = zeros(L, 1);
end
if nargin<7 || isempty(Shw)
    Shw = zeros(L, 1);
end
if nargin<8 || isempty(Shx)
    Shx = zeros(L, 1);
end

% initialize variables
Sy = zeros(size(y));
e = zeros(size(y));
Wx = zeros(L,1);
Ww = zeros(L,1);
Wy = zeros(size(y));
Sx = zeros(size(Sw));
Shy = zeros(L,1);
Pn = 1/lam*eye(L);

% perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];             % shift input signal
    Wy(n) = Ww'*Wx;                     % get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)];   % get delayed filter output
    Sy(n) = Sw'*Sx;                     % get filtered reference signal
    Shx = [x(n); Shx(1:L-1)];           % shift input signal for filtered reference signal
    Shy = [Shw'*Shx; Shy(1:L-1)];       % get delayed filtered reference signal
    e(n) = y(n)-Sy(n);                  % calculate error
    zn = Pn*Shy;                        % update iteration
    Kn = zn/(beta+Shy'*zn);             % kalman gain
    Pn = beta^-1*Pn-beta^-1*Kn*Shy'*Pn; % update iteration
    Ww = Ww+Kn*e(n);                    % update iteration
end

% calculate output variables
yhat = Sy; % filter output
se = e.^2; % squared error
