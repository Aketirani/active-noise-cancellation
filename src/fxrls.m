function [yhat, se] = fxrls(x, y, L, beta, lambda, Sw, Shw, Shx)
% Filtered Recursive Least Squares
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
Sy = zeros(size(y));
e = zeros(size(y));
Wx = zeros(L,1);
Ww = zeros(L,1);
Wy = zeros(size(y));
Sx = zeros(size(Sw));
Shy = zeros(L,1);
Pn = 1/lambda*eye(L);

% perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];             % get xn
    Wy(n) = Ww'*Wx;                     % get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)];   % get yn
    Sy(n) = Sw'*Sx;                     % get filter output
    Shx = [x(n); Shx(1:L-1)];           % get xn
    Shy = [Shw'*Shx; Shy(1:L-1)];       % get filter output
    e(n) = y(n)-Sy(n);                  % calculate error
    zn = Pn*Shy;                        % update iteration
    Kn = zn/(beta+Shy'*zn);             % kalman gain, this term may be unstable
    Pn = beta^-1*Pn-beta^-1*Kn*Shy'*Pn; % update iteration
    Ww = Ww+Kn*e(n);                    % update iteration
end
yhat = Sy; % filter output
se = e.^2; % squared error