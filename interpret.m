function interpret(N, counter_data, service_data, final_master_log)
    
    counter_names = {'Red Zone Counter', 'Yellow Zone Counter', 'Green Zone Counter 1', 'Green Zone Counter 2', 'Green Zone Counter 3'};
    total_sim_time = max(final_master_log(:, 11));
    
    %Header of Result Interpretation Section
    disp('======================================================');
    disp('                Result Interpretation                 ');
    disp('======================================================');
    
    %Counter by counter analysis
    for c = 1:5
        fprintf('\n---------------------------------------\n');
        fprintf('      %-17s Analysis: \n', counter_names{c});
        fprintf('---------------------------------------\n');
        
        data_matrix = counter_data{c};
        service_time = service_data{c};
        
        if ~isempty(data_matrix)
            avg_wait = mean(data_matrix(:, 1));
            max_wait = max(data_matrix(:, 1));
            prob_wait = mean((data_matrix(:, 1)) > 0) * 100;
            avg_qlen = sum(data_matrix(:, 1)) / total_sim_time; 
            avg_service = mean(service_time);
            ret_rate = mean(data_matrix(:, 3)) * 100;
            ret_time = mean(data_matrix(:, 4));
            
            total_busy_time = sum(service_time);
            utilization = (total_busy_time / total_sim_time) * 100;
            
            fprintf('Average Waiting Time = %10.4f mins\n', avg_wait); %Display the average waiting time
            fprintf('Maximum Waiting Time = %10.4f mins\n', max_wait); %Display maximum waiting time
            fprintf('Percentage of Patient need to wait = %10.4f %%\n', prob_wait); %Display percentage of need to wait
            fprintf('Average Queue Length = %10.4f people\n', avg_qlen); %Display average queue length
            fprintf('Average Service Time (Including Service Time 1 & 2) = %7.4f mins\n', avg_service); %Display the average service time
            fprintf('Percentage of Patient need to return = %10.4f %%\n', ret_rate); %Display percentage of return
            fprintf('Average Return Delay Time = %10.4f mins\n', ret_time); %Display average of return delay time
            fprintf('Doctor Utilization Rate = %10.4f %%\n', utilization); %display doctor utilization rate
        else 
            disp('No patient assigned to this counter.');
        end
    end
    
    %Overall hospital analysis
    fprintf('\n---------------------------------------\n');
    fprintf('           Overall Analysis: \n');
    fprintf('---------------------------------------\n');
        
    overall_avg_hosp = mean(final_master_log(:, 13));
    overall_avg_interarrival = mean(diff(final_master_log(:, 2)));
    throughput_ph = (N / (total_sim_time / 60));
    
    fprintf('Overall Average Interarrival Time = %5.4f mins\n', overall_avg_interarrival);
    fprintf('Overall Average Time Spent in Hospital for Patient = %7.4f mins\n', overall_avg_hosp);
    fprintf('Patient Throughput Rate = %6.4f patient/hour\n', throughput_ph);
    
end