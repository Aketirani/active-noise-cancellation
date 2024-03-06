% Active Noise Cancellation Using Filtered Adaptive Algorithms
%
% This script implements various ANC algorithms for active noise cancellation.
% It evaluates their performance through simulations and noisy speech processing.
%
% Usage:
%   Execute the script to run simulations and evaluate the ANC algorithms.
%   Adjust the parameters and modes according to specific requirements.
%   Ensure the required data files are available before running the script.

% initializate settings
clear, clc, clf
addpath(genpath('src'));
rng('default')

% read parameters
c = loadconfig('config/config.txt');

% load data
s = load(fullfile(c.data_path, c.data1));  % speech x(n)
x = load(fullfile(c.data_path, c.data2));  % noise
Pw = load(fullfile(c.data_path, c.data3)); % filter P(z)

% initialize parameters
d = 4;                                     % duration of the recording
p = 0;                                     % play the recording
T = 2000;                                  % iterations
N = 200;                                   % experiments
L = 10;                                    % filter length
L_vec = [10, 12, 14, 16];                  % filter length vector
mu_vec = [0.01, 0.03, 0.05, 0.07, 0.09];   % step size vector
alg = 'LMS';                               % algorithm
play = 'none';                             % audio to play

% run record audio
if c.rec_mode == true
    s = recorder(d, c, p);
end

% run simulate adaptive filters
if c.sim_mode == true
    Te = simulation(T, N, L, Pw.bpir, c);
end

% run optimize parameters
if c.optpara_mode == true
    [opt_L, opt_mu] = optpara(T, N, L_vec, mu_vec, Pw.bpir, alg, c);
end

% run noise reduction on noisy speech
if c.ns_mode == true
    Te = noisyspeech(s.speech, x.noise, L, Pw.bpir, c, play);
end
