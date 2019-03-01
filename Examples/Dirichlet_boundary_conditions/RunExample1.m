addpath('../../')
%% Example for simulation with Dirichlet boundary conditions
% Simple use case with constant values on the boundaries on 1dim domain

reLoadModel('Diffusion_from_source_bnd.def')

% Set grid size, initials, parameterfields to default values
reInitialize
reWriteRHS

% Simulation on 1dim grid with 200 grid points
re.PDE.xmax = 200;
re.PDE.ymax = 1;
reAdaptGridsize;

re.PDE.t = [0:0.01:0.1 0.2:0.1:1 2:10];

% The struct re.PDE.BndCndOpts contains the options for the single states re.yLabel
re.PDE.bndcondition='dirichlet';
re.PDE.BndCndOpts(1).c_x1 = 2;  % value at the left boundary
re.PDE.BndCndOpts(1).c_xend = 0;    % value at the right boundary
reSetDirichletBndCnd;

reSimuPDESys
rePlotPDE

