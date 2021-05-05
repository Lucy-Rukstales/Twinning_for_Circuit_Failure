# Twinning_for_Circuit_Failure
### Arduino_Read.ino
7/29/2020 - Lucy added Arduino_Read.ino
  - Collects and stores 100 12-bit samples, from the FPGA
### Arduino_Write_12bit.v
7/29/2020 - Lucy updated Arduino_Write_12bit.v
  - Sends a single 12-bit sample from the FPGA to the Arduino
  - A child of Data_Collector.v
### Auto_Make_Array.m
4/20/21 - Gillian added Auto_Make_Array.m
  - This can be used to make an array for a large number of "simulated" csv files
### BoostConverterCalculations.m
  - Not used in the final implementation
### Commented_Tabu_Example_Problem.m
01/31/2021 - Gillian added Commented_Tabu_Example_Problem.m
  -  MATLAB Solution to Tabu Search Problem from IJNME Paper from Semester 1 - includes Comments
### Data_Collector.v
8/4/2020 - Lucy updated Data_Collector.v
  - A parent of Arduino_Write_12bit.v and Fast_ADC_Read_12bit.v
  - This should be used as reference for the Tabu Search Algorithm
### Fast_ADC_Read_12bit.v
### Fast_ADC_Tester.v
### FinalFitnessFunctionTest.m
4/20/21 - Gillian added FinalFitnessFunctionTest.m
  - Final Algorithm and Fitness Function, implemented in MATLAB
  - This should be used as the reference for translation to Arduino
### FitnessFunctionTest.m
  - Not used in the final implementation
### FitnessFunctionTest_Sem2.m
02/07/2021 - Gillian added FitnessFunctionTest_Sem2.m
  - Working fitness function code for second semester
  - Not used in the final implementation
### Manual_Make_Array
4/20/21 - Gillian added Manual_Make_Array
  - This can be used to manually make an array for a reasonable number of "simulated" csv files
### Slow_ADC_Read_12bit.v
8/4/2020 - Lucy updated Slow_ADC_Read_12bit.v
  - Collects a single 12-bit sample from the 100kHz ADC
  - An optional child of Data_Collector.v
### Solution_Test.m
  - Not used in the final implementation
### TabuSearch.cpp
### TabuSearch.m
  - Not used in the final implementation
### TabuSearchExample.cpp
### Tabu_MichaelaSolution_Modified.m
  - Not used in the final implementation
### TestDataTest.m
  - Not used in the final implementation
