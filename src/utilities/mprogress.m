function update = mprogress(n)
% Displays elapsed and remaining time of a for-loop
%
% Input:
%	n      : [0:1] current value of counter
%
% Output:
%	update : [boolean] whether or not the counter was updated

% define persistent variables
persistent m t0 c p tp cwv

% if no update, return false
update = false;

% minimum change in counter before it is displayed
N0 = 0.01;

% minimum time (seconds) between counter is displayed
T0 = 1;

% no arguments: restart the counter
if nargin==0, n = 0; end
if isempty(m), m = inf; end
if isempty(p) || n<m, p = N0; end

% get command window
if isempty(cwv)
    try
        desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
        cw = desktop.getClient('Command Window');
        cwv = cw.getComponent(0).getComponent(0).getComponent(0);
    catch
        cwv = nan;
    end
end

% only display the counter if
% 1) we have taken a step greater then p
% 2) the counter has been restarted
% 3) the counter is at 100%
%  (1)      (2)    (3)
if n-m>p || n<m || n==1
    if n<m % new counter
        t0 = tic;
        tp = [];
        c = '0%';
    else   % already running counter if we have a XCmdWndView object
        if isa(cwv, 'com.mathworks.mde.cmdwin.XCmdWndView')
            s = char(cwv.getText); % get the text in the command window
            i = strfind(s, c);     % find the occurences of the last printed text
            j = strfind(s, 10);    % find occurences of line break
            if ~isempty(i)         % if the text occurs, erase the last occurence
                fprintf('%c',8*ones(j(end)-i(end)+1,1));
                fprintf('%s', s(i(end)+length(c)+1:j(end)));
            end
        else   % if we do not have a XCmdWndView object erase the length of the last printed text
            fprintf('%c',8*ones(length(c)+1*(length(c)>1),1));
        end
        if n<1 % if we are not at 100%
            c = sprintf('%0.f%% (%s) %s', n*100, mtime(toc(t0)), mtime(toc(t0)*(1-n)/n));
        else   % at 100% only display 100% and elapsed time
            c = sprintf('100%% (%s)', mtime(toc(t0)));
        end
    end
    disp(c);           % display counter string
    pause(0); drawnow; % refresh display
    if ~isempty(tp)    % check if the timer has been displayed before
        p = max(T0 * p / toc(tp), N0); % adjust the update rate
    end
    tp = tic;          % remember when the counter was last displayed
    m = n;             % remember the value of the counter that was displayed
    update = true;     % counter has been updated
end

function tstr = mtime(t)
% Format time duration
% Input:
%	t    : time duration in seconds
% Output:
%   tstr : formatted time string

if t<60*60        % minutes and seconds
    tstr = sprintf('%02.f:%02.f', floor(t/60), mod(t,60));
elseif t<60*60*24 % hours, minutes, and seconds
    tstr = sprintf('%02.f:%02.f:%02.f', floor(t/60/60), mod(floor(t/60),60), mod(t,60));
else              % days, hours, minutes, and seconds
    tstr = sprintf('%0.f - %02.f:%02.f:%02.f', floor(t/60/60/24), mod(floor(t/60/60),24), mod(floor(t/60),60), mod(t,60));
end
