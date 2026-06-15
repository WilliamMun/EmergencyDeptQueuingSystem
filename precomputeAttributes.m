function patient_table = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime) 
    jitcontrol off;
    random_matrix = reshape(random_sequence, 5, N); 
    % scale random elements 
    rn_arrival = floor(random_matrix(1, :) * maxRange) + 1; 
    rn_triage = floor(random_matrix(2, :) * maxRange) + 1; 
    rn_service = floor(random_matrix(3, :) * maxRange) + 1; 
    rn_return = floor(random_matrix(4, :) * maxRange) + 1; 
    rn_retTime = floor(random_matrix(5, :) * maxRange) + 1; 
    rn_arrival(1) = 0; 
    % memory allocation 
    interarrival_times = zeros(1, N); 
    triage_zones_numeric = zeros(1, N); 
    pre_service_times = zeros(1, N); 
    return_decisions_numeric = zeros(1, N); 
    return_delay_times = zeros(1, N); 
    % map interarrival times  
    for i = 1:length(values_arrival) 
        interarrival_times(rn_arrival >= ranges_arrival(i, 1) & rn_arrival <= ranges_arrival(i, 2)) = values_arrival(i); 
    end 
    interarrival_times(1) = 0; 
    arrival_times = cumsum(interarrival_times); 
    % map triage zone and zone specific service time 
    for p = 1:N 
        curr_triage_rn = rn_triage(p); 
        zone_idx = 0; 
        for i = 1:length(values_triage) 
            if curr_triage_rn >= ranges_triage(i, 1) && curr_triage_rn <= ranges_triage(i, 2) 
                zone_idx = i; % 1 = red, 2 = yellow, 3 = green 
                break; 
            end 
        end 
        curr_service_rn = rn_service(p); 
        srv_time = 0; 
        display_zone_numeric = zone_idx; 
        if zone_idx == 1 % red 
            for i = 1:length(values_serviceRed) 
                if curr_service_rn >= ranges_serviceRed(i, 1) && curr_service_rn <= ranges_serviceRed(i, 2) 
                    srv_time = values_serviceRed(i); 
                    break; 
                end 
            end 
        elseif zone_idx == 2 % yellow 
            for i = 1:length(values_serviceYellow) 
                if curr_service_rn >= ranges_serviceYellow(i, 1) && curr_service_rn <= ranges_serviceYellow(i, 2) 
                    srv_time = values_serviceYellow(i); 
                    break; 
                end 
            end 
        elseif zone_idx == 3 % green 
            green_counter_choice = floor(random_matrix(3, p) * 3) + 1; 
            if green_counter_choice == 1 
                display_zone_numeric = 3; % green (C1) 
                for i = 1:length(values_serviceGreen1) 
                    if curr_service_rn >= ranges_serviceGreen1(i, 1) && curr_service_rn <= ranges_serviceGreen1(i, 2) 
                        srv_time = values_serviceGreen1(i);
                        break; 
                    end 
                end 
            elseif green_counter_choice == 2 
                display_zone_numeric = 4; % green (C2) 
                for i = 1:length(values_serviceGreen2) 
                    if curr_service_rn >= ranges_serviceGreen2(i, 1) && curr_service_rn <= ranges_serviceGreen2(i, 2) 
                        srv_time = values_serviceGreen2(i); 
                        break; 
                    end 
                end 
            else display_zone_numeric = 5; % green (C3) 
                for i = 1:length(values_serviceGreen3) 
                    if curr_service_rn >= ranges_serviceGreen3(i, 1) && curr_service_rn <= ranges_serviceGreen3(i, 2) 
                        srv_time = values_serviceGreen3(i); 
                        break; 
                    end 
                end 
            end 
        end 
        triage_zones_numeric(p) = display_zone_numeric; 
        pre_service_times(p) = srv_time; 
    end 
    % map return decisions numerically (1 = yes, 2 = no) 
    for i = 1:length(values_return) 
        return_decisions_numeric(rn_return >= ranges_return(i, 1) & rn_return <= ranges_return(i, 2)) = i; 
    end 
    % map return delay times 
    for i = 1:length(values_retTime) 
        return_delay_times(rn_retTime >= ranges_retTime(i, 1) & rn_retTime <= ranges_retTime(i, 2)) = values_retTime(i);
    end 
    % clear delay time if patient not returning (No = 2) 
    for p = 1:N 
        if return_decisions_numeric(p) == 2 
            return_delay_times(p) = 0; 
        end 
    end 
    % print pre-computation summary table  
    disp('================================================================================================================='); 
    disp('Generated Patient Attributes Master Pre-Computation Array Matrix'); 
    disp('================================================================================================================='); 
    fprintf('|Pat ID|Arr Time |Triage Zone|Ser Time|Will Return?|Return Delay Time|\n'); 
    disp('-----------------------------------------------------------------------------------------------------------------'); 
    % temporary holders for output strings
    triage_zones = cell(1, N); 
    return_decisions = cell(1, N); 
    for p = 1:N 
        % map zone ids 
        if triage_zones_numeric(p) == 1; 
            triage_zones{p} = 'Red'; 
        elseif triage_zones_numeric(p) == 2; 
            triage_zones{p} = 'Yellow'; 
        elseif triage_zones_numeric(p) == 3; 
            triage_zones{p} = 'Green (C1)'; 
        elseif triage_zones_numeric(p) == 4; 
            triage_zones{p} = 'Green (C2)'; 
        else triage_zones{p} = 'Green (C3)'; 
        end 
        % map return decisions 
        if return_decisions_numeric(p) == 1; 
            return_decisions{p} = 'Yes'; 
        else return_decisions{p} = 'No'; 
        end
    
        fprintf('|%-5d | %-8.2f| %-10s| %-7g| %-11s| %-16g|\n', p, arrival_times(p), triage_zones{p}, pre_service_times(p), return_decisions{p}, return_delay_times(p));
    end 
    disp('================================================================================================================='); 
    disp(' '); 
    % output data map struct 
    patient_table.arrival_times = arrival_times; 
    patient_table.triage_zones = triage_zones; 
    patient_table.service_times = pre_service_times; 
    patient_table.return_decisions = return_decisions; 
    patient_table.return_delay_times = return_delay_times; 
end