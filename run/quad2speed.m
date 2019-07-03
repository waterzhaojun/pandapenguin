function speed = quad2speed(quad_vector)

    speed = zeros(1, length(quad_vector));
    
        for i = 2:length(quad_vector)
            speed(i) = abs(quad_vector(i)-quad_vector(i-1));
        end
    
    speed(1) = speed(2);

end