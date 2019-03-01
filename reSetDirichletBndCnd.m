% reSetDirichtletBndCnd
%
% Set the values at the boundary when using Dirichlet boundary conditions.
% It is possible to set a constant value for each side of the spatial
% domain. For the state re.yLabel{idy } these values are set in
%    re.PDE.BndCndOpts(idy).c_x1
%    re.PDE.BndCndOpts(idy).c_xend
%    re.PDE.BndCndOpts(idy).c_y1
%    re.PDE.BndCndOpts(idy).c_yend
%
% It is possible to selectively use Dirichlet boundary conditions, e.g.
% only for the upper boundary. For this set the other values to NaN, i.e
%    re.PDE.BndCndOpts(idy).c_x1  = myValue;
%    re.PDE.BndCndOpts(idy).c_xend = NaN;
%    re.PDE.BndCndOpts(idy).c_y1 = NaN;
%    re.PDE.BndCndOpts(idy).c_yend = NaN;
%
% You can also define custom values, for selected boundary regions.
% For this set the flag:
%    re.PDE.BndCndOpts(idy).kind = 'custom'
%
% The custom values has to be stored in the fields 
% re.PDE.idsBoundary and re.PDE.yBoundary. This uses the boundary values
% yBoundary at the indices idsBoundary. 
%
% It is also possible to define a custom function
%    reCustomDirichletBoundary.m
% in the working directory in which the boundary values are set to the fields
%    re.PDE.BndCndOpts(idy).yBoundary
% with the corresponding indices
%    re.PDE.BndCndOpts(idy).idsBoundary. 
% These values are then collected and saved in the fields
% re.PDE.idsBoundary and re.PDE.yBoundary. 
%
% The indices of the boundaries are saved in the fields:
%    re.PDE.BndCndOpts(idy).ids_x1     % Upper bnd (in 1dim: Left bnd)
%    re.PDE.BndCndOpts(idy).ids_xend   % Lower bnd (in 1dim: Right bnd)
%    re.PDE.BndCndOpts(idy).ids_y1     % Left bnd
%    re.PDE.BndCndOpts(idy).ids_yend   % Right bnd
%    re.PDE.BndCndOpts(idy).idsBoundary_clockwise  % All bnd indices clockwise starting from the upper left corner
% 
%
% See also /Examples/Dirichlet_boundary_conditions for different use cases.

function reSetDirichletBndCnd

global re

if ~strcmp(re.PDE.bndcondition,'dirichlet')
    warning('re.PDE.bndcondition is set to ''%s''. Set flag to ''dirichlet'' if you want to use Dirichlet boundary conditions.', re.PDE.bndcondition)
end

for idy = 1:length(re.yLabel)
    if strcmp(re.PDE.BndCndOpts(idy).kind,'constant')
        if re.PDE.ymax ~= 1 % 2 dim  
            f = ismember(re.PDE.BndCndOpts(idy).idsBoundary_clockwise, re.PDE.BndCndOpts(idy).ids_y1 );
            re.PDE.BndCndOpts(idy).yBoundary(f) = re.PDE.BndCndOpts(idy).c_y1;
 
            f = ismember(re.PDE.BndCndOpts(idy).idsBoundary_clockwise, re.PDE.BndCndOpts(idy).ids_yend );
            re.PDE.BndCndOpts(idy).yBoundary(f) = re.PDE.BndCndOpts(idy).c_yend;
        end
        
        f = ismember(re.PDE.BndCndOpts(idy).idsBoundary_clockwise, re.PDE.BndCndOpts(idy).ids_x1 );
        re.PDE.BndCndOpts(idy).yBoundary(f) = re.PDE.BndCndOpts(idy).c_x1;
        
        f = ismember(re.PDE.BndCndOpts(idy).idsBoundary_clockwise, re.PDE.BndCndOpts(idy).ids_xend );
        re.PDE.BndCndOpts(idy).yBoundary(f) = re.PDE.BndCndOpts(idy).c_xend;
        
        re.PDE.BndCndOpts(idy).idsBoundary = re.PDE.BndCndOpts(idy).idsBoundary_clockwise;
        if re.PDE.ymax ~= 1 % 2 dim
            fprintf('Boundary values of ''%s'' were set to constant values in re.PDE.BndCndOpts(%d): ''c_x1''= %d, ''c_xend''= %d, ''c_y1''= %d, ''c_yend''= %d\n',re.yLabel{idy},idy,re.PDE.BndCndOpts(idy).c_x1,re.PDE.BndCndOpts(idy).c_xend,re.PDE.BndCndOpts(idy).c_y1,re.PDE.BndCndOpts(idy).c_yend)
        else
            fprintf('Boundary values of ''%s'' were set to constant values in re.PDE.BndCndOpts(%d): ''c_x1''= %d, ''c_xend''= %d\n',re.yLabel{idy},idy,re.PDE.BndCndOpts(idy).c_x1,re.PDE.BndCndOpts(idy).c_xend)            
        end
    elseif strcmp(re.PDE.BndCndOpts(idy).kind,'custom')
        if exist('reCustomDirichletBoundary',5)
            reCustomDirichletBoundary;
        else
            if isfield(re.PDE,'yBoundary') && isfield(re.PDE,'idsBoundary')
                warning('re.PDE.BndCndOpts(idy).kind = ''custom'' but no custom boundary function provided. Values in re.PDE.idsBoundary and re.PDE.yBoundary are used for Dirichlet boundary conditions.')
            else
                error('re.PDE.BndCndOpts(idy).kind = ''custom'' but no custom boundary function provided. Please create the function reCustomDirichletBoundary.m which sets custom values in re.PDE.BndCndOpts(idy).yBoundary and re.PDE.BndCndOpts(idy).idsBoundary, or create directly the fields re.PDE.idsBoundary and re.PDE.yBoundary.')                
            end
            return
        end
    end
end

re.PDE.yBoundary = [];
re.PDE.idsBoundary = [];
for idy = 1:length(re.yLabel)
    re.PDE.yBoundary = [re.PDE.yBoundary re.PDE.BndCndOpts(idy).yBoundary];
    re.PDE.idsBoundary = [re.PDE.idsBoundary re.PDE.BndCndOpts(idy).idsBoundary];
end
re.PDE.idsBoundary(isnan(re.PDE.yBoundary)) = [];
re.PDE.yBoundary(isnan(re.PDE.yBoundary)) = [];

