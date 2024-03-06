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
pc = loadconfig('config.txt');

% load data
s = load(pc.speech_path);  % speech x(n)
x = load(pc.noise_path);   % noise
Pw = load(pc.filter_path); % filter P(z)

% run record audio
if pc.rec_mode == true
    s = recorder(pc.d, pc.r, pc.p);
end

% run simulate adaptive filters
if pc.sim_mode == true
    Te = simulation(pc.T, pc.N, pc.L, Pw.bpir, pc.res_path, pc.plot_path);
end

% run optimize parameters
if pc.optpara_mode == true
    [opt_L, opt_mu] = optpara(pc.T, pc.N, pc.L_vec, pc.mu_vec, Pw.bpir, pc.alg, pc.res_path, pc.plot_path);
end

% run noise reduction on noisy speech
if pc.ns_mode == true
    Te = noisyspeech(s.speech, x.noise, pc.L, Pw.bpir, pc.play, pc.res_path, pc.plot_path);
end
