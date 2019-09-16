%% Setup file used to generate ar model
%% does not work here because original input data is missing
%% but you can load the models with arLoad

% Input
obs = {'dad','Tkv'};
name = 'JanineODE';

% Load PDE
reLoadModel(name)
Dpp_Initialize

% ODE model
rePDE2ar(obs)

% ODE data
idx = [2 4 7; 3 6 9];
idx(:,:,2) = [1 6 14;2 8 15];
xls2data(name,obs,idx,length(re.PDE.ctr),re.PDE.t(end))

% Compile ODE
arInit
arLoadModel(['arModel_' name])
arLoadData(['arModel_' name])
if exist([pwd 'Data/arModel_' name '2'],'dir')
    arLoadData(['arModel_' name '2'])
end
arCompileAll(true)

% Set parameter
ar.model.nobs = length(re.PDE.ctr);
SetBounds
SetParsChen
%arSetParsPattern('sd',-1,0,1)
arSetParsPattern('offset',-5,1,1)

% Save
arSave(name)
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],['Results\' name]);

% Plot
ar.model.qPlotXs(:) = 1;
ar.model.qPlotX(:) = 0;
ar.model.qPlotX(5:10:end) = 1;
ar.model.qPlotX(4:10:end) = 1;
arPlot

% Pre-equilibrium
ar.config.turboSSSensi = 1;
%ar.config.eq_rtol = 1e-8;
arSteadyState(1,1,1, -1e7)
arSteadyState(1,2,2, -1e7)
arPlot

% Save
name = [name '_SS'];
arSave(name)
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],['Results\' name]);

% Fit
n = 10;
arFitLHS(n)

name = [ name '_Fit' num2str(n)];
arSave(name)
[~,ws]=fileparts(ar.config.savepath);
movefile(['Results/' ws],['Results\' name]);
arPlotChi2s
PlotPDE
