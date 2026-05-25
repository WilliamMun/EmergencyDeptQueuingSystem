###### **Introduction / Concepts**

Flow of Emergency Department in Hospital:

Patient register -> Category patient based on triage system (Red, yellow, green zone) -> Doctor consult patient for their situation -> Need to check up in other department (e.g. X-ray in radiology)? -> Yes, Go to other department then return to counter / No, discharged from hospital 



Parameters:

Red zone have 1 counter, yellow zone have 1 counter, green zone have 3 counter.

All outputs display in 6 decimal points.



###### **Program Overview / Flow**

**Phase 1: Initialization \& Parameter Generation (\*Kelvin)**

User Input: The program prompts the user to enter the total number of patients (N) to simulate.

User Input: Prompts user to choose the type of random number generator to be used in the whole system (Either rand(), LCG, ERVG or URVG)



Task:

1. Ask user input for number of patients (in main.m)
2. Code Mixed Model Linear Congruential Generators (LCG) with full period- Concepts refer Lecture Notes pg 1-3 (in LCG.m)
3. Code Random Variate Generator for Exponential Distribution (ERVG)- Concepts refer Lecture Notes pg 4 (in ERVG.m)
4. Code Random Variate Generator for Uniform Distribution (URVG)- Concepts refer Lecture Notes pg 5 (in URVG.m)
5. Ask user to choose type of random number generator to be used. (in main.m)



**Phase 2: Monte Carlo Attribute Generation (Pre-computation) (\*Zhun Rui)**

Before the clock starts, the program generates all patient attributes simultaneously using vectorized arrays:

4\. Triage Zone Assignment Table 

5\. Interarrival Time Table

6\. Service Time Table for all 5 counters 

7\. Return Table (Will return or not)

8\. Return Time Table (How long patient will take in other department)



Task:

1. Display all tables listed as above. (do in separate .m files, then call in main.m)



Sample Output (Not necessary same number as below):

========================================================

&#x20;               Triage Zone Assignment

========================================================

|Zone                |   Red    |  Yellow  |   Green  |

|Probability         | 0.133421 | 0.217893 | 0.648686 |

|CDF                 | 0.133421 | 0.351314 | 1.000000 |

|Random Number Range |   1-133  |  134-351 | 352-1000 |



=================================================================================================================================

&#x20;                                                Interarrival Time Table

=================================================================================================================================

|Interarrival Time (minutes) |     4    |     6    |     8    |    10    |    12    |    14    |    16    |    18    |    20    |

|Probability                 | 0.142857 | 0.115234 | 0.098765 | 0.123456 | 0.087654 | 0.104598 | 0.076543 | 0.134567 | 0.116326 |

|CDF                         | 0.142857 | 0.258091 | 0.356856 | 0.480312 | 0.567966 | 0.672564 | 0.749107 | 0.883674 | 1.000000 |

|Random Number Range         |   1-143  |  144-258 |  259-357 |  358-480 |  481-568 |  569-673 |  674-749 |  750-884 | 885-1000 |





**Phase 3: The Event-Driven Queue Engine (Chronological Simulation) (\*Qian Xian)**

Patient interarrival time table \& triage zone for patient: Loads all initial patient arrivals and patient zone for their respective arrival times.

Time-Step Processing: A while loop begins processing the Event List, always sorting it chronologically so it handles whichever event happens next in real time.

Counter Routing Logic:

Red Zone (1 Counter): Patient waits until the single Red counter is free.

Yellow Zone (1 Counter): Patient waits until the single Yellow counter is free.

Green Zone (3 Counters): The system checks all three Green counters and routes the patient to whichever one becomes available first.

Action \& Logging: The program calculates the patient's exact start time, wait time, and end time. It records this interaction into a central master log, tagging it with the specific Counter ID (1 through 5).

Re-entry Injection: If a patient just finished their initial visit and needs an X-ray, the system calculates their expected return time (End Time + X-ray Delay) and injects a brand-new "Return Event" into the future timeline of the Event List.

Counter-Specific Tables: The simulation loop finishes. The program filters the central master log and prints five distinct, chronologically sorted tables:

Red Counter Table

Yellow Counter Table

Green Counter 1 Table

Green Counter 2 Table

Green Counter 3 Table

(Each table shows the Patient ID, Arrival, Start, Service, End, and Wait times for that specific doctor).



Task: 

1. Display arrival time of each patient in a table. (Should have column: Patient ID, Random Number(RN) for arrival, Interarrival time, Arrival time, RN for triage zone, Triage zone)
2. Sort each patient based on their zone, display each zone counter service time table. (Should have column for each counter service time table: Patient ID, Arrival Time, RN for service time, Time service begin, Service time, RN for return, Need to return?, RN for return time, Return time, Time service continue, time service end, Waiting time, Time in system)
3. Sort green zone patient to counter 1,2,3 based on availability of each counter. 



Sample Output:

=================================================================================

&#x20;                          Interarrival Time Table

=================================================================================

|Patient ID|RN Arrival|Interarrival Time|Arrival Time|RN Triage Zone|Triage Zone|

|     1    |    -     |        -        |      0     |     572      |   Green   |

|     2    |   200    |        6        |      6     |     300      |  Yellow   |

|     3    |   538    |       12        |     18     |     793      |   Green   |

|     4    |   452    |       10        |     28     |      76      |     Red   |



============================================================================================================================================================================================

&#x20;                                                                                    Red Zone Counter

============================================================================================================================================================================================

|Patient ID|Arrival Time|RN Service|Time service begin|Service Time|RN Return|Need to return?|RN Return Time|Return Time|Time service continue|Time service end|Waiting Time|Time in hosp.|

|     4    |     28     |    456   |        28        |      32    |   367   |      No       |      -       |      -    |          -          |        60      |      0     |      32     |



============================================================================================================================================================================================

&#x20;                                                                                  Yellow Zone Counter

============================================================================================================================================================================================

|Patient ID|Arrival Time|RN Service|Time service begin|Service Time|RN Return|Need to return?|RN Return Time|Return Time|Time service continue|Time service end|Waiting Time|Time in hosp.|

|     2    |      6     |    278   |         6        |      24    |   896   |     Yes       |     672      |    20     |         50          |        74      |      0     |      68     |





**Phase 4: Data Formatting \& Output + Report (\*William)**

System Evaluation Metrics: Finally, the program calculates and displays:

Average Wait Time: Across all interactions (initial and returns).

Average Queue Length: Calculated using Little's Law (Total wait time divided by total simulation time).

Server Utilization: The percentage of the total shift each zone's counters spent actively treating patients.



