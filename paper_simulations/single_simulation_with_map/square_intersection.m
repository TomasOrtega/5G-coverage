function intersection = square_intersection(point, L)
% Returns intersection point between square [-L,L]x[-L,L] (workspace), 
% and the projection ray origin-point.
% Assume always point != (0,0)

if (point(1) == 0) | (abs(point(2)/point(1)) >= 1)
	y = sign(point(2)) * L;
	x = sign(point(2)) * L * point(1)/point(2);
else
	x = sign(point(1)) * L;
	y = sign(point(1)) * L * point(2)/point(1);
end

intersection = [x,y];

end
		
