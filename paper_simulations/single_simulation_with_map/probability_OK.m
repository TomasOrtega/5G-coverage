function probability = probability_OK(points, lambda, Lmax, N_grid)
% The function calculates the probability that the given points are
% all in light. The function calculates it using the fact that for a PPP, 
% the asked probability is given by exp(-expect_value(K_C)) (see paper for 
% notation).

if isempty(points)  % Trivial case.
	
probability = 1;

else
points_grid = 100;
if exist('N_grid', 'var')
    points_grid = N_grid;
end
probability = probability_OK_cpp(points,lambda,Lmax,points_grid);

end

