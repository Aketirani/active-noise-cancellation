% Main application
%
% Usage:
%   Execute the script to run simulations and evaluate the ANC algorithms
%   Adjust the parameters and modes according to specific requirements
%   Ensure the required data files are available before running the script

% initializate settings
clear, clc
addpath(genpath('src'));
rng('default')

% run application
app = gui;
