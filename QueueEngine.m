function master_log = QueueEngine(N, patient_table)
    % receive data
    p_id = patient_table.p_id;
    rn_arr = patient_table.rn_arr;
    int_arr = patient_table.int_arr;
    arr_time = patient_table.arr_time;
    rn_zone = patient_table.rn_zone; 
    zone = patient_table.zone; 
    rn_serv1 = patient_table.rn_serv1; 
    serv_time1 = patient_table.serv_time1; 
    rn_ret = patient_table.rn_ret; 
    needs_ret = patient_table.needs_ret; 
    rn_ret_time = patient_table.rn_ret_time; 
    ret_delay = patient_table.ret_delay; 
    serv_time2 = patient_table.serv_time2; 
    
    %display  patient RN and their values returned
    
    fprintf('=========================================================================================\n'); 
    fprintf('                       TABLE 1: PATIENT RANDOM NUMBERS \n'); 
    fprintf('=========================================================================================\n'); 
    fprintf('| Pat ID | RN Arr | RN Zone | RN Ser 1 | RN Ret | RN Ret T | RN Ser 2 |\n'); 
    fprintf('-----------------------------------------------------------------------------------------\n'); 
    
    for i = 1:N 
        rn_a_str = sprintf('%d', rn_arr(i)); if rn_arr(i) == -1, rn_a_str = '-'; end 
        rn_rt_str = sprintf('%d', rn_ret_time(i)); if rn_ret_time(i) == -1, rn_rt_str = '-'; end 
        rn_s2_val = patient_table.rn_serv2(i); 
        rn_s2_str = sprintf('%d', rn_s2_val); if rn_s2_val == -1, rn_s2_str = '-'; end 
        
        fprintf('| %6d | %6s | %7d | %8d | %6d | %8s | %8s |\n', p_id(i), rn_a_str, rn_zone(i), rn_serv1(i), rn_ret(i), rn_rt_str, rn_s2_str); 
        
    end
    
    fprintf('=========================================================================================\n\n'); 
    
    fprintf('====================================================================================================\n'); 
    fprintf('                       TABLE 2: PATIENT MAPPED VALUES \n'); 
    fprintf('====================================================================================================\n'); 
    fprintf('| Pat ID | Int Arr | Arr Time | Zone | Ser Time 1 | Will Ret? | Ret Delay | Ser Time 2 |\n'); 
    fprintf('----------------------------------------------------------------------------------------------------\n'); 
    
    zone_names = {'Red', 'Yellow', 'Green'}; 
    for i = 1:N 
        int_a_str = sprintf('%d', int_arr(i)); if i == 1, int_a_str = '-'; end 
        ret_str = 'No'; if needs_ret(i) == 1, ret_str = 'Yes'; end 
        ret_d_str = sprintf('%d', ret_delay(i)); if needs_ret(i) == 0, ret_d_str = '-'; end 
        ser2_str = sprintf('%d', serv_time2(i)); if needs_ret(i) == 0, ser2_str = '-'; end 
        
        fprintf('| %6d | %7s | %8d | %6s | %10d | %9s | %9s | %10s |\n', p_id(i), int_a_str, arr_time(i), zone_names{zone(i)}, serv_time1(i), ret_str, ret_d_str, ser2_str); 
    end
    fprintf('====================================================================================================\n\n');

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
        [dummy_sort, sorted_indices] = sort(event_list(:, 1)); 
        event_list = event_list(sorted_indices, :);
        
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
                [dummy_value, min_g] = min(counter_avail(3:5)); 
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
                event_list = [event_list; t_return, curr_id, 2];
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
    counter_names = {'Red Zone Counter', 'Yellow Zone Counter', 'Green Zone Counter 1', 'Green Zone Counter 2', 'Green Zone Counter 3'};
    
    for c = 1:5
        patients_in_counter = find(master_log(:, 14) == c);
        if isempty(patients_in_counter) 
            continue 
        end
        
        fprintf('=================================================================================================================================\n'); 
        fprintf('                                             %s\n', counter_names{c}); 
        fprintf('=================================================================================================================================\n'); 
        fprintf('| Pat ID | Arr Time | S1 Begin | S1 Time | S1 End | Will Ret? | Ret Delay | S2 Begin | S2 Time | S2 End | Wait Time | Hosp Time |\n'); 
        fprintf('---------------------------------------------------------------------------------------------------------------------------------\n'); 
        
        for idx = 1:length(patients_in_counter) 
            pid = patients_in_counter(idx); 
            row = master_log(pid, :); 
            
            % Calculate Service 1 End 
            s1_end = row(4) + row(5); 
            
            ret_str = 'No'; if row(7) == 1, ret_str = 'Yes'; end 
            ret_delay_str = sprintf('%d', row(9)); if row(7) == 0, ret_delay_str = '-'; end 
            
            s2_begin_str = sprintf('%d', row(10)); if row(10) == -1, s2_begin_str = '-'; end 
            s2_time_str = sprintf('%d', row(11) - row(10)); if row(10) == -1, s2_time_str = '-'; end 
            s2_end_str = sprintf('%d', row(11)); if row(10) == -1, s2_end_str = '-'; end 
            
            fprintf('| %6d | %8d | %8d | %7d | %6d | %9s | %9s | %8s | %7s | %6s | %9d | %9d |\n',row(1), row(2), row(4), row(5), s1_end, ret_str, ret_delay_str, s2_begin_str, s2_time_str, s2_end_str, row(12), row(13)); 
        end
        fprintf('\n');
    end 