clear; clc; 
jitcontrol off;

%========================================================================================================
%Random Number Generator and User Input
%========================================================================================================

disp(' ');
disp('==========================================================================================='); 
disp('                  HOSPITAL EMERGENCY DEPARTMENT QUEUING SYSTEM SIMULATION                   ');
disp('===========================================================================================');

N = 0;

while isempty(N) || N <= 0 
    
    if N < 0 
        disp('Error'); 
    end  
    
    N = input('Please enter the total patient : '); 
end 

maxRange = 100;

disp(' ');
disp('Please choose the type of random number generator to use:');
disp('1. Built-in function rand()');
disp('2. Linear Congruential Generator (LCG)');
disp('3. Exponential Random Variate Generator (ERVG)');
disp('4. Uniform Random Variate Generator (URVG)');
disp(' ');

choice = input('Please enter your choice (1-4): ');

while isempty(choice) || choice < 1 || choice > 4
    disp('Error');
    choice = input('Please reenter choice (1-4): ');
end

switch choice
    case 1
        disp('Selected: Built-in rand() algorithm.');
        random_sequence = rand(1, 7 * N);
        
    case 2
        disp('Selected: Mixed Full-Period LCG algorithm.');
        random_sequence = LCG(7 * N); % Call LCG.m
        
    case 3
        disp('Selected: Exponential Random Variate Generator (ERVG).');
        random_sequence = ERVG(7 * N); % Call ERVG.m
        
    case 4
        disp('Selected: Uniform Random Variate Generator (URVG).');
        random_sequence = URVG(7 * N); % Call URVG.m
        
end

%========================================================================================================
%Generate setup table
%========================================================================================================

disp(' ');
disp('Generating simulation tables...');

[ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime] = generatePreqTable(maxRange);

patient_table = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime);
disp('Simulation setup complete.');
disp(' ');

%========================================================================================================
%Generate service table for each counter
%========================================================================================================

[final_master_log, counter_data, service_data] = QueueEngine(N, patient_table);

%========================================================================================================
%Result interpretation
%========================================================================================================

interpret(N, counter_data, service_data, final_master_log);