# Wi-5-Smart-AP-Selection
This repository includes the source codes of the smart AP selection algorithm developed by LJMU.

Some instructions related to the execution of smart AP selection code are provided below:

In the file initParameters, the following input parameter can be selected:

ROI = size of the area (e.g., ROI=100 means an area 100m x 100m)
nAPs_actual = number of APs
nSTAs = number of flows (a flows can be randomly generated to be active in any station, so more than one flow can correspond to the same station. For each flow a bit rate included between 40kbps and 2Mbps is randomly selected)
APs_minDist = minimum distance between APs in meters

Note that the default values (i.e., ROI = 300, nAPs_actual = 15, nSTAs = 400, APs_minDist = 20 represent a dense environment, so if one wants to change any of these values, the other ones have to be changed in a proportional way)

In the file mainRun_comparison, set the following parameters:

"stop" must be = nSTAs*3 (for instance, if nSTAs = 100, one must select stop=300. The reason is that the simulator has been implemented to simulate time. In the default version the time is no needed for the aims of Wi5 project and it is no active)
Look for the parameter "flag_AP = zeros(1,x);" and be sure that x = nAPs_actual. So if nAPs_actual = 50, you must have flag_AP = zeros(1,50);

In order to execute the algorithm run the script: mainRun_comparison

At the end of the simulation you will achieve the following files:

performance_results_flow_ff.mat
performance_results_flow_sinr.mat

Run the command "clear"

Then open the file "performance_results_flow_ff.mat"
and open the file "performance_results_flow_sinr.mat"

You will see the following 4 arrays in the workspace:

DATARATE_FF is an array with a number of elements equal to the number you selected as "nSTAs" and each element represents the data rate assigned to each flow based on the FF algorithm
DATARATE_SINR is an array with a number of elements equal to the number you selected as "nSTAs" and each element represents the data rate assigned to each flow based on the maximum SINR

REQ_FF and REQ_SINR are arrays with a number of elements equal to the number you selected as "nSTAs" and each element represents the bit rate required by each flow

Using these arrays you can compute any kind of performance analysis you wish. For instance, the following satisfaction metric can be easily computed through the above arrays:

Average Satisfaction: This is the average percentage of flows connected to the network with their served data bit rates higher than or equal to their given requirements.

