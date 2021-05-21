% This code is for the paper's figure with subplots, joining the lambda
% comparison and the long simulation with MAP

%% Pre-run.
clear; close all;
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% Plot results.
fig = figure(); 

load('../Lambda_Comparison/lambda_comparison.mat');

subplot(2,1,2); hold on; grid on;

plot(lambda_vector, precision_kNB,'-bo');
plot(lambda_vector, precision_kNS,'--gs');
plot(lambda_vector, precision_kNN,'-.md');

ylim([0.5,1]);
%xticks(N_data_vector)

ylabel('Estimator Precision $\rho$')
xlabel('$\lambda$ (m$^{-2}$), with 30 data points')
% legend('$k$N-MAP', '$k$NS', '$k$NN')
% legend('Location', 'southeast')

hold off;

load('single_simulation_with_map.mat')

subplot(2,1,1); hold on; grid on;

plot(N_data_vector, precision_kNMAP,'-bo');
plot(N_data_vector, precision_kNN,'-.md');
plot(N_data_vector, precision_kNS,'--gs');
plot(N_data_vector, precision_MAP,':kx');

ylim([0.5,1]);

ylabel('Estimator Precision $\rho$')
xlabel('$N$ data points, with $\lambda = 1.5 \times 10^{-3}$ m$^{-2}$')
legend('$k$N-MAP', '$k$NN','$k$NS', 'MAP')
legend('Location', 'southeast')

hold off;

%% save plot

exportgraphics(fig,'estimator_precision_with_lambda.pdf','ContentType','vector')
