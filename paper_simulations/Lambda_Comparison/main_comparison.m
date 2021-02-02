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
N_data = 30;

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.
L = 2*R;

lambda_vector = linspace(1,6,11)*0.00075;

N_montecarlo = 1000;  % Number of montecarlo simulations for scenario

%% Simulation

% Precision variables init
precision_kNS = zeros(1,length(lambda_vector));
precision_kNB = zeros(1,length(lambda_vector));
precision_kNN = zeros(1,length(lambda_vector));

N_mesh = 12;  % Mesh x,y partitions.
[x, y] = meshgrid(linspace(-R,R,N_mesh), linspace(-R,R,N_mesh));
in_unitary_disk = x.^2 + y.^2 <= R^2;
% array with the points to estimate,(points inside unitary disk)
mesh = [x(in_unitary_disk), y(in_unitary_disk)];

timer = tic; 
for k = 1:length(lambda_vector) % Loop over values to simulate
    
    lambda = lambda_vector(k);

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
        estimated_kNS = kNS_estimator(data, mesh, L, 1);
        precision = estimation_precision(mesh, estimated_kNS, total_shadow);
        precision_kNS(k) = precision_kNS(k) + precision;
        
        estimated_kNMAP = kNMAP_estimator(data, lambda, Lmax, mesh, 3);
        precision = estimation_precision(mesh, estimated_kNMAP, total_shadow);
        precision_kNB(k) = precision_kNB(k) + precision; 
        
        estimated_kNN = kNN_estimator(data, mesh, 3);
        precision = estimation_precision(mesh, estimated_kNN, total_shadow);
        precision_kNN(k) = precision_kNN(k) + precision;  
        
    end
    
end
disp(toc(timer));

%Normalize precision values
precision_kNS = precision_kNS/N_montecarlo;
precision_kNB = precision_kNB/N_montecarlo;
precision_kNN= precision_kNN/N_montecarlo;

%% Plot results.
figure(); hold on;
grid on; 

plot(lambda_vector, precision_kNB,'-bo');
plot(lambda_vector, precision_kNS,'--gs');
plot(lambda_vector, precision_kNN,'-.md');

ylim([0,1]);
%xticks(N_data_vector)

% title('MAP Estimator vs. K-Nearest MAP Approximation Precision')
ylabel('Estimator Precision')
xlabel('$\lambda$ (m$^{-2}$)')
legend('$\rho$ $k$N-MAP', '$\rho$ $k$NS', '$\rho$ $k$NN')
legend('Location', 'southeast')
exportgraphics(gca,'lambda_comparison.pdf','ContentType','vector')

%% Save results
save('lambda_comparison')