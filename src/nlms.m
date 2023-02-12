function [yhat, se] = nlms(x, y, L, mu, delta)
% Normalized Least Mean Squares
%
% Input
%     x: input signal
%     y: desired signal
%     L: filter length
%     mu: step size
%     delta: small stability value
%
% Output
%     yhat: filter output
%     se: squared error

% reserve memory
yhat = zeros(size(y));
e = zeros(size(y));
w = zeros(L,1);
xn = zeros(L,1);

% perform algorithm
for n = 1:length(y)
    xn = [x(n); xn(1:L-1)];  % get xn
    yhat(n) = w'*xn;         % get filter output
    e(n) = y(n)-yhat(n);     % calculate error
    umu = mu/(delta+xn'*xn); % update mu
    w = w+umu*xn*e(n);       % update iteration
end
se = e.^2; % squared error