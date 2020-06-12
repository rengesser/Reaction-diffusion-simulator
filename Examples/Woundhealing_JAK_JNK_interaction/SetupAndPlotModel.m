addpath('../../')
reLoadModel('Woundhealing_JAKJNK_non-dimensionalized.def')
reInitialize
reWriteRHS

re.PDE.xmax = 100;
re.PDE.ymax = 1;
reAdaptGridsize;

% set start constant starting concentrations
for i = 1:4
    re.Y0opt(i).c=0.01;
    re.Y0opt(i).sigma=0;
end
reSetY0;

% Eiger production only in the outer left part of the domain
re.pxOpt.c=1; % bool_b_eiger
re.pxOpt.x0(1) = 0.05;
reSetPx;

% Load parameters (with back inhibition)
reLoad('001_Parameters')
rePrint

% Simulate partial differential equations
reSimuPDESys;

% Plot results
figure(1)
subplot(2,1,1)
plotJNKSTATin1plot;
title('With inhibition of JAK by JNK')

% Set back inhibition to zero
re.p(13) = 0;

% resimulate
reSimuPDESys;

% plot again
subplot(2,1,2)
plotJNKSTATin1plot;
title('Without inhibition of JAK by JNK')