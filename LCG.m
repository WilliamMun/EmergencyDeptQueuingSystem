function output = LCG(N) 

    m = 256; 
    a = 5; 
    c = 7; 
    current_X = 4;  
    
    u = zeros(1, N);  
    
    for i = 1:N 
        next_X = mod(a * current_X + c, m); 
        u(i) = next_X / m; 
        current_X = next_X; 
    end 
    output = u;
end