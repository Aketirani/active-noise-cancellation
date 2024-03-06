function p = loadconfig(file)
% Load configuration parameters from a text file.
%
% Inputs:
%	file : Path to the configuration text file (string)
%
% Outputs:
%   p    : Structure containing the loaded configuration parameters
%

% validate input
assert(ischar(file), 'File path must be a string.');

% open the configuration file
fid = fopen(file, 'r');
if fid == -1
    error('Config file not found or unable to open.');
end
% read parameters from the config file
while ~feof(fid)
    line = fgetl(fid);
    % Ignore empty lines or lines starting with '%'
    if isempty(line) || startsWith(strtrim(line), '%')
        continue;
    end
    % Remove inline comments (comments after the parameter value)
    commentIdx = strfind(line, '%');
    if ~isempty(commentIdx)
        line = line(1:commentIdx(1)-1);
    end
    parts = strsplit(line, ':');
    paramName = strtrim(parts{1});
    paramValue = strtrim(parts{2});
    if startsWith(paramValue, '''') && endsWith(paramValue, '''')
        paramValue = paramValue(2:end-1); % remove single quotes
    end
    if startsWith(paramValue, '"') && endsWith(paramValue, '"')
        paramValue = paramValue(2:end-1); % remove double quotes
    end
    if strcmpi(paramValue, 'true') || strcmpi(paramValue, 'false')
        p.(paramName) = strcmpi(paramValue, 'true');
    elseif contains(paramValue, '[') && contains(paramValue, ']')
        paramValue = str2num(paramValue); % convert to numeric array
        p.(paramName) = paramValue;
    elseif isempty(str2num(paramValue))   % check if the value is not numeric
        p.(paramName) = paramValue;
    else
        p.(paramName) = str2double(paramValue);
    end
end
% close the configuration file
fclose(fid);
