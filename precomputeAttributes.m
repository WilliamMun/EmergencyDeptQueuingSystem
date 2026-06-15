function patient_table = precomputeAttributes(N,maxRange,raw_stream,ranges_arrival,values_arrival,ranges_triage,values_triage,ranges_service,values_service,ranges_return,values_return,ranges_retTime,values_retTime)
    %reshape phase1 base random stream to 5 independent calculation rows
    random_matrix = reshape(raw_stream, 5, N);
    %scale random elements according to specific max target limit
    rn_arrival = floor(random_matrix(1, :) * maxRange) + 1;
    rn_triage = floor(random_matrix(2, :) * maxRange) + 1;
    rn_service = floor(random_matrix(3, :) * maxRange) + 1;
    rn_return = floor(random_matrix(4, :) * maxRange) + 1;
    rn_retTime = floor(random_matrix(5, :) * maxRange) + 1;
    %patien1 arrivals set to 0
    rn_arrival(1) = 0;
    
    %vector allocation
    interarrival_times = zeros(1, N);
    triage_zones = cell(1, N);
    pre_service_times = zeros(1, N);
    return_decisions = cell(1, N);
    return_delay_times = zeros(1, N);
    
    %vectorize matrix lookups
    for i = 1:length(values_arrival)
        interarrival_times(rn_arrival >= ranges_arrival(i, 1) & rn_arrival <= ranges_arrival(i, 2)) = values_arrival(i);
    end
    interarrival_times(1) = 0;
    arrival_times = cumsum(interarrival_times);
    for i =1:length(values_triage)
        triage_zones(rn_triage >= ranges_triage(i, 1) & rn_triage <= ranges_triage(i, 2)) = values_triage(i);
    end
    for i = 1:length(values_service)
        pre_service_times(rn_service >= ranges_service(i, 1) & rn_service <= ranges_service(i, 2)) = values_service(i);
    end
    for i = 1:length(values_return)
        return_decisions(rn_return >= ranges_return(i, 1) & rn_return <= ranges_return(i, 2)) = values_return(i);
    end
    for i = 1:length(values_retTime)
        return_delay_times(rn_retTime >= ranges_retTime(i, 1) & rn_retTime <= ranges_retTime(i, 2)) = values_retTime(i);
    end
    %if patient does not return, clear delay time
    for p = 1:N
        if strcmp(return_decisions{p}, 'No')
            return_delay_times(p) = 0;
        end
    end
    %print pre computation summary table
    disp('=================================================================================================================');
    disp('Generated Patient Attributes Master Pre-Computation Array Matrix');
    disp('=================================================================================================================');
    fprintf('|Pat ID|Arr Time |Triage Zone|Ser Time|Will Return?|Return Delay Time|\n');
    disp('-----------------------------------------------------------------------------------------------------------------');
    for p = 1:N
        fprintf('|%-4d | %-8.2f| %-10s| %-8g| %-11s| %-17g|\n', p, arrival_times(p), triage_zones{p}, pre_service_times(p), return_decisions{p}, return_delay_times(p));
    end
    disp('=================================================================================================================');
    disp(' ');
    %output data map struc to be processed in phase3
    patient_table.arrival_times = arrival_times;
    patient_table.triage_zones = triage_zones;
    patient_table.service_times = pre_service_times;
    patient_table.return_decisions = return_decisions;
    patient_table.return_delay_times = return_delay_times;
end
    