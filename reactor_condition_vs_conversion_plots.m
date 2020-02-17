%%The third MATLAB script uses the first function to plot graphs that model reactor conditions at different conversion values.

clear;
clc;
close all
 
T1 = 353;
T2 = 378;
T3 = 403;
 
P1 = 10.13;
P3 = P1*4;
P2 = (P1+P3)/2;
 
X_O2 = 0.01:0.01:0.99;
MR1 = 2:0.5:15;
MR2 = 2:0.5:10;
 
Recovery_DMC = .356;
Recovery_Me = 0;
Recovery_H2O = .66;
 
%Plot V vs. Conversion at 3 Temperatures & Pressures
for i = 1:length(X_O2)
    [NPV(i),NPVP(i),V_reactor1(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T1,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor2(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T2,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor3(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T3,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor4(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T1,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor5(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T1,P2,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor6(i),~,~,~,~,~,~,~,~,~,y_O2(i),y_CO(i),y_CO2(i),x_Me(i),x_H2O(i),x_DMC(i)] = DMCPlantGraphsFun(T1,P3,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV(i),NPVP(i),V_reactor7(i),F_Me(i),F_O2(i),F_CO(i),P_Me(i),P_O2(i),P_CO(i),P_CO2(i),P_H2O(i),P_DMC(i),y_O21(i),y_CO1(i),y_CO21(i),x_Me1(i),x_H2O1(i),x_DMC5(i)] = DMCPlantGraphsFun(T1,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
end
 
figure('DefaultAxesFontSize',12)
plot(X_O2,V_reactor1,'LineWidth',2)
hold on
plot(X_O2,V_reactor2,'LineWidth',2)
hold on
plot(X_O2,V_reactor3,'LineWidth',2)
legend('T = 80 C','T = 105 C','T = 130 C')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('Reactor Volume (m^3)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,V_reactor4,'LineWidth',2)
hold on
plot(X_O2,V_reactor5,'LineWidth',2)
hold on
plot(X_O2,V_reactor6,'LineWidth',2)
legend('P = 10.13 bar','P = 25.32 bar','P = 40.52 bar')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('Reactor Volume (m^3)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,F_Me,'LineWidth',2)
hold on
plot(X_O2,F_O2,'LineWidth',2)
hold on
plot(X_O2,F_CO,'LineWidth',2)
legend('F_M_e','F_O_2','F_C_O')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('Flowrate into Reactor (mol/s)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,P_O2,'LineWidth',2)
hold on
plot(X_O2,P_CO,'LineWidth',2)
hold on
plot(X_O2,P_CO2,'LineWidth',2)
hold on
plot(X_O2,P_H2O,'LineWidth',2)
hold on
plot(X_O2,P_Me,'LineWidth',2)
hold on
plot(X_O2,P_DMC,'LineWidth',2)
legend('P_O_2','P_C_O','P_C_O_2','P_H_2_O','P_M_e','P_D_M_C')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('Reactor Production Rate (mol/s)')
xlim([0.1 1])
 
x_H2O_max = 0.15*ones(1,length(X_O2));
 
figure('DefaultAxesFontSize',12)
plot(X_O2,x_Me1,'LineWidth',2)
hold on
plot(X_O2,x_DMC5,'LineWidth',2)
hold on
plot(X_O2,x_H2O_max,'--','LineWidth',2)
legend('x_M_e','x_D_M_C , x_H_2_O','x_H_2_O_,_m_a_x')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('Liquid Composition Leaving Reactor (x_i)')
 
for i = 1:length(X_O2)
    [NPV1(i),NPVP1(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T1,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV2(i),NPVP2(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T2,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV3(i),NPVP3(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T3,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV4(i),NPVP4(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T3,P1,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV5(i),NPVP5(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T3,P2,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
    [NPV6(i),NPVP6(i),~,~,~,~,~,~,~,~,~,~,~,~,~,~,~,~] = DMCPlantGraphsFun(T3,P3,X_O2(i),8,2,Recovery_DMC,Recovery_Me,Recovery_H2O);
end
 
figure('DefaultAxesFontSize',12)
plot(X_O2,NPV1,'LineWidth',2)
hold on
plot(X_O2,NPV2,'LineWidth',2)
hold on
plot(X_O2,NPV3,'LineWidth',2)
legend('T = 80 C','T = 105 C','T = 130 C')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_p_r_o_j (MM $)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,NPV4,'LineWidth',2)
hold on
plot(X_O2,NPV5,'LineWidth',2)
hold on
plot(X_O2,NPV6,'LineWidth',2)
legend('P = 10.13 bar','P = 25.32 bar','P = 40.52 bar')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_p_r_o_j (MM $)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,NPVP1,'LineWidth',2)
hold on
plot(X_O2,NPVP2,'LineWidth',2)
hold on
plot(X_O2,NPVP3,'LineWidth',2)
legend('T = 80 C','T = 105 C','T = 130 C')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_% (%)')
 
figure('DefaultAxesFontSize',12)
plot(X_O2,NPVP4,'LineWidth',2)
hold on
plot(X_O2,NPVP5,'LineWidth',2)
hold on
plot(X_O2,NPVP6,'LineWidth',2)
legend('P = 10.13 bar','P = 25.32 bar','P = 40.52 bar')
xlabel('Conversion of O_2 (X_O_2)')
ylabel('NPV_% (%)')
