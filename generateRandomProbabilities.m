function prob = generateRandomProbabilities(n)
    % generates n random probabilities that sum to 1
    raw = rand(1, n); 
    prob = raw / sum(raw); 
    % normalize so sum = 1
end