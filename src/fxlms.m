function [yhat, se] = fxlms(x, y, L, mu, Sw, Shw, Shx)
% Performs the Filtered Least Mean Squares (FxLMS) algorithm
%
% Inputs:
%   x: [Nx1] input signal
%   y: [Nx1] desired signal
%   L: [1x1] filter length (positive integer)
%   mu: [1x1] step size (positive scalar)
%   Sw: [Lx1] weighting coefficients for the reference signal (optional, default=zeros(L,1))
%   Shw: [Lx1] weighting coefficients for the filtered reference signal (optional, default=zeros(L,1))
%   Shx: [Lx1] delayed input signal (optional, default=zeros(L,1))
%
% Outputs:
%   yhat: [Nx1] filter output
%   se: [Nx1] squared error

% Validate inputs
assert(length(x) == length(y), 'Input and desired signals must have the same length')
assert(L>0 && round(L) == L, 'Filter length must be a positive integer')
assert(mu>0, 'Step size must be a positive scalar')

% Set default values for optional inputs
if nargin<5 || isempty(Sw)
    Sw = zeros(L, 1);
end
if nargin<6 || isempty(Shw)
    Shw = zeros(L, 1);
end
if nargin<7 || isempty(Shx)
    Shx = zeros(L, 1);
end

% Initialize variables
Sy = zeros(size(y));
e = zeros(size(y));
Wx = zeros(L,1);
Ww = zeros(L,1);
Wy = zeros(size(y));
Sx = zeros(size(Sw));
Shy = zeros(L,1);

% Perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];           % get xn
    Wy(n) = Ww'*Wx;                   % get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)]; % get yn
    Sy(n) = Sw'*Sx;                   % get filter output
    Shx = [x(n); Shx(1:L-1)];         % get xn
    Shy = [Shw'*Shx; Shy(1:L-1)];     % get filter output
    e(n) = y(n)-Sy(n);                % calculate error
    Ww = Ww+mu*e(n)*Shy;              % update iteration
end

% Set output variables
yhat = Sy; % Filter output
se = e.^2; % Squared error
