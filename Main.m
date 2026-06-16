clear; clc; 
jitcontrol off;

disp('--- EmergencyDeptQueuingSystem (Phase 1) ---'); 
disp(' ');  

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

% 3. Task Logic: Call the corresponding module based on user selection
switch choice
    case 1
        disp('Selected: Built-in rand() algorithm.');
        random_sequence = rand(1, 6 * N);
        
    case 2
        disp('Selected: Mixed Full-Period LCG algorithm.');
        random_sequence = LCG(6 * N); % Call LCG.m
        
    case 3
        disp('Selected: Exponential Random Variate Generator (ERVG).');
        random_sequence = ERVG(6 * N); % Call ERVG.m
        
    case 4
        disp('Selected: Uniform Random Variate Generator (URVG).');
        random_sequence = URVG(6 * N); % Call URVG.m
        
end

%phase 2
    disp(' ');
    disp('Generating simulation tables...');

%triage zone assignment 
values_triage = {'Red', 'Yellow', 'Green'};
prob_triage = sort(generateRandomProbabilities(3));
[cdf_triage, ranges_triage] = printSimulationTable('Table 1: Triage Zone Assignment', 'Zone', values_triage, prob_triage, maxRange);
disp(' ');

%interarrival time table 
values_arrival = [1, 2, 3, 4, 5];
prob_arrival = generateRandomProbabilities(5);
[cdf_arrival, ranges_arrival] = printSimulationTable('Table 2: Interarrival Time (minutes)', 'Time', values_arrival, prob_arrival, maxRange);
disp(' ');

% red zone counter service time table 
values_serviceRed = [8, 10, 12, 14, 16];
prob_serviceRed = generateRandomProbabilities(5);
[cdf_serviceRed, ranges_serviceRed] = printSimulationTable('Table 3: Red Zone Counter Service Time (minutes)', 'Time', values_serviceRed, prob_serviceRed, maxRange);
disp(' ');

%yellow zone counter service time table
values_serviceYellow = [5, 7,9 ,11 ,13];
prob_serviceYellow = generateRandomProbabilities(5);
[cdf_serviceYellow, ranges_serviceYellow] = printSimulationTable('Table 4: Yellow Zone Counter Service Time (minutes)', 'Time', values_serviceYellow, prob_serviceYellow, maxRange);
disp(' ');

%green zone counter1 service time table
values_serviceGreen1 = [3, 5, 7, 9];
prob_serviceGreen1 = generateRandomProbabilities(4);
[cdf_serviceGreen1, ranges_serviceGreen1] = printSimulationTable('Table 5: Green Zone Counter 1 Service Time (minutes)', 'Time', values_serviceGreen1, prob_serviceGreen1, maxRange);
disp(' ');

%green zone counter2 service time table
values_serviceGreen2 = [4, 6, 8, 10];
prob_serviceGreen2 = generateRandomProbabilities(4);
[cdf_serviceGreen2, ranges_serviceGreen2] = printSimulationTable('Table 6: Green Zone Counter 2 Service Time (minutes)', 'Time', values_serviceGreen2, prob_serviceGreen2, maxRange);
disp(' ');

%green zone counter3 service time table
values_serviceGreen3 = [2, 4, 6, 8, 10];
prob_serviceGreen3 = generateRandomProbabilities(5);
[cdf_serviceGreen3, ranges_serviceGreen3] = printSimulationTable('Table 7: Green Zone Counter 3 Service Time (minutes)', 'Time', values_serviceGreen3, prob_serviceGreen3, maxRange);
disp(' ');

%return decisions table
values_return = {'Yes','No'};
prob_return = generateRandomProbabilities(2);
[cdf_return, ranges_return] = printSimulationTable('Table 8: Return Decision', 'Decision', values_return, prob_return, maxRange);
disp(' ');

%return delay time table
values_retTime = [5, 10, 15, 20, 25];
prob_retTime = generateRandomProbabilities(5);
[cdf_retTime, ranges_retTime] = printSimulationTable('Table 9: Return Delay Time (minutes)', 'Time', values_retTime, prob_retTime, maxRange);
disp(' ');

values_service = [5, 7, 10, 12, 15];
prob_service = generateRandomProbabilities(5);
[cdf_service, ranges_service] = printSimulationTable('Table (internal): Generic Service Time', 'Time', values_service, prob_service, maxRange);
patient_table = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime);
disp('Simulation setup complete.');

patient_table = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, values_arrival, ranges_triage, values_triage, ranges_serviceRed, values_serviceRed, ranges_serviceYellow, values_serviceYellow, ranges_serviceGreen1, values_serviceGreen1, ranges_serviceGreen2, values_serviceGreen2, ranges_serviceGreen3, values_serviceGreen3, ranges_return, values_return, ranges_retTime, values_retTime); 
disp('Simulation setup complete.'); 
disp(' ');

disp('Executing Phase 3: Event-Driven Queue Engine...'); 
disp(' ');

final_master_log = QueueEngine(N, patient_table);