function [cdf, ranges] = printSimulationTable(titleStr, labelStr, values, probabilities, maxRange) 
    %safety validation check
    if length(values) ~= length(probabilities) 
        disp(' '); 
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'); fprintf('INPUT ERROR in %s:\n', titleStr); fprintf('You entered %d values but %d probabilities!\n', length(values), length(probabilities)); 
        disp('The number of values and probabilities MUST match exactly.'); 
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'); error('Simulation stopped due to mismatched input vector lengths.'); 
    end 
    numElements = length(probabilities); 
    cdf = zeros(1, numElements); 
    ranges = zeros(numElements, 2); 
    currentCDF = 0.0; currentRangeStart = 1; 
    for i = 1:numElements 
        currentCDF = currentCDF + probabilities(i); 
        cdf(i) = currentCDF; 
        % scale end point to user custom range 
        currentRangeEnd = round(currentCDF * maxRange); 
        %safety catch for small scale limit
        if probabilities(i) > 0 && currentRangeEnd < currentRangeStart 
            currentRangeEnd = currentRangeStart; 
        end 
        if i == numElements 
            currentRangeEnd = maxRange; 
        end 
        ranges(i, :) = [currentRangeStart, currentRangeEnd]; 
        currentRangeStart = currentRangeEnd + 1; 
    end 
    %dynamic formatting for perfect columns
    totalTableWidth = 30 + (numElements * 13); 
    dividerLine = repmat('=', 1, totalTableWidth); 
    disp(dividerLine); 
    fprintf('%s (Scale Limits: 1 to %d)\n', titleStr, maxRange); 
    disp(dividerLine); 
    %print values row
    fprintf('| %-26s |', labelStr); 
    for i = 1:numElements 
        if iscell(values) 
            fprintf(' %-11s|', values{i}); 
        else 
            fprintf(' %-11g|', values(i)); 
        end 
    end 
    fprintf('\n'); 
    % print probabilities row
    fprintf('| %-26s |', 'Probability'); 
    for i = 1:numElements 
        fprintf(' %-11.6f|', probabilities(i)); 
    end 
    fprintf('\n'); 
    % print cdf row
    fprintf('| %-26s |', 'CDF'); 
    for i = 1:numElements 
        fprintf(' %-11.6f|', cdf(i)); 
    end 
    fprintf('\n'); 
    % print scaled integer target range row
    fprintf('| %-26s |', 'Random Number Range'); 
    for i = 1:numElements 
        rangeString = sprintf('%d-%d', ranges(i, 1), ranges(i, 2)); 
        fprintf(' %-11s|', rangeString); 
    end 
    fprintf('\n'); 
    disp(dividerLine); 
    disp(' '); 
end