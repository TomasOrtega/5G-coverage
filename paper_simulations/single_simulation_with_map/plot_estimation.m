function plot_estimation(L, R, total_shadow, data, mesh, estimation, title_string, buildings)
    % Plot square of working region.
    plot([L,-L,-L,L,L], [L,L,-L,-L,L], '-')
    hold on; xlim((1.1)*[-R R]); ylim((1.1)*[-R R]); pbaspect([1 1 1]); % Aspect ratio 1:1.

    title(title_string);
    
    % Plot border of unit disk.
    plot(R*cos(linspace(0,2*pi,1000)), R*sin(linspace(0,2*pi,1000)), '-'); 

    % Plot shadows, to see edge effects.
    plot(total_shadow, 'FaceColor', 'black', 'FaceAlpha', 0.3, 'LineStyle', 'none');
    
    % Plot data
    plot(data(:,1), data(:,2), 'xk');  

    % Plotting the estimations with different colours.
    for i = 1:size(mesh,1)  
        if estimation(i)  % Mesh(i,:) is in light.
            plot(mesh(i,1),mesh(i,2), 'ob')
        else
            plot(mesh(i,1),mesh(i,2), 'or')
        end
    end
    
    if exist('buildings','var')
        for i = 1:size(buildings,1)
            plot([buildings(i,1),buildings(i,3)],[buildings(i,2),buildings(i,4)],'k')
        end
    end
    
    in_circle_x = R*cos(linspace(0,2*pi,1000));
    in_circle_y = R*sin(linspace(0,2*pi,1000));
    inner_circle = polyshape(in_circle_x, in_circle_y);

    out_circle_x = 2*R*cos(linspace(0,2*pi,1000));
    out_circle_y = 2*R*sin(linspace(0,2*pi,1000));
    outer_circle = polyshape(out_circle_x, out_circle_y);

    exterior_polygon = subtract(outer_circle, inner_circle);
    plot(exterior_polygon,'FaceColor','white', 'FaceAlpha', 1, 'LineWidth', 1.5); % Plot exterior of disk.
    xlim((1.1)*[-R R]); ylim((1.1)*[-R R]); pbaspect([1 1 1]); % Aspect ratio 1:1.
    
    hold off;
end

