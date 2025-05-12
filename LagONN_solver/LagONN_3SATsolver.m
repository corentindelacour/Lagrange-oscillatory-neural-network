clear all
close all
clc

% Number of SAT variables
N=50 %20

% Number of SAT clauses
M=218 %91

instance=1

% Datapath to the .cnf file for the 3SAT formula
datapath='../../SATlib/'+string(N)+'variables_'+string(M)+'clauses/uf'+string(N)+'-0'+string(instance)+'.cnf';

% Constructing LagONN network
command=perl('generate_Lagrangian.pl',datapath)
eval(command);% creates the sym variables

beta=50; % tanh slope in cost function
command2=perl('generate_cost_LagONN.pl',datapath);
eval(command2);% creates the sym cost


% Define differential equations for the phase variables X
dX=-jacobian(Lag,X);

%Define the differential equations for the Lagrange phase variable \lambda
tauL=1;% speed of Lagrangian oscillators (tau=1: same as X variable)
dL=jacobian(Lag,L)/tauL;


%Jacobian matrix
J_XL=jacobian([dX dL],[X L]);

% creates the symbolic functions
dX_f=symfun(dX,[X L]);
dL_f=symfun(dL, [X L]);
cost_f=symfun(cost,X);

J_XL_f=symfun(J_XL, [X L]);
%syms K

% writes to function files that will be called by the LagONN solver

tic
matlabFunction(dX_f,'File','dX_func.m','Vars',{X,L},'Optimize',false);
matlabFunction(dL_f,'File','dL_func.m','Vars',{X,L},'Optimize',false);
matlabFunction(J_XL_f,'File','dJ_f.m','Vars',{X,L},'Optimize',false);
matlabFunction(cost_f,'File','cost_func.m','Vars',{X},'Optimize',false);
toc

clear -regexp ^X ^L

%% Running LagONN dynamics

% solver time step
dt=0.15;
% solver max number of iterations
kmax=1e4;

% Initializing phases
phaseX=rand(N,1)*2*pi;
phaseL=rand(M,1)*2*pi;

tstart=tic;

% if using built-in Matlab solver:

%tspan=[0 1000];%t =0:dt:10000;
% xoverFcn_LagONN = @(t, phase) stopevents_LagONN(phase, N, threshold_rad);
% options_LagONN = odeset('Stats','on','Jacobian',@(t,phase) dJ_f(phase(1:N)',phase(N+1:end)'),'RelTol',1e-1,'AbsTol',1e-3,'Events',xoverFcn_LagONN,'BDF','on');
% [t,phase,st,~,~] = ode15s(@(t,phase) LagONN_dynamics4(phase',N), tspan, phase_0(:,trial),options_LagONN);

STOP=0;
i=0;
while (i<=kmax) && (STOP==0)
    i=i+1;
    [phaseX,phaseL,STOP,cost_trace(i),~]=Felhberg_integration(phaseX,phaseL,N,dt);
    phaseX_store(:,i)=phaseX;
end
CPU_runtime=toc(tstart);%measuring CPU runtime
N_step=i;
computation_time=i*dt;
cost_final=cost_trace(i);

figure
plot((1:1:i)*dt,cost_trace)
xlabel('Time (cycle)')
ylabel('Cost')
grid on

figure
plot((1:1:i)*dt,cos(phaseX_store))
xlabel('Time (cycle)')
ylabel('cos \phi')
grid on


% if using Matlab built-in solvers:

% function [value, terminate, direction]=stopevents_LagONN(phase, N, threshold)
% value=ones(2,1)*(N-sum(double(LagONN_dynamics(phase',N)<threshold)))*(1-double(cost_func(phase(1:N)')<0.125));
% terminate=[1;1];
% direction=[1;-1];
% end



