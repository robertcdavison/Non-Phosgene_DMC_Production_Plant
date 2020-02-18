%%The first code is a function that takes design variables as inputs, and outputs relevant stream flowrates and compositions as well as plant NPV and NPV percent.

function [NPV,NPVP,V_reactor,F_Me,F_O2,F_CO,P_Me,P_O2,P_CO,P_CO2,P_H2O,P_DMC,y_O2,y_CO,y_CO2,x_Me,x_H2O,x_DMC] = DMCPlantGraphsFun(T1,P1,X_O2,MR1,MR2,Recovery_DMC,Recovery_Me,Recovery_H2O)
%% Chemical Properties
Vbar_Me = 0.0405; %molar volume of methanol (L/mol)
Vbar_H2O = .018; %molar volume of water (L/mol)
Vbar_DMC = 0.0856; %molar volume of DMC (L/mol)
KH_O2 = 3179; KH_CO = 3107; KH_CO2 = 158; %Henry's constants for gases (bar)
Compressor_T = 467.1; % Temperature Leaving Compressor (K)
%% Rate constants
k1 = k_1(T1);
k2 = k_2(T1);
%% Solve for selectivity of DMC with iteration
fail1 = 0;
fail2 = 0;
S_err = 1;
S_DMC = 1.5;
J_DMC = 73.4;
J_H2O = 73.4; % Amounts of H2O and DMC leaving the plant (mol/s)
P_DMC = J_DMC/Recovery_DMC; %Production Rate of DMC from reactor (mol/s)
P_H2O = J_H2O/Recovery_H2O; %Production Rate of H2O from reactor (mol/s)
Re_DMC = P_DMC*(1-Recovery_DMC);
Re_H2O = P_H2O*(1-Recovery_H2O);
iter = 0;
while S_err > 0.001
    S_DMCold = S_DMC; % Reset Selectivity
    % Solve for flowrates into reactor (mol/s)
    F_O2 = (P_DMC-Re_DMC)/(X_O2*S_DMC);
    F_CO = MR2*F_O2;
    F_Me = MR1*F_O2;
    F_DMC = Re_DMC;
    F_H2O = Re_H2O;
    % Flowrates leaving reactor (mol/s)
    P_O2 = F_O2*(1 - X_O2);
    P_CO2 = (P_DMC-Re_DMC)*((2-S_DMC)/S_DMC);
    P_CO = - P_CO2 - (P_DMC - Re_DMC) + F_CO;
    P_H2O = (P_DMC - Re_DMC) + Re_H2O;
    P_Me = F_Me - 2*(P_DMC-Re_DMC);
    % Recycle Stream Flowrates
    Re_Me = P_Me*(1-Recovery_Me);
    Re_CO2 = 0;
    Re_O2 = P_O2;
    Re_CO = P_CO;
    % Exhaust Stream Flowrates
    E_O2 = 0;
    E_CO = 0;
    E_CO2 = P_CO2;
    % Plant inlet flowrates (mol/s)
    FF_Me = F_Me - Re_Me;
    FF_CO = F_CO - Re_CO;
    FF_O2 = F_O2 - Re_O2;
    % Solve for mole fractions in gas phase
    P_Gas = (P_O2 + P_CO2 + P_CO);
    y_O2 = P_O2/P_Gas;
    y_CO = P_CO/P_Gas;
    y_CO2 = P_CO2/P_Gas;
    % Solve for mole fractions in liquid phase
    x_O2 = y_O2*P1/KH_O2;
    x_CO = y_CO*P1/KH_CO;
    x_CO2 = y_CO2*P1/KH_CO2;
    P_Liq = P_DMC + P_Me + P_H2O;
    x_Me = P_Me/P_Liq;
    x_DMC = P_DMC/P_Liq;
    x_H2O = P_H2O/P_Liq;
    q_Liq = P_Me*Vbar_Me + P_DMC*Vbar_DMC + P_H2O*Vbar_H2O; %Total volumetric flowrate of liquid out (L/s)
    n_Liq = P_Me + P_H2O + P_DMC; %Total molar flowrate of liquid leaving reactor(mol/s)
    %Solve for concentrations in liquid phase (mol/L)
    C_DMC = P_DMC/q_Liq;
    C_H2O = P_H2O/q_Liq;
    C_Me = P_Me/q_Liq;
    C_O2 = n_Liq*x_O2/q_Liq;
    C_CO = n_Liq*x_CO/q_Liq;
    C_CO2 = n_Liq*x_CO2/q_Liq;
    r1 = k1*C_Me^2*C_O2^0.5;
    r2 = k2*C_O2^0.5;
    S_DMC = 2*r1/(r1 + r2);
    iter = iter + 1;
    S_err = abs(S_DMC - S_DMCold);
    if iter > 1000000
        fail2 = 1;
        break
    end
