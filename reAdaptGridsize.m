% updates variables when size of spatial dicretization grid is changed
% Attention: px and y0 are set to default values and have eventually to be
% resetted
%  

% boundary condition of the line/grid
bndcondition = 'zeroflux'; 
%bndcondition = 'periodic'; 
dx = 1/(max(re.PDE.xmax,re.PDE.ymax)-1); 
% initialize grid indices
re.PDE.ctr = IJKth(1,1:re.PDE.ymax,1:re.PDE.xmax,re.PDE.ymax,length(re.yLabel));

% spatial coupling matrix
if re.PDE.ymax==1 || re.PDE.xmax ==1
    re.PDE.D = couplingMatrix(re.PDE.xmax,bndcondition)./(dx^2); 
else
    re.PDE.D = couplingMatrix(re.PDE.xmax,re.PDE.ymax,bndcondition,'quadratic')./(dx^2);    
end

re.PDE.options.JPattern = jpat(length(re.yLabel),re.PDE.D);

% dynamical parameters (spatial dependent)
re.px = NaN(re.PDE.xmax*re.PDE.ymax,length(re.pxLabel));  
reSetPx;

% initial conditions (default value is set to one + some noise)
re.PDE.y0 = [];
reSetY0;

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

% Set Dirichlet boundary conditions
if strcmp(re.PDE.bndcondition,'dirichlet')
    reSetDirichletBndCnd
    re.PDE.Y(re.PDE.idsBoundary) = re.PDE.yBoundary;
end
