addpath('../../')
%% Example for simulation with Dirichlet boundary conditions
% Simple use case with constant values on the boundaries on 1dim domain

reLoadModel('Diffusion_from_source_bnd.def')

% Set grid size, initials, parameterfields to default values
reInitialize
reWriteRHS

% Simulation on 2dim grid with 50x50 grid points
re.PDE.xmax = 50;
re.PDE.ymax = 50;
reAdaptGridsize;

re.PDE.t = [0:0.01:0.1 0.2:0.1:1 2:10 20:10:100];
re.d(1)=0.01;
reSetPars('Km_grad',1)
re.PDE.bndcondition='dirichlet';

% Species 1: Boundary values for Species 1 a function (2 examples: line 24 sinus
% function, line 25 linear function)
re.PDE.idsBoundary=re.PDE.BndCndOpts(1).idsBoundary_clockwise;
re.PDE.yBoundary = 2+sin(24*pi*linspace(0,1,length(re.PDE.BndCndOpts(1).idsBoundary_clockwise)));
%re.PDE.yBoundary = 0.5+2*linspace(0,1,length(re.PDE.BndCndOpts(2).idsBoundary_clockwise));

reSimuPDESys
rePlotPDE

