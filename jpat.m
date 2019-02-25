function J = jpat(NVar,D,sysmat,diffmat)
% Returns a sparse matrix indicating the pattern of the jacobian matrix.
%
% J = JPAT(NVAR,D,SYSMAT,DIFFMAT). NVar is the number of species and D is
% the sparse coupling matrix. The optional input matrix SYSMAT indicates
% the system coupling, i.e., structure of the jacobian matrix of the
% single-cell system. By default SYSMAT = ones(NVar). The optional input
% argument DIFFMAT is a matrix indicating (cross-)diffusion. By default
% DIFFMAT = diag(diag(ones(NVar)))

if ~exist('sysmat','var') | isempty(sysmat)
  sysmat = ones(NVar); 
end
if ~exist('diffmat','var') | isempty(diffmat)
  diffmat = speye(NVar); 
end

Js = kron(speye(size(D)),sysmat); % system coupling
Jd = kron(spones(D),diffmat); % diffusive coupling
J = spones(Js+Jd);

  
  
