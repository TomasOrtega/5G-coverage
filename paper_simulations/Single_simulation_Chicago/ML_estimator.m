function estimation = ML_estimator(data, lambda, Lmax, mesh)
eps = 1e-4;
estimation = zeros(1, size(mesh,1));
for i = 1:size(mesh, 1)
    prob = points_probability_eps([mesh(i,:),1;data], lambda, Lmax, eps);
    probY1 = probability_OK(mesh(i,:), lambda, Lmax);
	estimation(i) = double(prob / probY1 > 0.5);
end

end

