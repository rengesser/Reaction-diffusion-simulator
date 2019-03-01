addpath('../../')
%% Example for simulation with Dirichlet boundary conditions
% Gierer-Meinhardt with fixed values at parts of the boundary

reLoadModel('GiererMeinhardt.def')

% Set grid size, initials, parameterfields to default values
reInitialize
reWriteRHS

% Simulation on 1dim grid with 200 grid points
re.PDE.xmax = 50;
re.PDE.ymax = 50;
reAdaptGridsize;

re.PDE.t = 0:1:50;

re.d(1) = 0.0003;
re.d(2) = 0.03;
re.p = [100*[0.004,  0.02,  0.001, 0.03], 0.1];

re.Y0opt(1).idkind=7;
re.Y0opt(2).idkind=7;
re.Y0opt(1).c=0.5;
re.Y0opt(2).c=0.1;
reSetY0

re.PDE.bndcondition='dirichlet';
re.PDE.idsBoundary = re.PDE.BndCndOpts(1).ids_x1(15:35);
re.PDE.yBoundary = 4 * ones(size(15:35));

reSimuPDESys
rePlotPDE