end
if x_H2O > 0.15
    fail1 = 1;
end
if C_CO < 0
    fail1 = 1;
end
%% Reactor Sizing
q_in = F_H2O*Vbar_H2O + F_Me*Vbar_Me + F_DMC*Vbar_DMC; % (L/s) into reactor
C_DMCin = F_DMC/q_in;
C_DMCout = C_DMC;
Tau = (C_DMCin - C_DMCout)/(-r1);
V_reactor = q_in*Tau/1000; %Volume of Reactor (m^3)
D_reactor = (2*V_reactor/pi)^(1/3); % Diameter of reactor (m)
L_reactor = 2*D_reactor; % Height of Reactor (m)
%% Reactor Costing
Fp = 1;
Fm = 1;
Fc = Fm*Fp;
ReactorW = 1.645e5*(P_DMC - F_DMC) + 2.013e5*(P_Me - F_Me) + 1.106e5*(P_CO - F_CO)...
    + 3.938e5*(P_CO2) + 2.418e5*(P_H2O - F_H2O); %Energy produced from reaction (W)
if ReactorW > 0 
    cooling = 1; %If reaction is exothermic, use cooling water
else
    cooling = 0; %If reaction is endothermic, use heater
end
if cooling == 0
    ReactorBTU = -ReactorW*3.412/1000000; %Energy into reactor (MM BTU/hr)
    Reactor_Cost = ReactorBTU*8400*3; % Cost of reactor heating ($/year)
    ReactorFurnace_IC = (1650/280)*(5.52*10^3)*(ReactorBTU^0.85)*(1.27+Fc); % IC of Reactor Furnace ($)
end
if cooling == 1
    Reactor_Cost = ReactorW*3600*8400/1e9*2;
    ReactorBTU = 0;
    ReactorFurnace_IC = 128179;
end
Reactor_IC = (1650/280)*(101.9*((D_reactor*3.28)^1.066)*((L_reactor*3.28)^.82))*(2.18+Fc); % IC of reactor ($)
%% Methanol Pre Heater Costing
PreHeater1W = (T1-298)*(90.5*FF_Me) + (T1 - 371.58)*(90.5*Re_Me + 75.2*Re_H2O + 234.26*Re_DMC); %Energy to heat OR cool Methanol feed (W)
if PreHeater1W < 0 
    cooling1 = 1; %Needs to be cooled
else
    cooling1 = 0; %Needs to be heated
end
if cooling1 == 0
    PreHeater1BTU = PreHeater1W*3.412/1000000; %Energy into methanol heater (MM BTU/hr)
    PreHeater1_IC = (1650/280)*(5.52*10^3)*(PreHeater1BTU^0.85)*(1.27+Fc); % IC of Methanol feed Furnace ($)
    PreHeater1_Cost = PreHeater1BTU*8400*3; % Cost of methanol feed heating ($/year)
end
if cooling1 == 1
    PreHeater1_Cost = -PreHeater1W*.06048; % Cost to cool methanol feed if too hot ($/year)
    PreHeater1_IC = 128179; %Preheater is now a heat exchanger
