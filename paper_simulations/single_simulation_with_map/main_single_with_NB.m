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

%% Simulation Parameters
load('single_simulation_with_NB.mat');
rng(2); % random seed set

% TODO delete this, just to test
N_montecarlo = 1;  % Number of montecarlo simulations for scenario

%% Simulation

% Precision variables init
precision_NB = zeros(1,length(N_data_vector));
precision_Gaussian = zeros(1,length(N_data_vector));
time_NB = zeros(1,length(N_data_vector));
time_Gaussian = zeros(1,length(N_data_vector));

timer_montecarlo = tic;
for k = 1:length(N_data_vector) % Loop over values to simulate
    
    N_data = N_data_vector(k);
    disp(N_data);
    disp('Hours spent:')
    disp(toc(timer_montecarlo) / 3600)

    for simulation = 1:N_montecarlo
        %% PPP-simulation of buildings and data generation.

        % Mx4 matrix of buildings
        buildings = PPP_buildings(lambda, Lmax, R);
        
        % Generation of shadow polygons in the cell
        total_shadow = generate_shadows(R, buildings);  
        
        % Generates N data points inside the study cell with
        % light(1)/shadow(0) label.
        data = generate_data(N_data, total_shadow, R);  

        %% Estimation of light/shadow in the cell mesh and calculus of precision.
        timer = tic;
        estimated_NB = NB_estimator(data, lambda, Lmax, mesh);
        time_NB(k) = time_NB(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_NB, total_shadow);
        precision_NB(k) = precision_NB(k) + precision;   
        
        timer = tic;
        estimated_Gaussian = Gaussian_estimator(data, 1.8, mesh);
        time_Gaussian(k) = time_Gaussian(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_Gaussian, total_shadow);
        precision_Gaussian(k) = precision_Gaussian(k) + precision;    
    end
    
end
disp('Timer Montecarlo took')
disp(toc(timer_montecarlo))

%Normalize precision values
precision_NB = precision_NB/N_montecarlo;
precision_Gaussian = precision_Gaussian/N_montecarlo;
time_NB = time_NB/N_montecarlo;
time_Gaussian = time_Gaussian/N_montecarlo;


%% Plot results.
fig1 = gcf; hold on;
plot(N_data_vector, precision_Gaussian,'-.md', 'DisplayName', 'Gaussian');
plot(N_data_vector, precision_NB,'--gs', 'NB');
hold off;
exportgraphics(fig1,'estimator_precision_v2.pdf','ContentType','vector')

% Computation Time Plot
fig2 = figure(); hold on;
plot(N_data_vector, time_kNMAP,'-bo');
plot(N_data_vector, time_kNN,'-.md');
plot(N_data_vector, time_kNS,'--gs');
plot(N_data_vector, time_MAP,':kx');
plot(N_data_vector, time_NB,'--gs');
plot(N_data_vector, time_Gaussian,':kx');

ylabel('Estimator Computational Time (s)')
xlabel('$N$ data points')
legend('$k$N-MAP', '$k$NN','$k$NS', 'MAP', 'NB', 'Gaussian')
legend('Location', 'east')

grid on;
exportgraphics(fig2,'computational_time_v2.pdf','ContentType','vector')

%% Save results
save('single_simulation_with_NB')