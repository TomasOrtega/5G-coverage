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
load('lambda_comparison');
rng(2); % random seed 

%% Simulation

% Precision variables init
precision_Gaussian = zeros(1,length(lambda_vector));
precision_NB = zeros(1,length(lambda_vector));

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
        estimated_Gaussian = Gaussian_estimator(data, 1.8, mesh);
        precision = estimation_precision(mesh, estimated_Gaussian, total_shadow);
        precision_Gaussian(k) = precision_Gaussian(k) + precision;
        
        estimated_NB = NB_estimator(data, lambda, Lmax, mesh);
        precision = estimation_precision(mesh, estimated_NB, total_shadow);
        precision_NB(k) = precision_NB(k) + precision;  
        
    end
    
end
disp(toc(timer));

%Normalize precision values
precision_Gaussian = precision_Gaussian/N_montecarlo;
precision_NB = precision_NB/N_montecarlo;

%% Plot results.
figure(); hold on;
grid on; 

plot(lambda_vector, precision_kNB,'-bo');
plot(lambda_vector, precision_kNS,'--gs');
plot(lambda_vector, precision_kNN,'-.md');

plot(lambda_vector, precision_NB,'-.r*');
plot(lambda_vector, precision_Gaussian,'--k*');

ylim([0,1]);
%xticks(N_data_vector)

% title('MAP Estimator vs. K-Nearest MAP Approximation Precision')
ylabel('Estimator Precision $\rho$')
xlabel('$\lambda$ (m$^{-2}$)')
legend('$k$N-MAP', '$k$NS', '$k$NN', 'NB', 'Gaussian, $\sigma = 1.8$')
legend('Location', 'southeast')
exportgraphics(gca,'lambda_comparison_v2.pdf','ContentType','vector')

%% Save results
save('lambda_comparison_v2')