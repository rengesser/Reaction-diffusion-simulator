addpath('../../')

reLoadModel('Diffusion_from_source.def')

% Set grid size, initials, parameterfields to default values
reInitialize
reWriteRHS

% Simulation on 1dim grid with 200 grid points
re.PDE.xmax = 30;
re.PDE.ymax = 1;
reAdaptGridsize;

re.pxOpt.c=1;  % Adapt parameter field
reSetPx;   

re.Y0opt(2).idkind = 7;  % initial concentration of species re.yLabel(2) random
re.Y0opt(2).sigma = 0.1; % relative sigma of noise
re.Y0opt(2).c     = 0.3; % Mean of noise

re.Y0opt(3).idkind = 4;  % initial concentration of species re.yLabel(3) as gaussian 
re.Y0opt(3).x0 = 0.5;    % mean of gaussian
re.Y0opt(3).sigma = 0.2; % sigma of gaussian
re.Y0opt(3).c = 0.15;     % scaling factor befor gaussian
reSetY0

re.PDE.t = linspace(0,100,300);

reSimuPDESys

% write D2D model file into the folder models containing the discretized
% PDE system which is a ODE system
rePDE2ar


% Setup and simulate the ar-Model and write the results to re.PDE.Yar
Setup_and_simulate_D2D_Model


rePlotComparison

