function [cdf, ranges] = printSimulationTable(titleStr, labelStr, values, probabilities, maxRange)
    % --- Safety Validation Check ---
    if length(values) ~= length(probabilities)
        disp(' ');
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        fprintf('INPUT ERROR in %s:\n', titleStr);
        fprintf('You entered %d values but %d probabilities!\n', length(values), length(probabilities));
        disp('The number of values and probabilities MUST match exactly.');
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
        error('Simulation stopped due to mismatched input vector lengths.');
    end

    numElements = length(probabilities);
    cdf = zeros(1, numElements);
    ranges = zeros(numElements, 2); 
    
    currentCDF = 0.0;
    currentRangeStart = 1;
    
    for i = 1:numElements
        currentCDF = currentCDF + probabilities(i);
        cdf(i) = currentCDF;
        
        % Scale end point to user custom range
        currentRangeEnd = round(currentCDF * maxRange);
        if i == numElements
            currentRangeEnd = maxRange; 
        end
        ranges(i, :) = [currentRangeStart, currentRangeEnd];
        currentRangeStart = currentRangeEnd + 1;
    end
    
    % --- Display Table Output ---
    disp('=================================================================================================================================');
    fprintf('%s (Scale Limits: 1 to %d)\n', titleStr, maxRange);
    disp('=================================================================================================================================');
    
    % Values
    fprintf('|%-28s|', labelStr);
    for i = 1:numElements
        if iscell(values)
            fprintf(' %-11s|', values{i});
        else
            fprintf(' %-11g|', values(i));
        end
    end
    fprintf('\n');
    
    % Probabilities
    fprintf('|%-28s|', 'Probability');
    for i = 1:numElements
        fprintf(' %.6f   |', probabilities(i));
    end
    fprintf('\n');
    
    % CDF
    fprintf('|%-28s|', 'CDF');
    for i = 1:numElements
        fprintf(' %.6f   |', cdf(i));
    end
    fprintf('\n');
    
    % Ranges
    fprintf('|%-28s|', 'Random Number Range');
    for i = 1:numElements
        fprintf(' %d-%-9d|', ranges(i, 1), ranges(i, 2));
    end
    fprintf('\n');
    disp('=================================================================================================================================');
    disp(' ');
end