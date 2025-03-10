function rec = recorder(d, c, p)
% Record audio and save it to a file
%
% Inputs:
%   d : [1x1] recording duration in seconds
%   c : [struct] containing configuration parameters
%   p : [0,1] whether to play the recorded audio
%
% Output:
%   rec : [Nx1] recorded audio data

% validate inputs
assert(isnumeric(d) && isscalar(d) && d > 0, 'duration must be a positive scalar.');
assert(isstruct(c), 'config must be a struct.')
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
rec = getaudiodata(recObj);
save(fullfile(c.data_path, c.data4), 'rec');

% play recording
if p == 1
    sound(rec, fs);
end
