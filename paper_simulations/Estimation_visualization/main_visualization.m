%% Pre-run.
clear; close all;
warning('off','all')  % Do not display ployshape warnings.
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
% mex -setup c++
% mex probability_OK_cpp.cpp
% for even better performance
% mex -v COPTIMFLAGS='-O3 -fwrapv -DNDEBUG'  probability_OK_cpp.cpp

%% PPP-simulation of buildings and data generation.
rng(2);

lambda = 0.00075*1;  % PPP parameter
Lmax = 20;        % Building's length distribution parameter (L ~ U(0,Lmax))
R = 150;          % Cell radius

buildings = PPP_buildings(lambda, Lmax, R);  % Mx4 matrix of buildings

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.
L = 2*R;
total_shadow = generate_shadows(R, buildings);  % Generation of shadow polygons in the cell

% Number of points in data, 15 at most if not approximating
N_data = 30;  

% Generates N data points inside the study cell with light(1)/shadow(0) label.
data = generate_data(N_data, total_shadow, R);  

% Plot pre-estimation (plot data and shadows only).
figure(1); 
title_string = 'Sparse obstacles scenario ($N = 30$)';
plot_estimation(L, R, total_shadow, data, [], [], title_string);
exportgraphics(gca,'figa.pdf','ContentType','vector')

%% Generate cell of study (points to estimate)

N_mesh = 12;  % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R,R,N_mesh), linspace(-R,R,N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

%% Estimation of light/shadow in the cell mesh and calculus of precision.

% OK/KO inclusion exclusion approximated algorithm

% K-nearest neighbors
timer = tic;
estimated_kNN = kNN_estimator(data, mesh, 3);  
elapsed_time_3 = toc(timer);
display(['Elapsed time for K-nearest neighbors estimation: ', num2str(elapsed_time_3)])

% OK/KO inclusion exclusion approximated by k nearest algorithm
timer = tic;
estimated_kNMAP = kNMAP_estimator(data, lambda, Lmax, mesh,3);  
elapsed_time_5 = toc(timer);
display(['Elapsed time for K-nearest Bayesian estimation: ', num2str(elapsed_time_5)])

%% Plot results.

figure(2);  
title_string = '$k$N-MAP Estimation ($k=3$)';
plot_estimation(L, R, total_shadow, data, mesh, estimated_kNMAP, title_string)
exportgraphics(gca,'figb.pdf','ContentType','vector')

figure(3)
title_string = '$k$NN Estimation ($k=3$)';
plot_estimation(L, R, total_shadow, data, mesh, estimated_kNN, title_string)
exportgraphics(gca,'figc.pdf','ContentType','vector')