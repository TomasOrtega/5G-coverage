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

N_data_vector = 2:10; %178 segons en una tirada de 2 a 10

N_montecarlo = 300;  % Number of montecarlo simulations for scenario

%% Simulation

% Precision variables init
precision_MAP = zeros(1,length(N_data_vector));
precision_kNMAP = zeros(1,length(N_data_vector));
time_MAP = zeros(1,length(N_data_vector));
time_kNMAP = zeros(1,length(N_data_vector));

N_mesh = 12;  % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R,R,N_mesh), linspace(-R,R,N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

for k = 1:length(N_data_vector) % Loop over values to simulate
    
    N_data = N_data_vector(k);
    disp(N_data);

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
        estimated_MAP = MAP_estimator(data, lambda, Lmax, mesh);
        time_MAP(k) = time_MAP(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_MAP, total_shadow);
        precision_MAP(k) = precision_MAP(k) + precision;
        
        timer = tic;
        estimated_kNMAP = kNMAP_estimator(data, lambda, Lmax, mesh, 3);
        time_kNMAP(k) = time_kNMAP(k) + toc(timer);
        precision = estimation_precision(mesh, estimated_kNMAP, total_shadow);
        precision_kNMAP(k) = precision_kNMAP(k) + precision;        
        
    end
    
end

%Normalize precision values
precision_MAP = precision_MAP/N_montecarlo;
precision_kNMAP = precision_kNMAP/N_montecarlo;
time_MAP = time_MAP/N_montecarlo;
time_kNMAP = time_kNMAP/N_montecarlo;


%% Plot results.
fig1=figure(); hold on;
grid on;

plot(N_data_vector, precision_kNMAP,'-bo');
plot(N_data_vector, precision_MAP,':kx');

ylim([0,1]);
xticks(N_data_vector)

ylabel('Estimator Precision')
xlabel('$N$ data points')
legend('$\rho$ $k$N-MAP','$\rho$ MAP')
legend('Location', 'southeast')

hold off;
exportgraphics(fig1,'MAPvsAPXprecision.pdf','ContentType','vector')


% Computation Time Plot MAPvsAPXtime
fig2 = figure(); hold on;

plot(N_data_vector, time_kNMAP,'-bo');
plot(N_data_vector, time_MAP,':kx');

xticks(N_data_vector)

ylabel('Estimator Computational Time (s)')
xlabel('$N$ data points')
legend('Computational Time $k$N-MAP','Computational Time MAP')
legend('Location', 'northwest')
grid on; 
exportgraphics(fig2,'MAPvsAPXtime.pdf','ContentType','vector')


%% Save results
save('MAP_approx_comparison')