function data = generate_data(N, shadow, R)
% Generates N data points labeled with 1 or 0 whether they are on light/shadow.
% The function returns an Nx3 matrix.
% shadow is a polyshape object.

theta = 2*pi * (rand(N, 1));  % angular coordinates
rho = R * sqrt(rand(N, 1));  % radial coordinates
[x,y] = pol2cart(theta, rho);  % Convert from polar to Cartesian coordinates


label = zeros(N,1);

for i = 1:N
	if not( isinterior(shadow, x(i), y(i)) )
		label(i) = 1;  % Assign value 1 to points that are in light (not inside the shadow)
	end
end

data = [x, y, label];

%% Plot data in different colours (Optional)
% for i = 1:N
%     if data(i,3)
%         plot(data(i,1), data(i,2), 'xb')
%         hold on;
%     else
%         plot(data(i,1), data(i,2), 'xr')
%         hold on;
%     end
% end

end
	
