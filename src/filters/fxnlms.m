function [yhat, se] = fxnlms(x, y, L, mu, Sw, Shw, Shx, delta)
% Performs the Filtered Normalized Least Mean Squares (FxNLMS) algorithm
%
% Inputs:
%   x    : [Nx1] input signal
%   y    : [Nx1] desired signal
%   L    : [1x1] filter length (positive integer)
%   mu   : [1x1] step size (positive scalar)
%   Sw   : [Lx1] weighting coefficients for the reference signal (optional, default=zeros(L,1))
%   Shw  : [Lx1] weighting coefficients for the filtered reference signal (optional, default=zeros(L,1))
%   Shx  : [Lx1] delayed input signal (optional, default=zeros(L,1))
%   delta: [1x1] small stability value
%
% Outputs:
%   yhat : [Nx1] filter output
%   se   : [Nx1] squared error

% validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(mu>0, 'Step size must be a positive scalar')

% set default values for optional inputs
if nargin<5 || isempty(Sw)
    Sw = zeros(L, 1);
end
if nargin<6 || isempty(Shw)
    Shw = zeros(L, 1);
end
if nargin<7 || isempty(Shx)
    Shx = zeros(L, 1);
end
if nargin<8 || isempty(delta)
    delta = 0.01;
end

% initialize variables
Sy = zeros(size(y));
e = zeros(size(y));
Wx = zeros(L,1);
Ww = zeros(L,1);
Wy = zeros(size(y));
Sx = zeros(size(Sw));
Shy = zeros(L,1);

% perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];           % shift input signal
    Wy(n) = Ww' * Wx;                 % get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)]; % get filtered reference signal
    Sy(n) = Sw' * Sx;                 % get filter output
    Shx = [x(n); Shx(1:L-1)];         % shift input signal
    Shy = [Shw' * Shx; Shy(1:L-1)];   % get filtered reference signal
    e(n) = y(n) - Sy(n);              % calculate error
    umu = mu / (delta + Wx' * Wx);    % update mu
    Ww = Ww + umu * e(n) * Shy;       % update weights
end

% calculate output variables
yhat = Sy; % filter output
se = e.^2; % squared error
