% Fitness Function First Attempt
% Read Test Data into simulated, read in data (observed), find closest
% solution

clear
clc
close all

% Read-in Testbench Waveform Data
simulated=readtable('TestData.CSV');
simulated=table2array(simulated(:,1:4e4));

% Available Capacitance Values for Testbench Waveforms
capacitance=[{'N27.7'} {'N3'} {'N6.7'} {'N10.4'} {'N14.1'} {'N31.4'} {'N48.7'} {'N66'} {'N24'} {'K14.1'} {'K31.4'} {'K48.7'} {'K66'}];

% Read-in Observed Signal Data
observed=readtable('13Oct_Test6_24uF.CSV');
observed=table2array(observed(3:end,5));
observed=str2double(observed(1:length(simulated)));
observed=observed';

%% Shift Observed Signal to match peak of simulated signal
for r=1:13
    [xc lags] = xcorr(observed, simulated(r,:));
    index=find(xc==max(xc)); % index of max cross correlation value
    shift=lags(index); % shift size
    if shift>0 % if positive shift size, shift the observed funciton
        obs(r,:)=[observed(shift+1:end) zeros(1,shift)]; %shift the function
        obs(r,:)=obs(r,1:length(simulated));%trim to size
    else % if negative shift size, shift the simulated function
        obs(r,:)=observed;
        simulated(r,:)=[simulated(r,abs(shift)+1:end) zeros(1,abs(shift))];
        simulated(r,:)=simulated(r,1:length(simulated));
    end
end

%% RMS Error
% do not take RMS Error where the waveforms flatline (due to shifting)
for l=1:13
    if shift>0
        firstZero=find(obs(l,:)==0);
        firstZero=firstZero(1)-1;
        RMSerror(l)=sqrt(sum((obs(l,1:firstZero)-simulated(l,1:firstZero)).^2)/length(simulated));
    else
        firstZero=find(simulated(l,:)==0);
        firstZero=firstZero(1)-1;
        RMSerror(l)=sqrt(sum((obs(l,1:firstZero)-simulated(l,1:firstZero)).^2)/length(simulated));
    end
end

plot(RMSerror)
xlabel('Capacitance Index');
ylabel('RMS Error')
title('RMS Error vs. Capacitance Index')

solIndex=find(RMSerror==min(RMSerror));
solution=capacitance(solIndex)

figure
plot(simulated(solIndex,:), 'Linewidth', 0.8)
hold on
plot(observed, 'Linewidth', 0.8)
hold on
plot(simulated(9,:), 'Linewidth', 0.8)
legend('Generated Solution', 'Observed', 'Actual Solution')
title('Test 6 24uF')
xlabel('Time (s)')
ylabel('Voltage (V)')

%% PLOT PARAMETERS
% Figure Properties:
    AxisFontSize        = 14;
    ImageSize           = [0 0 5 3]; % Width x Height
    PlotLineWidth       = 12;
    BorderGridLineWidth = 1.3;
%% PLOT APPEARANCE
    set(gca,'fontsize', AxisFontSize, ...
            'fontweight', 'bold',...
            'FontName','Times',...
            'LineWidth',BorderGridLineWidth,...
            'XGrid','on', ...
            'YGrid','on');
    set(gcf,'PaperUnits', 'inches',...
'PaperPosition', ImageSize);