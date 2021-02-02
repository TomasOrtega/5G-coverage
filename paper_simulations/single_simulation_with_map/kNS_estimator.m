function estimation = kNS_estimator(data, mesh, L, K)

    estimation = zeros(1, size(mesh, 1));
    N_data = size(data,1);

    for i = 1:size(mesh,1) % for each point in the mesh (mesh has index, x, y)
        p = mesh(i, :);
        % Search for K nearest segments
        dist_data = zeros(N_data,1);
        for j = 1:N_data
            b = [0,0];
            if ~data(j,3) % if shadow
                b = square_intersection(data(j,1:2),L);
            end
            dist_data(j) = point_to_segment(p,data(j,1:2),b);
        end
        [~, index] = mink(dist_data, K);
        estimation(i) = round( sum(data(index, 3))/K);
    end
end