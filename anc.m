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
clear, clc, clf          % clear
addpath(genpath('src')); % add src path
rng('default')           % generate the same random numbers

% set modes
rec_mode = false;        % recorder mode
sim_mode = true;         % simulation mode
optpara_mode = true;     % optimize parameters mode
ns_mode = true;          % noisy speech mode

% set plots
plot_save = true;        % save the plots
plot_path = 'plots/';    % path of the plots

% load data
load('data/speech')      % load speech
load('data/noise')       % load noise
load('data/bpir')        % load filter
s = speech;              % speech x(n)
x = noise;               % noise
Pw = bpir;               % filter P(z)

% initializate parameters
d = 4;                   % duration of the recording
r = 'data/rec.mat';      % name of the recording
p = 0;                   % play the recording
T = 2000;                % iterations
Nexp = 200;              % experiments
L = 10;                  % filter length
L_vec = 8:2:14;          % filter length vector
mu_vec = 0.01:0.02:0.1;  % step size vector
alg = 'LMS';             % algorithm
play = 'none';           % audio to play

% run record audio
if rec_mode == true
    s = recorder(d, r, p);
end

% run simulate adaptive filters
if sim_mode == true
    Te = simulation(T, Nexp, L, Pw, plot_save, plot_path);
end

% run optimize parameters
if optpara_mode == true
    [opt_L, opt_mu] = optpara(T, Nexp, L_vec, mu_vec, Pw, alg, plot_save, plot_path);
end

% run noise reduction on noisy speech
if ns_mode == true
    Te = noisyspeech(s, x, L, Pw, play, plot_save, plot_path);
end
