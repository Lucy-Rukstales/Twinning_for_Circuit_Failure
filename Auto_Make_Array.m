%%Read in Simulated Data and Make an Array of the Waveforms
d=dir('Simulations');
n=length(d);
cd('Simulations')

%Read in the table
for i=4:n
    test{i-3}=readtable(d(i).name); %first two items are empty
end

% %Convert times to array
for j=1:n-3
    time{j}=table2array(test{j}(1,1:end));
    data{j}=table2array(test{j}(2,1:end));
end

%New time domain
t1=[time{1}(1):6e-10:time{1}(end)];

% %Interpolate each sample
for l=1:n-3
    v{l}=interp1(time{l}, data{l}, t1);
end

%Change to correct data type
for m=1:n-3
    g(m,:)=v{l};
end

% %Save as CSV
csvwrite('SimData.CSV', g);
% csvwrite('fileNames.CSV', fileNames);

for m=1:n-3
    plot(v{m})
    hold  on
end
