function [yhat, mse] = wiener(x, y, L)
% Wiener
%
% Input
%     x: input signal
%     y: desired signal
%     L: filter length
%
% Output
%     yhat: filter output
%     mse: mean squared error

rxx = xcorr(y,L-1,'biased');   % cross-correlation
R = toeplitz(rxx(L:end));      % toeplitz matrix
rdx = xcorr(x,y,L-1,'biased'); % cross-correlation
w = R\rdx(L:end);              % estimated weights
yhat = filter(w,1,y);          % filters the data
e = y-yhat;                    % calculate error
mse = mean(e.^2);              % mean square error