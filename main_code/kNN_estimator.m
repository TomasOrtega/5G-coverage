function estimation = kNN_estimator(data, mesh, K)

    estimation = zeros(1, size(mesh, 1));

    for i = 1:size(mesh, 1)
        p = mesh(i, :);
        index = knnsearch(data(:, [1,2]), p, 'K', K);
        estimation(i) = round( sum(data(index, 3))/K);
    end
end