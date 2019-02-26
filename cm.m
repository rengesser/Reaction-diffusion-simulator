function D = cm(ymax,xmax,ysten,xsten,bflag,cflag)
% Low-level function for the construction of a sparse coupling matrix 
%
% D = CM(YMAX,XMAX,YSTEN,XSTEN,BFLAG,CFLAG), returns a sparse 
% YMAX*XMAX-by-YMAX*XMAX coupling matrix for a reaction-transport problem
% in two dimensions. YSTEN and XSTEN are vectors indicating the coupling
% in y and x direction, respectively, relative to a reference cell at
% postition (y,x)=(0,0). BFLAG indicates the boundary condition, i.e.,
% BFLAG=0 (periodic boundary condition), BFLAG=1 (zero-flux boundary
% condition). if CFLAG=1 the net coupling of a cell is zero, i.e.,
% sum(D) = zeros(1,ymax*xmax) and D(idx,idx) = -1.*sum(D(idx,:)).
%
% Examples:
%
% A reaction-transport problem on a two dimensional domain with 10*10
% cells, zero flux boundary conditions and cells of octagonal shape:
% D = cm(10,10,[-1 1 0 0 -1 1 1 -1],[0 0 -1 1 1 -1 -1],1);
%
% First and second order cellular coupling on a one dimensional domain
% with 100 cells and periodic boundary conditions is defind as:
% D = cm(100,1,[-2 -1 1 2],[0 0 0 0],0);

if ~(size(ysten)==size(xsten))
  error('Unequal sizes of YSTEN and XSTEN')
end

n = ymax*xmax;
D = sparse(n,n);
idx = reshape(1:n,ymax,xmax);
for s=1:length(ysten)
  sidx = circshift(idx,[ysten(s) xsten(s)]);
  ind = sub2ind([n n],idx,sidx);
  if bflag 
    % zeroflux: remove indices of 'outside' cells
    if ysten(s)>0
      ry = 1:ysten(s);
    elseif ysten(s)<0
      ry = ymax:-1:ymax+ysten(s)+1;
    else
      ry = [];
    end
    if xsten(s)>0
      rx = 1:xsten(s);
    elseif xsten(s)<0
      rx = xmax:-1:xmax+xsten(s)+1;
    else
      rx = [];
    end
    ind(ry,:) = [];
    ind(:,rx) = [];
  end
  D(ind) = 1;
end
if cflag
  D = spdiags(-ones(n,1).*sum(D)',0,D);
end