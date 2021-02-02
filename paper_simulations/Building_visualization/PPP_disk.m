function points = PPP_disk(lambda, R)
%Generates points on a disk with the given radius following a PPP with parameter lambda

Area = pi * R^2;  % area of the disk
  
% Simulate Poisson point process
Npoints = poissrnd(Area * lambda);  % Poisson number of points
theta = 2*pi * (rand(Npoints, 1));  % angular coordinates
rho = R * sqrt(rand(Npoints, 1));  % radial coordinates
 
% Convert from polar to Cartesian coordinates
[x,y] = pol2cart(theta, rho);  % x/y coordinates of Poisson points
points = [x,y];
end
