%% Pre-run.
clear all
close all;
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
warning('off','all')  % Do not display ployshape warnings.
rng(9); % to make sure results are repeatable

%% PPP-simulation of buildings and data generation.

lambda = 0.00120;  % PPP parameter
Lmax = 20;        % Building's length distribution parameter (L ~ U(0,Lmax))
R = 150;          % Cell radius

buildings = PPP_buildings(lambda, Lmax, R);  % Mx4 matrix of buildings

% Workspace: [-L,L]x[-L,L] square (L = 2*R); cell of study: disk of radius R centered at origin.

generate_shadows  % Generation of shadow polygons in the cell

% Plot pre-estimation (plot data and shadows only).
N_data = 40;  % Number of points in data, 15 at most if not approximating
data = generate_data(N_data, total_shadow, R);  % Generates N data points inside the study cell with light(1)/shadow(0) label.

% Plot pre-estimation (plot data and shadows only).

figure(1); L = 2*R;
plot([L,-L,-L,L,L], [L,L,-L,-L,L], '-')% Plot square of working region.
hold on; xlim((1.1)*[-R R]); ylim((1.1)*[-R R]); pbaspect([1 1 1]); % Aspect ratio 1:1.

plot( R*cos(linspace(0,2*pi,1000)), R*sin(linspace(0,2*pi,1000)), '-');  % Plot border of unit disk.

plot(total_shadow, 'FaceColor', 'black', 'FaceAlpha', 0.3, 'LineStyle', 'none');  % Plot shadows.

y = [-110,0];

% angle of y is atan2(y(2)/y(1))
angle_y = atan2(y(2),y(1));
plot(data(:,1), data(:,2), 'xk');  % Data plot

% plot additional data for degenerate case
k_added = 20;
theta = 0.05*pi * (rand(k_added, 1));
theta = theta - mean(theta) + angle_y;% angular coordinates
rho = 0.5*R * sqrt(rand(k_added, 1));  % radial coordinates
[x_k,y_k] = pol2cart(theta, rho); 
plot(x_k, y_k, 'xk');  % Data plot

% plot more additional data for degenerate case
plot(y(1) - 15, y(2) - 4, 'xk');  % Data plot
plot(y(1) - 13, y(2) + 9, 'xk');  % Data plot

scatter(y(1),y(2),'filled','b');
text(y(1)+5,y(2)+5,'$y$')

in_circle_x = R*cos(linspace(0,2*pi,1000));
in_circle_y = R*sin(linspace(0,2*pi,1000));
inner_circle = polyshape(in_circle_x, in_circle_y);

out_circle_x = 2*R*cos(linspace(0,2*pi,1000));
out_circle_y = 2*R*sin(linspace(0,2*pi,1000));
outer_circle = polyshape(out_circle_x, out_circle_y);

exterior_polygon = subtract(outer_circle, inner_circle);
plot(exterior_polygon,'FaceColor','white', 'FaceAlpha', 1, 'LineWidth', 1.5); % Plot exterior of disk.
xlim((1.1)*[-R R]); ylim((1.1)*[-R R]); pbaspect([1 1 1]); % Aspect ratio 1:1.

exportgraphics(gca,'slice_degenerate_3.pdf','ContentType','vector')