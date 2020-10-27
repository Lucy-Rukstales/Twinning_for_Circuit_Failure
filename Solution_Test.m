% Generate simulated signals (f), read in data (observed), find closest
% solution

clear
clc
close all

e=[0:0.2:2];
x=[0:0.05:2];

%% Generate Simulated Signals
for i=1:length(e)
    for j=1:length(x)
        simulated(i,j)=cosd(1e10*x(j))*exp(-e(i)*x(j)) + 5;
    end
end

%% Generate Observed Signal
for g=1:length(x)
    observed(g)= cosd(1e10*x(g))*exp(-0.8*x(g)) + 5 + 0.4*rand(1,1);
end

observed=[zeros(1,4) observed]; % shift the signal to mimick actual observed function
observed=observed(1:length(simulated)); %trim to size

%% Shift Observed Signal to match peak of simulated signal
for r=1:i
    [xc lags] = xcorr(observed, simulated(r,:));
    index=find(xc==max(xc)); % index of max cross correlation value
    shift=lags(index); % shift the function by this amount
    obs(r,:)=[observed(shift+1:end) zeros(1,shift)];
    obs(r,:)=obs(r,1:length(simulated));%trim to size
end

%% RMS Error

for l=1:i
    firstZero=find(obs(l,:)==0);
    firstZero=firstZero(1)-1;
    RMSerror(l)=sqrt(sum((obs(l,1:firstZero)-simulated(l,1:firstZero)).^2)/length(simulated));
end

plot(e,RMSerror)
xlabel('e');
ylabel('RMS Error')
title('RMS Error vs. e Value')

solIndex=find(RMSerror==min(RMSerror));
solution=e(solIndex)