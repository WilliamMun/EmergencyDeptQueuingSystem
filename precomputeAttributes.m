function patient_table = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime) 
    jitcontrol off;
    random_matrix = reshape(random_sequence, 7, N); %added 6 rows, one more random number for the second service if they go xray
    % scale random elements 
    rn_arrival = floor(random_matrix(1, :) * maxRange) + 1; 
    rn_triage = floor(random_matrix(2, :) * maxRange) + 1; 
    rn_service = floor(random_matrix(3, :) * maxRange) + 1; 
    rn_return = floor(random_matrix(4, :) * maxRange) + 1; 
    rn_retTime = floor(random_matrix(5, :) * maxRange) + 1; 
    rn_service2 = floor(random_matrix(6, :) * maxRange) + 1; % new random number for returning patients
    green_assigned = zeros(1, N); % memory array to track which green doctor they saw
    
    rn_arrival(1) = -1; % standard first patient arrival as -1
    
    % memory allocation 
    interarrival_times = zeros(1, N); 
    triage_zones_numeric = zeros(1, N); % 1= red, 2 = yellow, 3 = green
    pre_service_times = zeros(1, N); 
    return_decisions_numeric = zeros(1, N); % 1 = yes, 0 = no
    return_delay_times = zeros(1, N); 
    second_service_times = zeros(1, N); % array for X-ray review times
    
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
            % phase 2 calculates green service times only, then phase 3 will decied which counter the patient will go based on availability
            green_counter_choice = floor(random_matrix(7, p) * 3) + 1; 
            green_assigned(p) = green_counter_choice; % save the specific doctor to memory
            
            if green_counter_choice == 1 
                for i = 1:length(values_serviceGreen1) 
                    if curr_service_rn >= ranges_serviceGreen1(i, 1) && curr_service_rn <= ranges_serviceGreen1(i, 2) 
                        srv_time = values_serviceGreen1(i);
                        break; 
                    end 
                end 
            elseif green_counter_choice == 2 
                for i = 1:length(values_serviceGreen2) 
                    if curr_service_rn >= ranges_serviceGreen2(i, 1) && curr_service_rn <= ranges_serviceGreen2(i, 2) 
                        srv_time = values_serviceGreen2(i); 
                        break; 
                    end 
                end 
            else 
                for i = 1:length(values_serviceGreen3) 
                    if curr_service_rn >= ranges_serviceGreen3(i, 1) && curr_service_rn <= ranges_serviceGreen3(i, 2) 
                        srv_time = values_serviceGreen3(i); 
                        break; 
                    end 
                end 
            end 
        end 
        triage_zones_numeric(p) = zone_idx; % store strictly as 1, 2 or 3  
        pre_service_times(p) = srv_time; 
    end 
    
    % map return decisions numerically (1 = yes, 0 = no) 
    for i = 1:length(values_return) 
        if strcmp(values_return{i}, 'Yes')
            return_decisions_numeric(rn_return >= ranges_return(i, 1) & rn_return <= ranges_return(i, 2)) = 1;
        else 
            return_decisions_numeric(rn_return >= ranges_return(i, 1) & rn_return <= ranges_return(i, 2)) = 0;
        end
    end
    
    % map return delay times and generate second service time
    for i = 1:length(values_retTime) 
        return_delay_times(rn_retTime >= ranges_retTime(i, 1) & rn_retTime <= ranges_retTime(i, 2)) = values_retTime(i);
    end 
    
    % clear delay time and generate second service time only if patient is returning
    for p = 1:N 
        if return_decisions_numeric(p) == 0
            return_delay_times(p) = 0;
            rn_retTime(p) = -1; %standardize no return random number
            rn_service2(p) = -1;
            second_service_times(p) = 0;
        else 
            
            % the original counter tables for the 2nd visit 
            curr_rn = rn_service2(p); 
            srv2_time = 0; 
            
            if triage_zones_numeric(p) == 1 % Route through Red Zone Table 
                for i = 1:length(values_serviceRed) 
                    if curr_rn >= ranges_serviceRed(i, 1) && curr_rn <= ranges_serviceRed(i, 2) 
                        srv2_time = values_serviceRed(i); 
                        break; 
                    end 
                end
                
            elseif triage_zones_numeric(p) == 2 % Route through Yellow Zone Table 
                for i = 1:length(values_serviceYellow) 
                    if curr_rn >= ranges_serviceYellow(i, 1) && curr_rn <= ranges_serviceYellow(i, 2) 
                        srv2_time = values_serviceYellow(i); 
                        break; 
                    end 
                end 
            
            elseif triage_zones_numeric(p) == 3 % Route through Green Zone Table 
                % recall which green table they used for service 1
                if green_assigned(p) == 1
                    for i = 1:length(values_serviceGreen1) 
                        if curr_rn >= ranges_serviceGreen1(i, 1) && curr_rn <= ranges_serviceGreen1(i, 2) 
                            srv2_time = values_serviceGreen1(i); 
                            break;
                        end
                    end
                    
                elseif green_assigned(p) == 2
                    for i = 1:length(values_serviceGreen2) 
                        if curr_rn >= ranges_serviceGreen2(i, 1) && curr_rn <= ranges_serviceGreen2(i, 2) 
                            srv2_time = values_serviceGreen2(i); 
                            break; 
                        end
                    end
                else
                    for i = 1:length(values_serviceGreen3) 
                        if curr_rn >= ranges_serviceGreen3(i, 1) && curr_rn <= ranges_serviceGreen3(i, 2) 
                            srv2_time = values_serviceGreen3(i); 
                            break;
                        end
                    end
                end
            end
            
            second_service_times(p) = srv2_time;
        end
    end
    
    % output data map struct 
    % passes every data to phase 3 usage
    patient_table.p_id = (1:N)';
    patient_table.rn_arr = rn_arrival';
    patient_table.int_arr = interarrival_times';
    patient_table.arr_time = arrival_times';
    patient_table.rn_zone = rn_triage';
    patient_table.zone = triage_zones_numeric'; % 1, 2, or 3
    patient_table.rn_serv1 = rn_service'; 
    patient_table.serv_time1 = pre_service_times'; 
    patient_table.rn_ret = rn_return'; 
    patient_table.needs_ret = return_decisions_numeric'; % 1 or 0 
    patient_table.rn_ret_time = rn_retTime'; 
    patient_table.ret_delay = return_delay_times'; 
    patient_table.rn_serv2 = rn_service2'; 
    patient_table.serv_time2 = second_service_times'; 
end