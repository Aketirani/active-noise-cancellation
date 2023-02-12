function [yhat, se] = rls(x, y, L, beta, lambda)
% Recursive Least Squares
%
% Input
%     x: input signal
%     y: desired signal
%     L: filter length
%     beta: forget factor
%     lambda: regularization
%
% Output
%     yhat: filter output
%     se: squared error

% reserve memory
yhat = zeros(size(y));
e = zeros(size(y));
w = zeros(L,1);
xn = zeros(L,1);
Pn = 1/lambda*eye(L);

% perform algorithm
for n = 1:length(y)
    xn = [x(n); xn(1:L-1)];            % get xn
    yhat(n) = w'*xn;                   % get filter output
    e(n) = y(n)-yhat(n);               % calculate error
    zn = Pn*xn;                        % update iteration
    Kn = zn/(beta+xn'*zn);             % kalman gain, this term may be unstable 
    Pn = beta^-1*Pn-beta^-1*Kn*xn'*Pn; % update iteration
    w = w+Kn*e(n);                     % update iteration
end
se = e.^2; % squared error