function estimation = NB_estimator(data, lambda, Lmax, mesh)
eps = 1e-4;
estimation = zeros(1, size(mesh,1));
for i = 1:size(mesh, 1)
    M = size(data, 1);
    probY1 = probability_OK(mesh(i,:), lambda, Lmax);
    probY0 = 1 - probY1;
    prod1 = probY1;
    prod0 = probY0;
    for k = 1:M
        prod1 = prod1 * points_probability_eps([mesh(i,:),1;data(k,:)], lambda, Lmax, eps) / probY1;
        prod0 = prod0 * points_probability_eps([mesh(i,:),0;data(k,:)], lambda, Lmax, eps) / probY0;
    end    
	estimation(i) = double(prod1 > prod0);
end

end

