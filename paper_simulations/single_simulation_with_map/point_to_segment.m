function d = point_to_segment(pt, a, b)
% POINT_TO_SEGMENT Distance from point to segment
%   d = POINT_TO_SEGMENT(pt,a,b) is the distance from the point in the
%   plane pt to the segment in the plane defined by points a, b
    eps = 1e-6;   
    if point_in_segment(pt,a,b,eps)
        d = 0;
    else
        % z coordinate is added to ease calculations
        pt = [pt(1),pt(2),0];
        a = [a(1),a(2),0];
        b = [b(1),b(2),0];
        v1 = a - b;
        v2 = pt - b;
        d = norm(cross(v1,v2)) / norm(v1); % distance from point to line
        h = cross(v1,cross(v1,v2)); % perpendicular vector from point to line
        he = h / norm(h);
        perp = he*d;
        pt_min_dist = pt+perp; % point of intersection in line    
        if ~point_in_segment(pt_min_dist,a,b,eps)
            d = min(norm(pt-a),norm(pt-b));
        end
    end
    
    