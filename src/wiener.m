function [yhat, se] = wiener(x, y, L)
% Performs the Weiner algorithm
%
% Inputs:
%   x: [Nx1] input signal
%   y: [Nx1] desired signal
%	L: [1x1] filter length (positive integer)
%
% Outputs:
%   yhat: [Nx1] filter output
%   se: [Nx1] squared error

% Validate inputs
assert(isvector(x), 'Input x must be a vector.');
assert(isvector(y), 'Input y must be a vector.');
assert(length(x) == length(y), 'Input vectors x and y must be the same length.');
assert(L>0 && L <= length(y), 'Input L must be a positive integer less than or equal to the length of y.');

% Perform algorithm
rxx = xcorr(y,L-1,'biased');   % cross-correlation
R = toeplitz(rxx(L:end));      % toeplitz matrix
rdx = xcorr(x,y,L-1,'biased'); % cross-correlation
w = R\rdx(L:end);              % estimated weights
yhat = filter(w,1,y);          % filters the data
e = y-yhat;                    % calculate error

% Set output variables
se = e.^2; % Squared error
