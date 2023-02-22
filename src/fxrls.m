function [yhat, se] = fxrls(x, y, L, beta, lambda, Sw, Shw, Shx)
% Performs the Filtered Recursive Least Squares (FxRLS) algorithm
%
% Inputs:
%   x: [Nx1] input signal
%   y: [Nx1] desired signal
%	L: [1x1] filter length (positive integer)
%	beta: [1x1] forget factor (positive scalar)
%   lambda: [1x1] regularization (positive scalar)
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
assert(beta>0 && beta<1, 'Forget factor must be a scalar between 0 and 1')
assert(lambda>0, 'Regularization must be a positive scalar')

% Set default values for optional inputs
if nargin<6 || isempty(Sw)
    Sw = zeros(L, 1);
end
if nargin<7 || isempty(Shw)
    Shw = zeros(L, 1);
end
if nargin<8 || isempty(Shx)
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
Pn = 1/lambda*eye(L);

% Perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];             % Shift input signal
    Wy(n) = Ww'*Wx;                     % Get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)];   % Get delayed filter output
    Sy(n) = Sw'*Sx;                     % Get filtered reference signal
    Shx = [x(n); Shx(1:L-1)];           % Shift input signal for filtered reference signal
    Shy = [Shw'*Shx; Shy(1:L-1)];       % Get delayed filtered reference signal
    e(n) = y(n)-Sy(n);                  % Calculate error
    zn = Pn*Shy;                        % Update iteration
    Kn = zn/(beta+Shy'*zn);             % Kalman gain
    Pn = beta^-1*Pn-beta^-1*Kn*Shy'*Pn; % Update iteration
    Ww = Ww+Kn*e(n);                    % Update iteration
end

% Set output variables
yhat = Sy; % Filter output
se = e.^2; % Squared error
