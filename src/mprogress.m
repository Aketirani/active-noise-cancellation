function update = mprogress(n)
% Displays elapsed and remaining time of a for-loop
%
% Usage:
%    mprogress (with no arguments) resets and displays the counter.
%
%    mprogress(t) where t is a number between 0 and 1 displays/updates the
%    counter at t*100 percent. The counter is only updated if at least 1
%    second has passed and the counter has increased by at least 1
%    percentage point since the last update.
%
% Variables
% n  : Current value of counter (btwn 0 and 1)
% m  : Value of counter at last display
% t0 : Time when counter was started
% c  : Counter string to display
% p  : Step (seconds)
% tp : Time when counter was last displayed
%
% Returns
% update: Boolean, whether or not the counter was updated

persistent m t0 c p tp cwv

% If no update, return false
update = false;

% Minimum change in counter before it is displayed
N0 = .01;

% Minimum time (seconds) between counter is displayed
T0 = 1;

% No arguments: restart the counter
if nargin==0, n = 0; end
if isempty(m), m = inf; end
if isempty(p) || n<m, p = N0; end

% Get command window
if isempty(cwv)
    try
        desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
        cw = desktop.getClient('Command Window');
        cwv = cw.getComponent(0).getComponent(0).getComponent(0);
    catch
        cwv = nan;
    end
end

% Only display the counter if
%  (1)      (2)    (3)
if n-m>p || n<m || n==1
    % 1) we have taken a step greater then p
    % 2) the counter has been restarted
    % 3) the counter is at 100%
    % Update the counter string
    if n<m % New counter
        t0 = tic;
        tp = [];
        c = '0%';
    else % Already running counter
        % If we have a XCmdWndView object
        if isa(cwv, 'com.mathworks.mde.cmdwin.XCmdWndView')
            % Get the text in the command window
            s = char(cwv.getText);
            % Find the occurences of the last printed text
            i = strfind(s, c);
            % Find occurences of line break
            j = strfind(s, 10);
            % If the text occurs, erase the last occurence
            if ~isempty(i)
                fprintf('%c',8*ones(j(end)-i(end)+1,1));
                fprintf('%s', s(i(end)+length(c)+1:j(end)));
            end
        else % If we do not have a XCmdWndView object
            % Erase the length of the last printed text
            fprintf('%c',8*ones(length(c)+1*(length(c)>1),1));
        end
        % If we are not at 100%
        if n<1
            c = sprintf('%0.f%% (%s) %s', ...
                n*100, mtime(toc(t0)), mtime(toc(t0)*(1-n)/n));
        else % At 100% only display 100% and elapsed time
            c = sprintf('100%% (%s)', mtime(toc(t0)));
        end
    end
    % Display counter string
    disp(c);
    % Refresh display
    pause(0); drawnow;
    % If timer has been displayed before, set p to make next
    % update in T0 sec and counter has incresed more than N0
    if ~isempty(tp), p = max(T0*p/toc(tp), N0); end
    % Remember when the counter was last displayed
    tp = tic;
    % Remember the value of the counter that was displayed
    m = n;
    % Counter has been updated
    update = true;
end

function tstr = mtime(t)
if t<60*60
    tstr = sprintf('%02.f:%02.f', floor(t/60), mod(t,60));
elseif t<60*60*24
    tstr = sprintf('%02.f:%02.f:%02.f', floor(t/60/60), mod(floor(t/60),60), mod(t,60));
else
    tstr = sprintf('%0.f - %02.f:%02.f:%02.f', floor(t/60/60/24), mod(floor(t/60/60),24), mod(floor(t/60),60), mod(t,60));
end
