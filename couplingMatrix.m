function D = couplingMatrix(varargin)
% Coupling matrix of a cell-based reaction-transport problem.
%
% D = COUPLINGMATRIX(YMAX,BNDCONDITION), returns a sparse YMAX-by-YMAX
% coupling matrix for a reaction-transport problem in one dimension with
% YMAX number of cells. The boundary condition BNDCONDITION can be either
% 'zeroflux' for zero transport across the boundary or 'periodic'. 
%
% D = COUPLINGMATRIX(YMAX,XMAX,BNDCONDITION,CELLTYPE), returns a sparse
% YMAX*XMAX-by-YMAX*XMAX coupling matrix for a reaction-transport problem
% in two dimensions. YMAX and XMAX are the number of cells in y and x
% direction, respectively. CELLTYPE can be either 'quadratic' leading to
% four neighbors per cell or 'hexagonal' leading to six neighbors per cell.

if ~((nargin==2)|(nargin==4))
  error('Two or four input arguments required')
end

if nargin == 2
  % 1-d domain
  ymax = varargin{1};
  ysten = [-1 1];
  xmax = 1;
  xsten = [0 0];
  bndcondition = varargin{2};
  if strcmp(bndcondition,'zeroflux')
    bflag = 1;
  elseif strcmp(bndcondition,'periodic')
    bflag = 0;
  else
    error('Unknown boundary condition!')
  end  
else
  % 2-d domain
  ymax = varargin{1};
  xmax = varargin{2};
  if (ymax==1)|(xmax==1)
    help couplingMatrix
    error('One dimensional domain!')
  end  
  bndcondition = varargin{3};
  if strcmp(bndcondition,'zeroflux')
    bflag = 1;
  elseif strcmp(bndcondition,'periodic')
    bflag = 0;
  else
    error('Unknown boundary condition!')
  end
  celltype = varargin{4};
  if strcmp(celltype,'quadratic')&(ymax>1)&(xmax>1)
    ysten = [-1 1 0 0];
    xsten = [0 0 -1 1];
  elseif strcmp(celltype,'hexagonal')&(ymax>1)&(xmax>1)
    ysten = [-1 1 0 0 -1 1];
    xsten = [0 0 -1 1 1 -1];
  else
    error('Unknow cell type!')
  end
end

D = cm(ymax,xmax,ysten,xsten,bflag,1);
