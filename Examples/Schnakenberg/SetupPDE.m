addpath('../../')

reLoadModel('Schnakenberg.def')
reInitialize
reWriteRHS

re.PDE.xmax = 50;
re.PDE.ymax = 50;
re.PDE.t = 0:0.01:2;
reAdaptGridsize;

re.p = [40 0.01 2];
re.d = [1/50   1];

 % initial concentrations steady state with spatial noise
re.Y0opt(1).c = re.p(2)+re.p(3);
re.Y0opt(2).c = re.p(3)/(re.p(2)+re.p(3))^2;
re.Y0opt(1).idkind = 7;
re.Y0opt(2).idkind = 7;
re.Y0opt(1).sigma = 0.01;
re.Y0opt(2).sigma = 0.01;
reSetY0;

reSimuPDESys;

re.plot.ts = 0:0.1:1; 
re.plot.qTimes = 'rel';
rePlotPDE;

%% Assess simulations by hand 
% results are saved in re.PDE.Y
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
%ids_states3 = re.PDE.ctr + 2; % only for illustration, model has only two states

Y_state1 = re.PDE.Y(:,ids_states1);
Y_state2 = re.PDE.Y(:,ids_states2);

% plot final time point of state 2:
figure
imagesc(reshape(Y_state2(end,:),re.PDE.xmax,re.PDE.ymax)')  % transposed since x and y axis are switched in imagesc
title(re.yLabel{2})



