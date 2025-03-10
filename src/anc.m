function anc(rec_mode, sim_mode, optpara_mode, ns_mode)
% Active noise cancellation using filtered adaptive algorithms
%
% Inputs:
%   - rec_mode     : [boolean] indicating whether to record audio
%   - sim_mode     : [boolean] indicating whether to simulate filters
%   - optpara_mode : [boolean] indicating whether to optimize parameters
%   - ns_mode      : [boolean] indicating whether to perform noise reduction on noisy speech

try
    % read config
    c = loadconfig('config/config.txt');

    % create log file
    log_name = [c.log_path, c.log1, datestr(datetime('now'), c.log2), c.log3];
    log_file = fopen(log_name, 'w');
    fprintf(log_file, 'Application Started On %s \n', datestr(datetime('now')));

    % load data
    fprintf(log_file, 'Loading Data...\n');
    s = load(fullfile(c.data_path, c.data1));  % speech
    x = load(fullfile(c.data_path, c.data2));  % noise
    Pw = load(fullfile(c.data_path, c.data3)); % filter
    r = load(fullfile(c.data_path, c.data4));  % recording

    % initialize parameters
    fprintf(log_file, 'Initializing Parameters...\n');
    d = 4;                                     % recording duration
    p = 0;                                     % play recorded audio
    T = 2000;                                  % number of iterations
    N = 200;                                   % number of experiments
    L = 10;                                    % filter length
    L_vec = [10, 12, 14, 16];                  % filter length vector
    mu_vec = [0.01, 0.03, 0.05, 0.07, 0.09];   % step size vector
    alg = 'LMS';                               % algorithm type
    play = 'none';                             % audio to play
    src = s.speech;                            % speech signal (switch to 'r.rec' for recorded audio)

    % run record audio
    if rec_mode == true
        fprintf(log_file, 'Running Record Audio...\n');
        r = recorder(d, c, p);
    end

    % run simulate adaptive filters
    if sim_mode == true
        fprintf(log_file, 'Running Simulate Adaptive Filters...\n');
        Te = simulation(T, N, L, Pw.bpir, c);
    end

    % run optimize parameters
    if optpara_mode == true
        fprintf(log_file, 'Running Optimize Parameters...\n');
        [opt_L, opt_mu] = optpara(T, N, L_vec, mu_vec, Pw.bpir, alg, c);
    end

    % run noise reduction on noisy speech or recording
    if ns_mode == true
        fprintf(log_file, 'Running Noise Reduction On Noisy Speech...\n');
        Te = noisyspeech(src, x.noise, L, Pw.bpir, c, play);
    end

    % close log file
    fprintf(log_file, 'Application Finished On %s \n', datestr(datetime('now')));
    fclose(log_file);
catch ME
    if exist('log_file', 'var')
        fprintf(log_file, 'Error: %s\n', ME.message);
        fclose(log_file);
    end
    rethrow(ME);
end
