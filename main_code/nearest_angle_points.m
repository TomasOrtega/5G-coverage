function data_subset = nearest_angle_points(P, data, data_angle, theta0);
% Given a point P = [x, y], returns a subset of the data points which are
% at an angle to P less than theta0.

angle_P = atan2(P(1), P(2));
anglediff = abs(angle_P - data_angle);
indexes_to_correct = (anglediff > pi) & (sign(P(1)*P(2)) ~= sign(data(:,1).*data(:,2)));
anglediff(indexes_to_correct) = anglediff(indexes_to_correct) - pi;
data_subset = data(anglediff < theta0, :);

if (size(data_subset, 1) == 0) 
    data_subset = nearest_angle_points(P, data, data_angle, 2*theta0);
end

end

