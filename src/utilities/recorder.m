function s = recorder(d, r, p)
% Record audio and save it to a file
%
% Inputs:
%   d : [1x1] duration of recording in seconds
%   r : string specifying the file path and name for the audio
%   p : [0 or 1] whether to play the recorded audio
%
% Outputs:
%   s : recorded audio data

% validate inputs
assert(isnumeric(d) && isscalar(d) && d > 0, 'dur must be a positive scalar.');
assert(ischar(r) && ~isempty(r), 'name must be a non-empty string.');
assert(isscalar(p) && (p == 0 || p == 1), 'play must be 0 or 1.');

% initializate parameters
fs = 8000; % sample rate
bits = 16; % bits per sample
mono = 1;  % audio channels
recObj = audiorecorder(fs, bits, mono);

% record
disp('Recording Started...');
recordblocking(recObj, d);
disp('Recording Finished.');

% save recording
s = getaudiodata(recObj);
save(r, 's');

% play recording
if p == 1
    sound(s, fs);
end