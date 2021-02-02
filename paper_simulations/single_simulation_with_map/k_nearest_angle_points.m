function data_subset = k_nearest_angle_points(P, data, data_angle, k_min)
% Given a point P = [x, y], returns a subset of the k_min data points which
% are at the smallest angle to P.

angle_P = atan2(P(1), P(2));
anglediff = abs(angle_P - data_angle);
indexes_to_correct = (anglediff > pi) & (sign(P(1)*P(2)) ~= sign(data(:,1).*data(:,2)));
anglediff(indexes_to_correct) = anglediff(indexes_to_correct) - pi;

[~,data_subset_index] = mink(abs(anglediff), k_min);
data_subset = data(data_subset_index, :);

end

