%% Results
% Cpp_time = 0.0887
% Matlab_time = 27.1121
% Matlab_time/Cpp_time = 305.6020

% for even better performance
%mex -v COPTIMFLAGS='-O3 -fwrapv -DNDEBUG'  probability_OK_cpp.cpp
%% Pre-run.
clear all; close all;
warning('off','all')  % Do not display ployshape warnings.

lambda = 0.001;
Lmax = 20;
theta = linspace(0, pi, 100);

N_grid = 100;
r = 50;
x1 = [r, 0];

prob = zeros(1, length(theta)); 

tic
for i = 1:length(theta)
    x2 = r * [cos(theta(i)), sin(theta(i))];
    prob(i) = probability_OK_cpp([x1; x2], lambda, Lmax, N_grid);
end
Cpp_time = toc

tic
for i = 1:length(theta)
    x2 = r * [cos(theta(i)), sin(theta(i))];
    prob(i) = probability_OK([x1; x2], lambda, Lmax, N_grid);
end
Matlab_time = toc

% tic
% parfor i = 1:length(theta)
%     x2 = r * [cos(theta(i)), sin(theta(i))];
%     prob(i) = probability_OK([x1; x2], lambda, Lmax, N_grid);
% end
% Matlab_time_parallel = toc

Matlab_time/Cpp_time