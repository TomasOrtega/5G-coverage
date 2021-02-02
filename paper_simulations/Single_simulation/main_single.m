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

rng(2); % random seed set

  % PPP parameter
Lmax = 20;        % Building's length distribution parameter (L ~ U(0,Lmax))
R = 150;          % Cell radius
lambda = 0.0015;

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.
L = 2*R;

N_data_vector = 2:50;

N_montecarlo = 600;  % Number of montecarlo simulations for scenario

%% Simulation

% Precision variables init
precision_kNMAP = zeros(1,length(N_data_vector));
precision_kNS = zeros(1,length(N_data_vector));
precision_kNN = zeros(1,length(N_data_vector));
precision_slice = zeros(1,length(N_data_vector));
time_MAP = zeros(1,length(N_data_vector));
time_kNMAP = zeros(1,length(N_data_vector));
time_kNS = zeros(1,length(N_data_vector));
time_kNN = zeros(1,length(N_data_vector));
time_slice = zeros(1,length(N_data_vector));

N_mesh = 12;  % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R,R,N_mesh), linspace(-R,R,N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

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
        estimated_kNMAP = kNMAP_estimator(data, lambda, Lmax, mesh, 3);
        time_kNMAP(k) = time_kNMAP(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_kNMAP, total_shadow);
        precision_kNMAP(k) = precision_kNMAP(k) + precision;        
        
        timer = tic;
        estimated_kNS = kNS_estimator(data, mesh, L, 1);
        time_kNS(k) = time_kNS(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_kNS, total_shadow);
        precision_kNS(k) = precision_kNS(k) + precision;   
        
        timer = tic;
        estimated_kNN = kNN_estimator(data, mesh, 3);
        time_kNN(k) = time_kNN(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_kNN, total_shadow);
        precision_kNN(k) = precision_kNN(k) + precision;   
        
        timer = tic;
        estimated_slice = slice_estimator(data, lambda, Lmax, mesh, pi/12);
        time_slice(k) = time_slice(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_slice, total_shadow);
        precision_slice(k) = precision_slice(k) + precision;   
    end
    
end
disp('Timer Montecarlo took')
disp(toc(timer_montecarlo))

%Normalize precision values
precision_kNMAP = precision_kNMAP/N_montecarlo;
precision_kNS = precision_kNS/N_montecarlo;
precision_kNN = precision_kNN/N_montecarlo;
precision_slice = precision_slice/N_montecarlo;
time_kNMAP = time_kNMAP/N_montecarlo;
time_kNS = time_kNS/N_montecarlo;
time_kNN = time_kNN/N_montecarlo;
time_slice = time_slice/N_montecarlo;


%% Plot results.
fig1 = figure(); hold on;
grid on;

plot(N_data_vector, precision_kNMAP,'-bo');
plot(N_data_vector, precision_slice,':r*');
plot(N_data_vector, precision_kNN,'-.md');
plot(N_data_vector, precision_kNS,'--gs');


ylim([0,1]);

% title('MAP Estimator vs. K-Nearest MAP Approximation Precision')
ylabel('Estimator Precision')
xlabel('$N$ data points')
legend('$\rho$ kN MAP', '$\rho$ Slice MAP', '$\rho$ kNS','$\rho$ kNN')
legend('Location', 'southeast')
hold off;
exportgraphics(fig1,'estimator_precision.pdf','ContentType','vector')

% Computation Time Plot
fig2 = figure(); hold on;
plot(N_data_vector, time_kNMAP,'-bo');
plot(N_data_vector, time_slice,':r*');
plot(N_data_vector, time_kNN,'-.md');
plot(N_data_vector, time_kNS,'--gs');


ylabel('Estimator Computational Time (s)')
xlabel('$N$ data points')
legend('kN MAP', 'Slice MAP', 'kNS', 'kNN')
legend('Location', 'northwest')

grid on;
exportgraphics(fig2,'computational_time.pdf','ContentType','vector')

%% Save results
save('single_simulation')