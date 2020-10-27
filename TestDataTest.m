% Read Test Data into simulated, read in data (observed), find closest
% solution

clear
clc
close all

simulated=readtable('TestData.CSV');
simulated=table2array(simulated(:,1:4e4));

capacitance=[{'N27.7'} {'N3'} {'N6.7'} {'N10.4'} {'N14.1'} {'N31.4'} {'N48.7'} {'N66'} {'N24'} {'K14.1'} {'K31.4'} {'K48.7'} {'K66'}];

observed=readtable('13Oct_Test6.CSV');
observed=table2array(observed(3:end,5));
observed=str2double(observed(1:length(simulated)));
observed=observed';

%% Shift Observed Signal to match peak of simulated signal
for r=1:13
    [xc lags] = xcorr(observed, simulated(r,:));
    index=find(xc==max(xc)); % index of max cross correlation value
    shift=lags(index); % shift the function by this amount
    if shift>0
        obs(r,:)=[observed(shift+1:end) zeros(1,shift)];
        obs(r,:)=obs(r,1:length(simulated));%trim to size
    else
        obs(r,:)=observed;
        simulated(r,:)=[simulated(r,abs(shift)+1:end) zeros(1,abs(shift))];
        simulated(r,:)=simulated(r,1:length(simulated));
    end
end

%% RMS Error

for l=1:13
    firstZero=find(obs(l,:)==0);
    firstZero=firstZero(1)-1;
    RMSerror(l)=sqrt(sum((obs(l,1:firstZero)-simulated(l,1:firstZero)).^2)/length(simulated));
end

plot(RMSerror)
xlabel('Capacitance Index');
ylabel('RMS Error')
title('RMS Error vs. Capacitance Index')

solIndex=find(RMSerror==min(RMSerror));
solution=capacitance(solIndex)