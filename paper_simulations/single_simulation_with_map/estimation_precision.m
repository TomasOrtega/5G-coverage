function precision = estimation_precision(mesh, estimation, total_shadow)

    N = size(mesh, 1);  % Total number of estimations
    Nmiss = 0;

    for i = 1:N
        if estimation(i) == isinterior(total_shadow, mesh(i,:))
            Nmiss = Nmiss + 1;
        end
    end

    precision = (N - Nmiss)/N;
end

