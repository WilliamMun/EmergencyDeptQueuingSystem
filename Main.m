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
        random_sequence = rand(1, N);
        
    case 2
        disp('Selected: Mixed Full-Period LCG algorithm.');
        random_sequence = LCG(N); % Call LCG.m
        
    case 3
        disp('Selected: Exponential Random Variate Generator (ERVG).');
        random_sequence = ERVG(N); % Call ERVG.m
        
    case 4
        disp('Selected: Uniform Random Variate Generator (URVG).');
        random_sequence = URVG(N); % Call URVG.m
        
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