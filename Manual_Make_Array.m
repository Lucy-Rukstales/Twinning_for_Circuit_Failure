%%Read in Simulated Data and Make an Array of the Waveforms

%Read in the table
test1=readtable('Sim_N1u1_N1u2_N1u3.csv');
test2=readtable('Sim_N1u1_N1u2_N4.7u2.csv');
test3=readtable('Sim_N1u1_N4.7u1_N4.7u2.csv');
test4=readtable('Sim_N1u1_N4.7u2_N22u2.csv');
test5=readtable('Sim_N1u2_N1u3_N22u3.csv');
test6=readtable('Sim_N4.7u1_N4.7u2_N4.7u3.csv');
test7=readtable('Sim_N4.7u1_N4.7u2_N22u3.csv');
test8=readtable('Sim_N4.7u1_N22u1_N22u3.csv');
test9=readtable('Sim_N22u1_N22u2_N22u3.csv');

%Convert times to array
time1=table2array(test1(1:end-1,1)); %Convert voltage data to array
time2=table2array(test2(1:end-1,1)); %Convert voltage data to array
time3=table2array(test3(1:end-1,1)); %Convert voltage data to array
time4=table2array(test4(1:end-1,1)); %Convert voltage data to array
time5=table2array(test5(1:end-1,1)); %Convert voltage data to array
time6=table2array(test6(1:end-1,1)); %Convert voltage data to array
time7=table2array(test7(1:end-1,1)); %Convert voltage data to array
time8=table2array(test8(1:end-1,1)); %Convert voltage data to array
time9=table2array(test9(1:end-1,1)); %Convert voltage data to array

% Convert voltages to array
data1=table2array(test1(1:end-1,2));
data2=table2array(test2(1:end-1,2));
data3=table2array(test3(1:end-1,2));
data4=table2array(test4(1:end-1,2));
data5=table2array(test5(1:end-1,2));
data6=table2array(test6(1:end-1,2));
data7=table2array(test7(1:end-1,2));
data8=table2array(test8(1:end-1,2));
data9=table2array(test9(1:end-1,2));

% Convert voltages to double
data1=str2double(data1);
data2=str2double(data2);
% data3=str2double(data3);
% data4=str2double(data4);
% data5=str2double(data5);
data6=str2double(data6);
data7=str2double(data7);
data8=str2double(data8);
% data9=str2double(data9);

%New time domain
t1=[time1(1):5e-10:time1(end)];

%Interpolate each sample
v1=interp1(time1, data1, t1);
v2=interp1(time2, data2, t1);
v3=interp1(time3, data3, t1);
v4=interp1(time4, data4, t1);
v5=interp1(time5, data5, t1);
v6=interp1(time6, data6, t1);
v7=interp1(time7, data7, t1);
v8=interp1(time8, data8, t1);
v9=interp1(time9, data9, t1);

%Write waveforms to array
data=[v1; v2; v3; v4; v5; v6; v7; v8; v9];

%Save as CSV
csvwrite('SimData.CSV', data);

plot(v1)
hold on
plot(v2)
hold on
plot(v3)
hold on
plot(v4)
hold on
plot(v5)
hold on
plot(v6)
hold on
plot(v7)
hold on
plot(v8)
hold on
plot(v9)