end
%% Gas Pre Heater Costing
PreHeater2W = (T1-298)*(Cp_O2(298,T1)*FF_O2 + Cp_CO(298,T1)*FF_CO) + (T1-Compressor_T)*(Cp_O2(Compressor_T,T1)*Re_O2 + Cp_CO(Compressor_T,T1)*Re_CO); %Energy to heat CO and O2 feeds (W)
if PreHeater2W < 0 
    cooling2 = 1; %Needs to be cooled
else
    cooling2 = 0; %Needs to be heated
end
if cooling2 == 0
    PreHeater2BTU = PreHeater2W*3.412/1000000; %Energy into methanol heater (MM BTU/hr)
    PreHeater2_IC = (1650/280)*(5.52*10^3)*(PreHeater2BTU^0.85)*(1.27+Fc); % IC of Methanol feed Furnace ($)
    PreHeater2_Cost = PreHeater2BTU*8400*3; % Cost of methanol feed heating ($/year)
end
if cooling2 == 1
    PreHeater2_Cost = -PreHeater2W*.06048; % Cost to cool methanol feed if too hot ($/year)
    PreHeater2_IC = 128179; %Preheater is now a heat exchanger
end
%% Compressor Costing
q_Comp = (Re_O2 + Re_CO)*0.0821*303/1.974*0.0353147*60; % Volumetric flow of gas recycle (ft^3/min)
CompressorBHP = (3.03e-5/.254)*2*2088.54*q_Comp*((P1/2)^.254 - 1);
Compressor_IC = (1650/280)*(517.5)*(CompressorBHP/.8)^0.82*3.11;
Compressor_Cost = CompressorBHP*745.7/1000000*50*24*350; %Electricity powering compressor ($/year)
%% Column 1 Heater Costing
Column1HeaterW = (97.86 - 80)*(90.5*P_Me + 75.2*P_H2O + 234.26*P_DMC); % Wattage of heater before columns
Column1HeaterBTU = Column1HeaterW*3.412/1000000; % Energy into Column 1 heater (MM BTU/hr)
Column1Heater_IC = (1650/280)*(5.52*10^3)*(Column1HeaterBTU^0.85)*(1.27+Fc); % IC of Column 1 Heater ($)
Column1Heater_Cost = Column1HeaterBTU*8400*3; % Cost to operate column 1 pre heater ($/year)
%% Amine Scrubber Heater Costing
ScrubberHeaterW = (303 - 264)*(Cp_O2(264,303)*P_O2 + Cp_CO(264,303)*P_CO + 37.23*P_CO2); % Wattage of heater before amine scrubber
ScrubberHeaterBTU = ScrubberHeaterW*3.412/1000000; %Power of scrubber heater (MM BTU/hr)
ScrubberHeater_IC = (1650/280)*(5.52*10^3)*(ScrubberHeaterBTU^0.85)*(1.27+Fc); % IC of Scrubber Heater ($)
ScrubberHeater_Cost = ScrubberHeaterBTU*8400*3;
%% Variable Costs
Me_Cost = FF_Me*0.0144*30240000; % Feed Cost of Methanol ($/year)
O2_Cost = FF_O2*0.0096*30240000; % Feed Cost of Oxygen ($/year)
CO_Cost = FF_CO*0.005042*30240000; % Feed Cost of Carbon Monoxide ($/year)
CO2_Cost = E_CO2*4.401e-3*30240000; % Cost of Separating CO2 ($/year)
H2O_Cost = J_H2O*1.442e-6*30240000; % Cost of Wastewater Treatment ($/year)
Column1_Cost = 13653904.32*(n_Liq)/1258; % Cost of utilities for column 1 ($/year)
Column2_Cost = 10468483.2*(n_Liq)/1258; % Cost of utilities for column 2 ($/year)
Column3_Cost = 15903095.04*(n_Liq)/1258; % Cost of utilities for column 3 ($/year)
AllCosts = [ScrubberHeater_Cost Column1Heater_Cost Me_Cost O2_Cost CO_Cost CO2_Cost H2O_Cost Reactor_Cost PreHeater1_Cost PreHeater2_Cost Compressor_Cost Column1_Cost Column2_Cost Column3_Cost];
for i = 1:length(AllCosts)
    if AllCosts(i) < 0
        AllCosts(i) = 0;
    end
