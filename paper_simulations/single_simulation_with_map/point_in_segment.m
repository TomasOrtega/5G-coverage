function res = point_in_segment(pt, a, b, eps)
% POINT_IN_SEGMENT Returns true if point is in segment, false otherwise, with tolerance eps
    res = abs(norm(pt-a) + norm(pt-b) - norm(a-b)) < eps;
    