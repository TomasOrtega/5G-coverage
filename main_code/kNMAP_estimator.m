function estimation = kNMAP_estimator(data, lambda, Lmax, mesh, k_nearest_angle)

    global skips;
    skips = 0;
    
    % was configured at k = 3;

    data_angle = atan2( data(:, 1), data(:, 2) );

    estimation = zeros(1, size(mesh, 1));
    for i = 1:size(mesh, 1)
        % Take only the k nearest angle points
        data_subset = k_nearest_angle_points(mesh(i,[1,2]), data, data_angle, k_nearest_angle);
        estimation(i) = estimate_point_var(mesh(i,:), data_subset, lambda, Lmax);
    end

    %display(['total number of skips : ' , num2str(skips)]);
end



