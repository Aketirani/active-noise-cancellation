function [yhat, se] = fxnlms(x, y, L, mu, Sw, Shw, Shx, delta)
% Filtered Normalized Least Mean Squares
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
%     mse: squared error

% reserve memory
Sy = zeros(size(y));
e = zeros(size(y));
Wx = zeros(L,1);
Ww = zeros(L,1);
Wy = zeros(size(y));
Sx = zeros(size(Sw));
Shy = zeros(L,1);

% perform algorithm
for n = 1:length(y)
    Wx = [x(n); Wx(1:L-1)];           % get xn
    Wy(n) = Ww'*Wx;                   % get filter output
    Sx = [Wy(n); Sx(1:length(Sx)-1)]; % get yn
    Sy(n) = Sw'*Sx;                   % get filter output
    Shx = [x(n); Shx(1:L-1)];         % get xn
    Shy = [Shw'*Shx; Shy(1:L-1)];     % get filter output
    e(n) = y(n)-Sy(n);                % calculate error
    umu = mu/(delta+Wx'*Wx);          % update mu
    Ww = Ww+umu*e(n)*Shy;             % update iteration
end
yhat = Sy; % filter output
se = e.^2; % squared error