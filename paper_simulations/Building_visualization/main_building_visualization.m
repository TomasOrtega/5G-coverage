%% Pre-run.
clear all
close all;
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
warning('off','all')  % Do not display ployshape warnings.
rng(5); % to make sure results are repeatable

%% PPP-simulation of buildings and data generation.

lambda = 0.0012;  % PPP parameter
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

for i = 1:size(buildings,1)
    plot([buildings(i,1),buildings(i,3)],[buildings(i,2),buildings(i,4)],'k','LineWidth',1.5)
end

plot(data(:,1), data(:,2), 'xk');  % Data plot

y = [-50,100]; 
scatter(y(1),y(2),'filled','b'); % Plot y
text(y(1)+5,y(2)+5,'$y$') % Add y label

in_circle_x = R*cos(linspace(0,2*pi,1000));
in_circle_y = R*sin(linspace(0,2*pi,1000));
inner_circle = polyshape(in_circle_x, in_circle_y);

out_circle_x = 2*R*cos(linspace(0,2*pi,1000));
out_circle_y = 2*R*sin(linspace(0,2*pi,1000));
outer_circle = polyshape(out_circle_x, out_circle_y);

exterior_polygon = subtract(outer_circle, inner_circle);
plot(exterior_polygon,'FaceColor','white', 'FaceAlpha', 1, 'LineWidth', 1.5); % Plot exterior of disk.
xlim((1.1)*[-R R]); ylim((1.1)*[-R R]); pbaspect([1 1 1]); % Aspect ratio 1:1.

exportgraphics(gca,'scenario_example.pdf','ContentType','vector')