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

re.px = NaN(re.PDE.xmax*re.PDE.ymax,length(re.pxLabel));  % dynamical parameters (spatial dependent)
reSetPx 

% initial conditions (default value is set to one + some noise)
re.PDE.y0 = [];
reSetY0;
