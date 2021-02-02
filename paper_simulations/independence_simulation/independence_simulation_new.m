%% Pre-run.
clear all; close all;
warning('off','all')  % Do not display ployshape warnings.
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% Simulation of P(OK_1 |s OK_2) \approx P(OK_1) if x1 and x2 are sufficiently
% spread in angle.

lambda = 0.001;

Lmax = 20;  % Lmax value, what will vary will be r.

theta = linspace(0, pi, 500);

N_grid = 1000;

lsn = 1;
linestyles = ["-","--",":"];

for r = 50:50:150
    x1 = [r, 0];  % Fixed position of x1, x2 will rotate. 
    probOK = probability_OK_cpp(x1, lambda, Lmax, N_grid);  %% Since x1 and x2 are at the same distance from
    % base station,r
    
    prob_cond = zeros(1, length(theta)); prob_approx = zeros(1, length(theta));

    for i = 1:length(theta)
        x2 = r * [cos(theta(i)), sin(theta(i))];
        prob_cond(i) = probability_OK_cpp([x1; x2], lambda, Lmax, N_grid) / probOK;
        prob_approx(i) = probOK;
    end

    error = abs(prob_approx-prob_cond)./prob_cond;  % relative error made by the aproximacion
    plot(theta, error, linestyles(lsn), 'LineWidth', 2); hold on;
    lsn = lsn+1;
    axis([0, pi, 0, max(error)+0.05]);
end

xlabel('$\theta_0$')
ylabel('Relative Error')
set(gca,'XTick',0:pi/4:pi) 
set(gca,'XTickLabel',{'$0$','$\pi/4$','$\pi/2$','$3\pi/4$','$\pi$'})
grid on;
legend('r = 50','r = 100', 'r = 150')
hold off;
exportgraphics(gca,'independence.pdf','ContentType','vector')