end
%% Remainder of Installed Costs
Column1_IC = 164837.9;
Column2_IC = 448155.06;
Column3_IC = 107916;
DecanterHX_IC = 128179;
AllIC = [Reactor_IC ReactorFurnace_IC PreHeater1_IC PreHeater2_IC Compressor_IC ScrubberHeater_IC Column1Heater_IC Column1_IC Column2_IC Column3_IC DecanterHX_IC]; % All installed costs
for i = 1:length(AllIC)
    if AllIC(i) < 0
        AllIC(i) = 0;
    end
end
%% Revenue
DMC_Revenue = J_DMC*0.0811*30240000; % Revenue from sale of DMC ($/year)
%% NPV Calculations for normal case
ISBL = sum(AllIC); %Total installation cost ($)
PR = DMC_Revenue; %AARON - annual product revenue ($/yr)
VC = sum(AllCosts);%AARON - annual cost of feedstock ($/yr)
FC = ISBL;
PBT = PR - VC;
 
Sigma   =   6.8137;
a   =   4.1107;
b   =   -0.3503;
c   =   0.2936;
d   =   -2.06;
e   =   3.4057;
f   =   7.005;
g   =   1.180;
h   =   1.216;
k   =   12;
 
TCI = h*FC;
ROIbt = PBT/TCI;
NPV = (a*PBT+b*FC)/1000000;
NPVP = (c*ROIbt+d);
%% Calculate Economics for Delayed Startup Case
Sigma1  =   7.1034;
a1  =   3.7370;
b1  =   -0.3377;
c1  =   0.2491;
d1  =   -1.85;
e1  =   4.0139;
f1  =   7.429;
g1  =   1.180;
h1  =   1.216;
k1  =   12;
 
 
TCI_delay = h1*FC;
ROIbt_delay = PBT/TCI_delay;
NPV_delay = a1*PBT+b1*FC;
NPVP_delay = c1*ROIbt_delay+d1;
if fail1 == 1
    NPVP = -Inf;
    NPVP_delay = -Inf;
    NPV = -Inf;
    NPVP_delay = -Inf;
end
if fail2 == 1
    NPVP = -Inf;
    NPVP_delay = -Inf;
    NPV = -Inf;
    NPVP_delay = -Inf;
end
end
%% Functions for finding kinetic parameters
function k1 = k_1(T)
    R = 1.986;
    k1 = 1.4*10^(11)*exp(-24000/(R*T));
end
function k2 = k_2(T)
    R = 1.986;
    k2 = 5.6*10^(12)*exp(-22700/(R*T));
end
function CpO2 = Cp_O2(T1,T2)
    A__O2 = 31.32234;
    B__O2 = -20.23531;
    C__O2 = 57.86644;
    D__O2 = -36.50624;
    E__O2 = -0.007374;
    T = 0.5*(T1+T2);
    CpO2 = A__O2 + B__O2*(T/1000) + C__O2*(T/1000)^2 + D__O2*(T/1000)^3 + E__O2/(T/1000)^2;
end
function CpCO = Cp_CO(T1,T2)
    A__CO = 25.56759;
    B__CO = 6.096130;
    C__CO = 4.054656;
    D__CO = -2.671301;
    E__CO = 0.131021;
    T = 0.5*(T1+T2);
    CpCO = A__CO + B__CO*(T/1000) + C__CO*(T/1000)^2 + D__CO*(T/1000)^3 + E__CO/(T/1000)^2;
end