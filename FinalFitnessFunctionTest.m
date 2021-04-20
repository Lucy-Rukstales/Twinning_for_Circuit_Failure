% Fitness Function First Attempt
% Read Test Data into simulated, read in data (observed), find closest
% solution
% Uses RMS Error

clear
clc
close all

% Read-in Testbench ("simulated") Waveform Data
simulated=readtable('SimData.CSV');
simulated=table2array(simulated(:,1:end));

% Available Capacitance Values for Testbench Waveforms
capacitance=[{'N3'} {'N6.7'} {'N10.4'} {'N27.7'} {'N24'} {'N14.1'} {'N31.4'} {'N48.7'} {'N66'}];

% Read-in Observed Signal Data
observed=readtable('SDS00049.CSV');
observed=table2array(observed(3:end,5));
observed=str2double(observed(1:length(simulated)));
observed=observed';

%% Shift Observed Signal to match peak of simulated signal
for r=1:9 %Number of available "simulated" waveforms
    [xc lags] = xcorr(observed, simulated(r,:));
    index=find(xc==max(xc)); % index of max cross correlation value
    shift=lags(index); % shift size
    if shift>0 % if positive shift size, shift the observed funciton to the left
        obs=observed(1,shift+1:end);
        simulatedNew=simulated(r,1:length(obs(1,:)));
    else % if negative shift size, shift the simulated function to the left
        simulatedNew=simulated(r,abs(shift)+1:end);
        obs=observed(1,1:length(simulatedNew(1,:)));
    end
    RMSerror(r)=sqrt(sum((obs-simulatedNew).^2)/length(simulatedNew));
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
plot(simulated(8,:), 'Linewidth', 0.8)
legend('Generated Solution', 'Observed', 'Actual Solution')
title('48.7uF')
xlabel('Time (s)')
ylabel('Voltage (V)')

display(shift)

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