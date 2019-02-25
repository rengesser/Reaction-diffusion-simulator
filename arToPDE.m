function arToPDE(idm)
global ar
clear -global re
global re;

if ~exist('idm','var')
    idm = 1; 
end

if ~isfield(ar,'PDEqPx')
    warning('No spatial dependent dynamical parameter specified. If spatial dependent parameters are required, please specifiy them in ar.PDEqPx and re-run arToPDE.')
    ar.PDEqPx = zeros(size(ar.p));
end
if ~isfield(ar,'PDEqDiffusive')
    warning('All states difussive. Immobile states can be specified in ar.PDEDiffusive. Re-run of arToPDE necessary when immobile states are included.')
    ar.PDEqDiffusive = ones(size(ar.p));
end

if isempty(ar)
    error('No ar-struct loaded')
end

% states
states = ar.model(idm).x;
nstates = length(states);


%diffusion parameters
dd=cell(size(states));
for i = 1:length(states)
    if ar.PDEqDiffusive
       dd{i}=['d_' states{i}];
    else
       dd{i} = '0';
    end   
end

% equations
eqSymbolic = subs(ar.model(idm).fx,ar.model(idm).p,ar.model(idm).fp');

for i = 1:length(eqSymbolic)
    eq{i,:} = char(eqSymbolic(i));
end

% input variables (time dependent input not supported)
uLabel = ar.model(idm).u;

%dynamic parameters and parameter fields
pLabel = ar.pLabel((ar.qDynamic & ~ar.qInitial) & ~ar.PDEqPx );

if any(ar.PDEqPx & (ar.qInitial | ~ar.qDynamic ) )
    warning('Only dynamical parameter can be spatial dependent. Initials are always defined as spatial dependent.')
    ar.PDEqPx(ar.PDEqPx & (ar.qInitial | ~ar.qDynamic )) = 0;
end

pxLabel = ar.pLabel(logical(ar.PDEqPx));

dSym = symvar(sym(dd));
for i=1:length(dSym)
    dLabel{i} = char(dSym(i));
end

re.modelname = ar.model.name;
re.eq=eq';
re.eqSymbolic = eqSymbolic;

re.yLabel = states;
re.ySymbolic = sym(states,'clear');

re.pLabel = pLabel;
re.pSymbolic =pLabel;

re.pxLabel = pxLabel; 

re.uLabel = uLabel;

re.dLabel = dLabel;
re.dSym = dSym;
re.D = diag(sym(dd));  % Diffusion matrix

re.pFromAr = 1;
% states / y  : y1 ... yn
% paras / p   : p1 ... pn
% paras_x / px : px1 ... pxn