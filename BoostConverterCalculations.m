%% Boost converter calculations
Vs = 14;
Vout = 28;
Rl = 1000;
C = 20e-6;
esr = 40e-3;
L = 43e-6;
D = 0.5;
fs = 150e3;

Il = Vs/((1-D)^2*Rl);
deltI = Vs*D/(L*fs);
ilmin = Il - deltI/2; 
ilmax = Il + deltI/2;

deltVout_esr = ilmax*esr;

C = linspace(8e-8, 20e-6, 1000);
for i=1:1:1000
rippleVoltage(i) = Vout*D/(Rl*C(i)*fs);
end

plot(C, rippleVoltage)
xlabel('Capacitance Value (F)')
ylabel('Ripple Voltage (V)')
title('Ripple Voltage vs. Capacitance From Hart Equations')

C = D/(Rl*(1/28)*fs);
