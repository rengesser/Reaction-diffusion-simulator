addpath('../../')
%% Example for simulation with temporaly changing Dirichlet boundary conditions

reLoadModel('GiererMeinhardt.def')

% Set grid size, initials, parameterfields to default values
reInitialize

%reWriteRHS  % Run once and add custum line into .m file in /RHS_fcts and
%rename file to RHS_PDE_custom.m

re.PDE.RHS_fct = @RHS_PDE_custom;

% Simulation on 2dim grid with 50x50 grid points
re.PDE.xmax = 50;
re.PDE.ymax = 50;
reAdaptGridsize;

re.PDE.t = 0:5:400;

re.d(1) = 0.0005;
re.d(2) = 0.05;
re.p = [100*[0.004,  0.02,  0.001, 0.03], 0.1];

re.Y0opt(1).idkind=7;
re.Y0opt(1).c=0.5;
re.Y0opt(2).c=0.09;
reSetY0

re.PDE.bndcondition='dirichlet';

% Use dirichlet only for left boundary
re.PDE.idsBoundary = re.PDE.BndCndOpts(1).ids_x1;

re.omega = 0.008;  % Frequency of the input sinus
re.A = 2;          % Amplitude of the input sinus

reSimuPDESys_timeDirichlet

re.plot.ts=0:0.01:1;
rePlotPDE

