%% Pre-run.
clear; close all;
warning('off', 'all') % Do not display ployshape warnings.
set(groot, 'defaulttextinterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
% mex -setup c++
% mex probability_OK_cpp.cpp
% for even better performance
% mex -v COPTIMFLAGS='-O3 -fwrapv -DNDEBUG'  probability_OK_cpp.cpp

%% Simulation Parameters
R = 150; % Cell radius

[lambda, Lmax, buildings] = chicago_buildings(R);

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.
L = 2 * R;
total_shadow = generate_shadows(R, buildings); % Generation of shadow polygons in the cell

N_data_vector = 5:5:60;

N_montecarlo = 10000; % Number of montecarlo simulations for scenario

rng(2); % random seed set

%% Simulation

% Precision variables init
precision_kNN2 = zeros(1, length(N_data_vector));
time_kNN2 = zeros(1, length(N_data_vector));

N_mesh = 12; % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R, R, N_mesh), linspace(-R, R, N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

timer_montecarlo = tic;

for k = 1:length(N_data_vector) % Loop over values to simulate

    N_data = N_data_vector(k);
    disp(N_data);

    for simulation = 1:N_montecarlo
        %% PPP-simulation of buildings and data generation.

        % Generates N data points inside the study cell with
        % light(1)/shadow(0) label.
        data = generate_data(N_data, total_shadow, R);

        %% Estimation of light/shadow in the cell mesh and calculus of precision.
        timer = tic;
        estimated_kNN = kNN_estimator(data, mesh, 7);
        time_kNN2(k) = time_kNN2(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_kNN, total_shadow);
        precision_kNN2(k) = precision_kNN2(k) + precision;

    end

end

disp('Timer Montecarlo took')
disp(toc(timer_montecarlo))

%Normalize precision values
precision_kNN2 = precision_kNN2 / N_montecarlo;
time_kNN2 = time_kNN2 / N_montecarlo;

save('knn7_chicago')
return;

%% Plot results.
hold on;
grid on;

plot(N_data_vector, precision_kNN2, ':rd', 'DisplayName', '$k$NN, $k = 7$');

ylim([0, 1]);

hold off;
exportgraphics(fig1, 'estimator_precision_chicago.pdf', 'ContentType', 'vector')
