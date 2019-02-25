function idx = IJKth(s,y,x,ymax,NVar)
% Grid index of species s at grid position (y,x).
%
% IDX = IJKTH(S,Y,X,YMAX,NVAR)
%
% YMAX is the number of grid points in y dirction. NVAR is number of
% species in the reaction diffusion problem. The index is calculated as:
% idx = s + (y-1)*NVar + (x-1)*ymax*NVar. The 'speed' of the subindices
% is in the order fastest to slowest: s, y, x.
%
% Examples:
%
% Indices of the first species on a 20*20 grid in a problem with
% four species:
%
% idx = IJKth(1,1:20,1:20,20,4)

xp = repmat((x-1).*(ymax*NVar),length(y),1);
yp = repmat(((y-1).*NVar)',1,length(x));
idx = xp + yp + s;
idx = idx(:);