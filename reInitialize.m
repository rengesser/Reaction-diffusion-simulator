if exist(fullfile(pwd, 'RHS_fcts'),'dir')
   addpath('RHS_fcts/')
end

global re

re.PDE.xmax = 100;
re.PDE.ymax = 1;

dx = 1/(max(re.PDE.xmax,re.PDE.ymax)-1); 

% boundary condition of the line/grid
re.PDE.bndcondition = 'zeroflux'; 
%re.PDE.bndcondition = 'periodic'; 
%re.PDE.bndcondition = 'dirichlet'; 

% initialize grid indices
re.PDE.ctr = IJKth(1,1:re.PDE.ymax,1:re.PDE.xmax,re.PDE.ymax,length(re.yLabel));

% spatial coupling matrix
if re.PDE.ymax==1 || re.PDE.xmax ==1
    re.PDE.D = couplingMatrix(re.PDE.xmax,re.PDE.bndcondition)./(dx^2); 
else
    re.PDE.D = couplingMatrix(re.PDE.xmax,re.PDE.ymax,re.PDE.bndcondition,'quadratic')./(dx^2);    
end

% Set integration options including structure of the jacobian
if ~isempty(re.pxLabel) || strcmp(re.PDE.bndcondition,'dirichlet')
   boolVectorized = 'off';
else
   boolVectorized = 'on';
end
re.PDE.options = odeset('RelTol',1e-12,'AbsTol',1e-12,'Vectorized',boolVectorized,'JPattern',jpat(length(re.yLabel),re.PDE.D));

% vector with time points to be integrated.
re.PDE.t = 0:0.1:100; 

% initial conditions (default value is set to one + some noise)
rng(1);  % random seed (todo: include into re.PDE struct with shuffle option)

reSetY0; % properties saved in re.Y0Opt; see reSetY0.m for details

% set default parameter values
re.d = 0.1*ones(size(re.dLabel));  % diffusion constants

% dynamical parameters (spatially constant)
if re.pFromAr
    arp  = ar.qLog10 .* 10.^ar.p + ~ar.qLog10 .* ar.p;
    re.p = double(subs(re.pLabel,ar.pLabel,arp));
else
    re.p = 0.1*ones(size(re.pLabel));  
end

re.u = 0.1*ones(size(re.uLabel));  % input parameters (spatial constant), only for import of ar models! Time dependent input not supported!

re.px = NaN(re.PDE.xmax*re.PDE.ymax,length(re.pxLabel));  % dynamical parameters (spatially dependent) = parameter fields
reSetPx % properties saved in re.pxOpt; see reSetPx.m for details

% plotting
re.plot.timespace_1d = 0; % =1: plot heatmap with concentration over time and space, only used in 1dim space
re.plot.ts = 0:0.05:1;  % indices, absolute or relative timepoints of plotting; if length(re.plot.idt)>1, all are plotted with pause. Use '+inf' for last timepoint
re.plot.qTimes = 'rel';  %'ids', 'abs', 'rel' (between 0 and 1)
re.plot.px = 1; % plot parafields
re.plot.global_clims = 0; % 2dim: Use same colorscale for all timepoints 


% Properties of Dirichlet boundary conditions
for idy = 1:length(re.yLabel)
    re.PDE.BndCndOpts(idy).kind = 'constant'; % constant values used at the borders
    % re.PDE.BndCndOpts(idy).kind = 'custom'; % if you want to specify
    % custom function at the the boundary 
  
    % constant values used when re.PDE.BndCndOpts(idy).kind = 'constant'.
    % When set to NaN, zeroflux conditions are used.
    re.PDE.BndCndOpts(idy).c_x1 = NaN;     
    re.PDE.BndCndOpts(idy).c_xend = NaN;
    re.PDE.BndCndOpts(idy).c_y1 = NaN;
    re.PDE.BndCndOpts(idy).c_yend = NaN;
end

% Extract indices of the boundary
for idy = 1:length(re.yLabel)
    if re.PDE.ymax == 1 % 1 dim
        re.PDE.BndCndOpts(idy).idsBoundary_clockwise = [re.PDE.ctr(1) re.PDE.ctr(end)] + idy - 1;
        re.PDE.BndCndOpts(idy).ids_x1 = re.PDE.ctr(1);
        re.PDE.BndCndOpts(idy).ids_xend = re.PDE.ctr(end);
    else % 2 dim
        ctr = reshape(re.PDE.ctr + idy -1, re.PDE.xmax, re.PDE.ymax);
        
        idsBoundary_clockwise = unique([ctr(:,1)'  ctr(end,:) ctr(end:-1:1,end)' ctr(1,end:-1:1)  ], 'stable');
        
        re.PDE.BndCndOpts(idy).ids_x1 = ctr(1,:);
        re.PDE.BndCndOpts(idy).ids_xend = ctr(end,end:-1:1);
        re.PDE.BndCndOpts(idy).ids_y1 = ctr(end:-1:1,1)';
        re.PDE.BndCndOpts(idy).ids_yend = ctr(:,end)';
        
        re.PDE.BndCndOpts(idy).idsBoundary_clockwise = idsBoundary_clockwise;
    end
    re.PDE.BndCndOpts(idy).yBoundary = NaN(size(re.PDE.BndCndOpts(idy).idsBoundary_clockwise));
end

if strcmp(re.PDE.bndcondition,'dirichlet')
    reSetDirichletBndCnd;
end
