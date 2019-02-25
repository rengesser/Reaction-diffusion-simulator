addpath('../../')

%% Example 1
disp('Example 1: Load model, make 1d simulation and plot.')

reLoadModel('Diffusion_from_source.def')

% Set grid size, initials, parameterfields to default values
reInitialize
reWriteRHS

% Simulation on 1dim grid with 200 grid points
re.PDE.xmax = 200;
re.PDE.ymax = 1;
reAdaptGridsize;

reSimuPDESys

re.plot.ts = 0:0.05:1;  % Plot 20 Time points equally distributed
re.plot.qTimes = 'rel';
rePlotPDE(0,'Example 1')


%% Example 2
disp('Example 2: Different initial concentrations, parameter values and variations in plotting.')

re.p(3)=4;             % Set parameter re.pLabel{3} to 4 
reSetPars('b_JNK',3);  % Set parameter b_JNK to 3 
reSetPars('k_deg_grad',7);
re.d(1) = 0.4;         % Set Diffusion coefficient re.dLabel(1), alternative reSetPars(re.dLabel{1},0.4);

re.Y0opt(2).idkind = 7;  % initial concentration of species re.yLabel(2) random
re.Y0opt(2).sigma = 0.1; % relative sigma of noise
re.Y0opt(2).c     = 0.3; % Mean of noise

re.Y0opt(3).idkind = 4;  % initial concentration of species re.yLabel(3) as gaussian 
re.Y0opt(3).x0 = 0.5;    % mean of gaussian
re.Y0opt(3).sigma = 0.2; % sigma of gaussian
re.Y0opt(3).c = 0.15;     % scaling factor befor gaussian

reSetY0     % apply new initials

reSimuPDESys
rePlotPDE(0,'Example 2')

%% Different way to plot 1d simulations
re.plot.timespace_1d = 1;
rePlotPDE(0,'Example 2 - timespace heatmap.')
re.plot.timespace_1d = 0;
pause
%% Example 3
disp('Example 3: Simulation on 2dim grid and different parameter field bx')
re.PDE.xmax = 50;
re.PDE.ymax = 50;
reAdaptGridsize;

% Adapt parameter field to a circle (0 outside of circle and c within circle)
re.pxOpt(1).idkind = 2;      % corresponds to a circle, compare re.pxOpt.kinds
re.pxOpt(1).x0 = [0.5 0.5];  % mean of circle
re.pxOpt(1).c = 5;           % value within circle
re.pxOpt(1).sigma = 0.1;     % radius of the circle

reSetPx         % apply new parameter field

re.PDE.t = 0:0.01:5;  % integrate only up to 5 time units

reSimuPDESys
rePlotPDE(0,'Example 3')

%% Example 4: Assess simulations by hand 
% The results are saved in re.PDE.Y
% the first dimension runs over the timepoints in re.PDE.t
% the second dimension contains the concentrations of all states at all
% spatial points. 
% A single state can be accessed by the index field re.PDE.ctr. 
% If you want the simulations of state ns at re.PDE.t(ti)
% just call re.PDE.ctr( ti, re.PDE.ctr + ni -1).
% In two dimensions you can just reshape the resulting 1dim vector with 
% reshape(Y_state2(end,:),re.PDE.xmax,re.PDE.ymax)

ids_states1 = re.PDE.ctr + 0;
ids_states2 = re.PDE.ctr + 1;
ids_states3 = re.PDE.ctr + 2; 

Y_state1 = re.PDE.Y(:,ids_states1);
Y_state2 = re.PDE.Y(:,ids_states2);
Y_state3 = re.PDE.Y(:,ids_states3);

% plot final time point of state 2:
figure('Name','Exmaple 4')
imagesc(reshape(Y_state2(end,:),re.PDE.xmax,re.PDE.ymax)')  % transposed since x and y axis are switched in imagesc
title(re.yLabel{2})





