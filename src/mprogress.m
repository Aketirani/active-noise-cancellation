function update = mprogress(n)
% Displays elapsed and remaining time of a for-loop
%
% Usage:
%	mprogress (with no arguments) resets and displays the counter.
%   mprogress(t) for t in [0,1] updates at t*100% if 1 sec passed & increased >= 1% since last update.
%
% Variables:
%	n  : Current value of counter (between 0 and 1)
%	m  : Value of counter at last display
%	t0 : Time when counter was started
%	c  : Counter string to display
%	p  : Step (seconds)
%	tp : Time when counter was last displayed
%
% Returns:
%	update: Boolean, whether or not the counter was updated

% define persistent variables
persistent m t0 c p tp cwv

% if no update, return false
update = false;

% minimum change in counter before it is displayed
N0 = .01;

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
    % update the counter string
    if n<m % new counter
        t0 = tic;
        tp = [];
        c = '0%';
    else % already running counter
        % if we have a XCmdWndView object
        if isa(cwv, 'com.mathworks.mde.cmdwin.XCmdWndView')
            % get the text in the command window
            s = char(cwv.getText);
            % find the occurences of the last printed text
            i = strfind(s, c);
            % find occurences of line break
            j = strfind(s, 10);
            % if the text occurs, erase the last occurence
            if ~isempty(i)
                fprintf('%c',8*ones(j(end)-i(end)+1,1));
                fprintf('%s', s(i(end)+length(c)+1:j(end)));
            end
        else % if we do not have a XCmdWndView object
            % erase the length of the last printed text
            fprintf('%c',8*ones(length(c)+1*(length(c)>1),1));
        end
        % if we are not at 100%
        if n<1
            c = sprintf('%0.f%% (%s) %s', ...
                n*100, mtime(toc(t0)), mtime(toc(t0)*(1-n)/n));
        else % at 100% only display 100% and elapsed time
            c = sprintf('100%% (%s)', mtime(toc(t0)));
        end
    end
    % display counter string
    disp(c);
    % refresh display
    pause(0); drawnow;
    % if timer has been displayed before, set p to make next
    % update in T0 sec and counter has incresed more than N0
    if ~isempty(tp), p = max(T0*p/toc(tp), N0); end
    % remember when the counter was last displayed
    tp = tic;
    % remember the value of the counter that was displayed
    m = n;
    % counter has been updated
    update = true;
end

% format time duration in hours, minutes, and seconds
function tstr = mtime(t)
if t<60*60
    tstr = sprintf('%02.f:%02.f', floor(t/60), mod(t,60));
elseif t<60*60*24
    tstr = sprintf('%02.f:%02.f:%02.f', floor(t/60/60), mod(floor(t/60),60), mod(t,60));
else
    tstr = sprintf('%0.f - %02.f:%02.f:%02.f', floor(t/60/60/24), mod(floor(t/60/60),24), mod(floor(t/60),60), mod(t,60));
end
