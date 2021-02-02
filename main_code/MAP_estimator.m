function estimation = MAP_estimator(data, lambda, Lmax, mesh)
% Given a point P = [x, y], returns a subset of the k_min data points which
% are at the smallest angle to P.


eps = 1e-4; %precision of prob_data
prob_data = points_probability_eps(data, lambda, Lmax, eps);

global skips;
skips = 0;
estimation = zeros(1, size(mesh,1));
for i = 1:size(mesh, 1)
	estimation(i) = estimate_point(mesh(i,:), data, lambda, Lmax, prob_data);
end

%display(["total number of skips : " , num2str(skips)]);
end

