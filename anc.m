% Main script
clear, clc, clf      % clear
addpath('src');      % add path
rng('default')       % generate the same random numbers

% Load data
load('data/speech')  % load speech
load('data/noise')   % load noise
load('data/bpir')    % load filter
s = speech;          % speech x(n)
x = noise;           % noise
Pw = bpir;           % filter P(z)

% Modes
sim_mode = true;     % simulation mode
optpara_mode = true; % optimize parameters mode
ns_mode = true;      % noisy speech demo

% Plot save
plot_save = true;
plot_path = 'plots/';

% Initializate parameters
T = 2000;            % iterations
Nexp = 500;          % experiments
L = 10;              % filter length

% Run simulate adaptive filters
if sim_mode == true
    Te = simulation(T, Nexp, L, Pw, plot_save, plot_path);
end

% Run optimize parameters
if optpara_mode == true
    L_vec = 8:16;           % filter length vector
    mu_vec = 0.01:0.01:0.1; % step size vector
    alg = 'LMS';            % algorithm
    
    % Optimize Parameters
    [opt_L, opt_mu] = optpara(T, Nexp, L_vec, mu_vec, Pw, alg, plot_save, plot_path);
end

% Run noise reduction on noisy speech
if ns_mode == true
    play = 'none';          % audio to play
    Te = noisyspeech(s, x, L, Pw, play, plot_save, plot_path);
end
