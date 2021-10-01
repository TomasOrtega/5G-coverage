function estimation = Gaussian_estimator(data, sigma, mesh)

estimation = zeros(1, size(mesh,1));
for i = 1:size(mesh, 1)
    % for every data point add Gaussian 1 or -1
    res = 0;
    for j = 1:size(data, 1)
        res = res + (-1 + 2*data(j,3)) * exp(-norm(mesh(i, :)-data(j, 1:2))^2 / 2 / sigma^2);
    end
	estimation(i) = double(res > 0);
end

end

