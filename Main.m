clear; clc;

disp('--- EmergencyDeptQueuingSystem (Phase 1) ---');
disp(' ');

% 1. ????: ?????????????? (N)
N = input('Please enter the total patient : ');

% ????????
while isempty(N) || N <= 0
    disp('Error: Number of patient must more than 0!');
    N = input('Please Re-enter the total patient! : ');
end

disp(' ');
disp('Please choose the type of random number generator to use:');
disp('1. Built-in function rand()');
disp('2. Linear Congruential Generator (LCG)');
disp('3. Exponential Random Variate Generator (ERVG)');
disp('4. Uniform Random Variate Generator (URVG)');
disp(' ');

% 2. User Input: Prompt user to choose the generator type
choice = input('Please enter your choice (1-4): ');

while isempty(choice) || choice < 1 || choice > 4
    disp('Error: Invalid choice! Please select a number between 1 and 4.');
    choice = input('Please enter your choice (1-4): ');
end

disp(' ');
% 3. Task Logic: Call the corresponding module based on user selection
switch choice
    case 1
        disp('Selected: Built-in rand() algorithm.');
        random_sequence = rand(1, 5 * N);
        
    case 2
        disp('Selected: Mixed Full-Period LCG algorithm.');
        random_sequence = LCG(5 * N); % Call LCG.m
        
    case 3
        disp('Selected: Exponential Random Variate Generator (ERVG).');
        random_sequence = ERVG(5 * N); % Call ERVG.m
        
    case 4
        disp('Selected: Uniform Random Variate Generator (URVG).');
        random_sequence = URVG(5 * N); % Call URVG.m
        
end

disp(' ');
disp('Random sequence generated successfully! The random value samples for the first 5 patients are:');

% If the total number of patients (N) is greater than or equal to 5
if N >= 5
    
    % Use a while loop to print the first 5 numbers
    counter = 1;                     % 1. Set counter to start from 1 (FreeMat matrix index starts from 1)
    while counter <= 5               % 2. Loop as long as counter is less than or equal to 5
        disp(random_sequence(counter)); % 3. Print the random number at the current position
        counter = counter + 1;       % 4. Increment the counter by 1
    end

% If the total number of patients is less than 5 (e.g., only 3 patients)
else
    
    % Print as many times as the total number of patients using a while loop
    counter = 1;
    while counter <= N               % 2. Loop as long as counter is less than or equal to N
        disp(random_sequence(counter)); 
        counter = counter + 1;
    end
end

%phase 2
disp(' ');
disp('===================================================================');
disp('--- PHASE 2: Interactive Monte Carlo Attribute Setup ---');
disp('===================================================================');
disp(' ');
%get precision threshold boundary upper bound range
maxRange = input('Enter the random number maximum range scale limit:');
disp(' ');

%triage zone assignment input
disp('----Configure Triage Zone Assignment Table----');
disp('Example label format:{''Red'', ''Yellow'', ''Green''}');
triage_labels = input('Enter zone labels as cell array:');
disp('Example probabilities format: [0.123333, 0.279345,0.983333]');
triage_probs = input('Enter matching probabilities vector:');
disp(' ');

%interarrival time table input
disp('----Configure Interarrival Time Table----');
disp('Example times format: [3,6,8,13,20]');
interarrival_values = input('Enter interarrival times vector(minutes):');
interarrival_probs = input('Enter matching probabilities vector:');
disp(' ');

%service time table input
disp('----Configure Service Time Table for Counter----');
disp('Example service times format: [10,15,20,25,30]');
service_values = input('Enter service times vector(minutes):');
service_probs = input('Enter matching probabilities vector:');
disp(' ');

%return table input
disp('----Configure Return Table(Will return or not)----');
disp('Example decision labels format: {''Yes'', ''No''}');
return_labels = input('Enter return labels as cell array:');
return_probs = input('Enter matching probabilities vector:');
disp(' ');

%return time table input
disp('----Configure Return Time Table----');
disp('Example delay times format: [15,20,30,45,60]');
return_time_values = input('Enter return delay times vector(minutes):');
return_time_probs = input('Enter matching probabilities vector:');
disp(' ');

%display all tables
[cdf_triage, ranges_triage] = printSimulationTable('4. Triage Zone Assignment Table', 'Zone', triage_labels, triage_probs, maxRange);
[cdf_arrival, ranges_arrival] = printSimulationTable('5. Interarrival Time Table', 'Interarrival Time (min)', interarrival_values, interarrival_probs, maxRange);
[cdf_service, ranges_service] = printSimulationTable('6. Service Time Table (All Counters)', 'Service Time (min)', service_values, service_probs, maxRange); 
[cdf_return, ranges_return] = printSimulationTable('7. Return Table (Will Return or Not)', 'Requires Return?', return_labels, return_probs, maxRange);
[cdf_retTime, ranges_retTime] = printSimulationTable('8. Return Time Table (Other Dept Duration)', 'Delay Time (min)', return_time_values, return_time_probs, maxRange);

%compute attributes using vectorized arrays
patients_data = precomputeAttributes(N, maxRange, random_sequence, ranges_arrival, interarrival_values, ranges_triage, triage_labels, ranges_service, service_values, ranges_return, return_labels, ranges_retTime, return_time_values);