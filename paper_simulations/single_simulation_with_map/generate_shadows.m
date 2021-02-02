function total_shadow = generate_shadows(R, buildings)
    L = 2 * R; 
    N_buildings = size(buildings, 1);

    total_shadow = polyshape([0,0]); %total shadow polygon (init as a point)

    for i = 1:N_buildings
        point1 = buildings(i,1:2);
        point2 = buildings(i,3:4);
        point3 = square_intersection(point1, L); 
        point4 = square_intersection(point2, L) ;
        %In this order so as to generate the propper polygon
        polygon = polyshape([point1; point2; point4; point3]);
        total_shadow = union(total_shadow, polygon);
    end
end
