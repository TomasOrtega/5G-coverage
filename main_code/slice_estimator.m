function estimation = slice_estimator(data, lambda, Lmax, mesh, theta0)
% Circular slice MAP approximation

global skips;
skips = 0;

data_angle = atan2( data(:, 1), data(:, 2) );

estimation = zeros(1, size(mesh,1));
for i = 1:size(mesh, 1)
    % Take only nearest data points by angle theta0
    data_subset = nearest_angle_points(mesh(i,[1,2]), data, data_angle, theta0);
	estimation(i) = estimate_point_var(mesh(i,:), data_subset , lambda, Lmax);
end

%display(['total number of skips : ' , num2str(skips)]);
end



