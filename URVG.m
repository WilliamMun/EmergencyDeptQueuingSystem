function output = URVG(N)
    
    a = 0;
    b = 1;
    
    R = rand(1, N);
    
    output = a + (b - a) .* R; % Xi = a + (b-a)Ri 
    
end