%%The second script uses the first function to plot NPV versus varying design variables to find the best possible configuration

clear;
clc;
close all
 
T1 = 353;
T = 353:0.5:403;
P = 10.13:0.01:40.52;
 
P1 = 10.13;
P3 = P1*4;
P2 = (P1+P3)/2;
 
MR11 = 7;
MR12 = 8;
MR13 = 9;
MR14 = 10;
 
MR21 = 2.5;
MR22 = 2;
MR23 = 1.5;
MR24 = 1;
 
 
X_O2 = 0.3:0.01:0.99;
 
Recovery_DMC = .356;
Recovery_Me = 0;
Recovery_H2O = .66;
 
%Plot V vs. Conversion at 3 Temperatures & Pressures
for i = 1:length(X_O2)
    %Vary MR1
    [NPV1(i),NPVP1(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR11,MR21,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV2(i),NPVP2(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR12,MR21,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV3(i),NPVP3(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR13,MR21,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV4(i),NPVP4(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR14,MR21,Recovery_DMC,Recovery_Me,Recovery_H2O);
    %Vary MR2
    [NPV5(i),NPVP5(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR14,MR21,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV6(i),NPVP6(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR14,MR22,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV7(i),NPVP7(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR14,MR23,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV8(i),NPVP8(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),MR14,MR24,Recovery_DMC,Recovery_Me,Recovery_H2O);
end
for i = 1:length(T)
    %Vary Temperature
    [NPV9(i),NPVP9(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T(i),P1,0.74,MR14,MR22,Recovery_DMC,Recovery_Me,Recovery_H2O);
end
for i = 1:length(P)
%Vary Pressure
    [NPV10(i),NPVP10(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(403,P(i),0.74,MR14,MR22,Recovery_DMC,Recovery_Me,Recovery_H2O);
end
figure('DefaultAxesFontSize',12)
plot(X_O2,NPV1,'LineWidth',2)
hold on
plot(X_O2,NPV2,'LineWidth',2)
hold on
plot(X_O2,NPV3,'LineWidth',2)
hold on
plot(X_O2,NPV4,'LineWidth',2)
legend('MR1 = 7 MR2 = 2.5','MR1 = 8 MR2 = 2.5','MR1 = 9 MR2 = 2.5','MR1 = 10 MR2 = 2.5')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_p_r_o_j (MM $)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,NPV5,'LineWidth',2)
hold on
plot(X_O2,NPV6,'LineWidth',2)
hold on
plot(X_O2,NPV7,'LineWidth',2)
hold on
plot(X_O2,NPV8,'LineWidth',2)
legend('MR1 = 10 MR2 = 2.5','MR1 = 10 MR2 = 2','MR1 = 10 MR2 = 1.5','MR1 = 10 MR2 = 1')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_p_r_o_j (MM $)')
 
% NPV vs conversion varying T
 
figure('DefaultAxesFontSize',12)
plot(T-273,NPV9,'r','LineWidth',2)
xlabel('Reactor Temperature (Deg C)')
ylabel('NPV_p_r_o_j (MM $)')
ylim([90 max(NPV9)])
 
% NPV vs conversion varying P
 
figure('DefaultAxesFontSize',12)
plot(P./1.013,NPV10,'LineWidth',2)
xlabel('Reactor Pressure (atm)')
ylabel('NPV_p_r_o_j (MM $)')
ylim([121 max(NPV10)])
xlim([10 40])
