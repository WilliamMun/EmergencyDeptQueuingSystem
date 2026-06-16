function master_log = QueueEngine(N, patient_table)
    % receive data
    p_id = patient_table.p_id;
    rn_arr = patient_table.rn_arr;
    int_arr = patient_table.int_arr;
    rn_zone = patient_table.rn_zone; 
    zone = patient_table.zone; 
    rn_serv1 = patient_table.rn_serv1; 
    serv_time1 = patient_table.serv_time1; 
    rn_ret = patient_table.rn_ret; 
    needs_ret = patient_table.needs_ret; 
    rn_ret_time = patient_table.rn_ret_time; 
    ret_delay = patient_table.ret_delay; 
    serv_time2 = patient_table.serv_time2; 
    
    %display interarrival table column name
    fprintf('=================================================================================\n');
    fprintf('                               Interarrival Time Table\n');
    fprintf('=================================================================================\n');
    fprintf('|Patient ID|RN Arrival|Interarrival Time|Arrival Time|RN Triage Zone|Triage Zone|\n');
    zone_names ={'Red','Yellow','Green'};
    
    for i = 1:N
        rn_a_str = sprintf('%d', rn_arr(i)); if rn_arr(i) == -1, rn_a_str = '-'; 
        end 
        
        int_a_str = sprintf('%d', int_arr(i)); if i == 1, int_a_str = '-'; 
        end 
        
        fprintf('| %8d | %10s | %17s | %12d | %14d | %11s |\n', p_id(i), rn_a_str, int_a_str, arr_time(i), rn_zone(i), zone_names{zone(i)}); 
        
    end
    fprint('\n');
    
    %queue system
    
    counter_avail = [0,0,0,0,0];
    
    % master matrix structure
    master_log = zeros(N, 14); 
    master_log(:, 1:9) = [p_id, arr_time, rn_serv1, zeros(N,2), rn_ret, needs_ret, rn_ret_time, ret_delay]; 
    master_log(:, 10) = -1; 
    
    event_list = [arr_time, p_id, ones(N, 1)]; 
    doc_assigned = zeros(N, 1); 
    
    % queue engine based on time
    while size(event_list, 1) > 0 
        event_list = sortrows(event_list, 1); 
        
        curr_time = event_list(1, 1); 
        curr_id = event_list(1, 2); 
        v_type = event_list(1, 3); 
        event_list(1, :) = []; 
        
        p_zone = zone(curr_id); 
        
        if v_type == 1 
            if p_zone == 1
                c_idx = 1;
            elseif p_zone == 2
                c_idx = 2;
            elseif p_zone == 3
                [~, min_g] = min(counter_avail(3:5)); 
                c_idx = 2 + min_g; 
            end
            
            doc_assigned(curr_id) = c_idx; 
            master_log(curr_id, 14) = c_idx; 
            
            start_time = max(curr_time, counter_avail(c_idx)); 
            wait1 = start_time - curr_time; 
            end_time = start_time + serv_time1(curr_id); 
            counter_avail(c_idx) = end_time; 
            
            master_log(curr_id, 4) = start_time; 
            master_log(curr_id, 5) = serv_time1(curr_id); 
            master_log(curr_id, 11) = end_time; 
            master_log(curr_id, 12) = wait1; 
            
            if needs_ret(curr_id) == 1
                t_return = end_time + ret_delay(curr_id);
                event_list = [event_list; t_return, cuur_id, 2];
            else
                master_log(curr_id,13) = end_time - arr_time(curr_id);
            end
            
        else
            c_idx = doc_assigned(curr_id);
            
            start_time = max(curr_time, counter_avail(c_idx));
            wait2 = start_time - curr_time; 
            end_time = start_time + serv_time2(curr_id); 
            counter_avail(c_idx) = end_time; 
            
            master_log(curr_id, 10) = start_time; 
            master_log(curr_id, 11) = end_time; 
            master_log(curr_id, 12) = master_log(curr_id, 12) + wait2; 
            master_log(curr_id, 13) = end_time - arr_time(curr_id); 
            
        end
    end
    
    %print final counter table
    counter_name = {'Red Zone Counter', 'Yellow Zone Counter', 'Green Zone Counter 1', 'Green Zone Counter 2', 'Green Zone Counter 3'};
    
    for c = 1:5
        patients_in_counter = find(master_log(:, 14) == c);
        if isempty(patients_in_counter) 
            continue 
        end
        
        fprintf('============================================================================================================================================================================================\n');
        fprintf('                                                                                             %s\n', counter_names{c});  
        fprintf('============================================================================================================================================================================================\n'); 
        fprintf('|Patient ID|Arrival Time|RN Service|Time service begin|Service Time|RN Return|Need to return?|RN Return Time|Return Time|Time service continue|Time service end|Waiting Time|Time in hosp.|\n'); 
        
        for idx = 1:length(patients_in_counter) 
            pid = patients_in_counter(idx); 
            row = master_log(pid, :); 
            
            ret_str = 'No'; if row(7) == 1, ret_str = 'Yes'; end 
            rn_rt_str = sprintf('%d', row(8)); if row(8) == -1, rn_rt_str = '-'; end 
            rt_str = sprintf('%d', row(8)); if row(7) == 0, rt_str = '-'; end 
            cont_str = sprintf('%d', row(10)); if row(10) == -1, cont_str = '-'; end 
            
            fprintf('| %8d | %12d | %10d | %18d | %12d | %9d | %13s | %14s | %11s | %21s | %16d | %12d | %13d |\n', row(1), row(2), row(3), row(4), row(5), row(6), ret_str, rn_rt_str, rt_str, cont_str, row(11), row(12), row(13)); 
        end
        fprintf('\n');
    end
    