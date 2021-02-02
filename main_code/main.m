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

lambda = 0.00075*1;  % PPP parameter
Lmax = 20;        % Building's length distribution parameter (L ~ U(0,Lmax))
R = 150;          % Cell radius

[lambda,Lmax,buildings] = chicago_buildings(R);

%buildings = PPP_buildings(lambda, Lmax, R);  % Mx4 matrix of buildings

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.
L = 2*R;
total_shadow = generate_shadows(R, buildings);  % Generation of shadow polygons in the cell

% Number of points in data, 10 at most if not approximating
N_data = 40;  

% Generates N data points inside the study cell with light(1)/shadow(0) label.
data = generate_data(N_data, total_shadow, R);  

% Plot pre-estimation (plot data and shadows only).
figure(); 
title_string = 'Data and shadows plot';
plot_estimation(L, R, total_shadow, data, [], [], title_string, buildings);

%% Generate cell of study (points to estimate)

N_mesh = 12;  % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R,R,N_mesh), linspace(-R,R,N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

%% Estimation of light/shadow in the cell mesh and calculus of precision.

% OK/KO inclusion exclusion approximated algorithm
% theta0 = pi/12;
% timer = tic;
% estimated_slice = slice_estimator(data, lambda, Lmax, mesh, theta0);
% elapsed_time_1 = toc(timer);
% display(['Elapsed time for Inclusion-Exclusion estimation approximated: ', num2str(elapsed_time_1)])

% OK/KO inclusion exclusion algorithm
% timer = tic;
% estimated_MAP = MAP_estimator(data, lambda, Lmax, mesh);  
% elapsed_time_2 = toc(timer);
% display(['Elapsed time for Inclusion-Exclusion estimation: ', num2str(elapsed_time_2)])

% K-nearest neighbors
timer = tic;
estimated_kNN = kNN_estimator(data, mesh, 3);  
elapsed_time_3 = toc(timer);
display(['Elapsed time for K-nearest neighbors estimation: ', num2str(elapsed_time_3)])

% % K-nearest segments
% timer = tic;
% estimated_kNS = kNS_estimator(data, mesh, L, 1);  
% elapsed_time_4 = toc(timer);
% display(['Elapsed time for K-nearest segments estimation: ', num2str(elapsed_time_4)])

% OK/KO inclusion exclusion approximated by k nearest algorithm
timer = tic;
estimated_kNMAP = kNMAP_estimator(data, lambda, Lmax, mesh, 3);  
elapsed_time_5 = toc(timer);
display(['Elapsed time for kN-MAP estimation: ', num2str(elapsed_time_5)])

%% Precision calculation

% precision = estimation_precision(mesh, estimated_slice, total_shadow);
% display(['Precision for slice approximation in %: ', num2str(precision * 100)])

% precision = estimation_precision(mesh, estimated_MAP, total_shadow); 
% display(['Precision for MAP in %: ', num2str(precision * 100)])

% precision = estimation_precision(mesh, estimated_kNN, total_shadow);
% display(['Precision for kNN in %: ', num2str(precision * 100)])

% precision = estimation_precision(mesh, estimated_kNS, total_shadow);
% display(['Precision for kNS algorithm in %: ', num2str(precision * 100)])

precision = estimation_precision(mesh, estimated_kNMAP, total_shadow);
display(['Precision for kNMAP in %: ', num2str(precision * 100)])

%% Plot results.

fig = figure();   % Multi-plot

% Plot Approximated Inclusion-Exclusion Estimation
% subplot(1, 3, 1);
% title_string = 'Inclusion-Exclusion Slice Estimation';
% plot_estimation(L, R, total_shadow, data, mesh, estimated_slice, title_string, buildings)

% % Plot Inclusion-Exclusion Estimation
% subplot(1, 3, 1);
% title_string = 'Inclusion-Exclusion Estimation';
% plot_estimation(L, R, total_shadow, data, mesh, estimated_MAP, title_string, buildings)

% Plot K-Nearest Neighbors Estimation
% subplot(1, 3, 2);
% title_string = 'K-Nearest-Neighbors Estimation (K = 3)';
% plot_estimation(L, R, total_shadow, data, mesh, estimated_kNN, title_string, buildings)

% % Plot K-Nearest Segments Estimation
% subplot(1, 3, 3);
% title_string = 'K-Nearest-Segments Estimation';
% plot_estimation(L, R, total_shadow, data, mesh, estimated_kNS, title_string, buildings)

% Plot K-Nearest Bayesian Estimation
% subplot(1, 3, 3);
% title_string = 'K-Nearest-Bayesian Estimation';
title_string='';
plot_estimation(L, R, total_shadow, data, mesh, estimated_kNMAP, title_string, buildings)

% fig.WindowState = 'maximized';
% exportgraphics(fig,'example_comparison.pdf','ContentType','vector')

%% Criteria for plot lines and dots
% plot(N_data_vector, precision_kNMAP,'-bo');
% plot(N_data_vector, precision_slice,':r*');
% plot(N_data_vector, precision_kNN,'-.md');
% plot(N_data_vector, precision_kNS,'--gs');
% plot(N_data_vector, precision_MAP,':kx');