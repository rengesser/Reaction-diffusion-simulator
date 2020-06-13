% Set values of a parameter field. 
% Properties are stored in re.pxOpt
% Values are stored in re.px
% Corresponding labels are stored in re.pxLabel
%
% idY0    [all]   index of parameter field

function reSetPx(idpx)
% re.pxOpt.kind:
% ['xstep'], 'circle', '2dgaussian', 'constant', '1dgaussian', 'xrange'
% re.pxOpt.x0: middle of circle, gaussians, step or range
% re.pxOpt.c:  multiplicative constant which determines max(px(:))
% re.pxOpt.sigma: variance of gaussians; radius of circle


global re

if ~exist('idpx','var')
    for i=1:length(re.pxLabel)
        reSetPx(i);
    end
    return
end

if idpx>length(re.pxLabel)
    warning(['No parameterfield at re.px(' num2str(idpx) ')'])
    return
end

if ~isfield(re,'pxOpt') % standard values
    for i=1:length(re.pxLabel)
        re.pxOpt(i).kinds = {'xstep', 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant'};
        re.pxOpt(i).idkind = 1;
        re.pxOpt(i).x0 = [0.05 0.5];
        re.pxOpt(i).sigma = 0.3;
        re.pxOpt(i).c = 1;
    end
end

if ~isfield(re.pxOpt(idpx),'x0')
    re.pxOpt.x0 = [0.5 0.5];
end

if ~isfield(re.pxOpt(idpx),'sigma')
    re.pxOpt(idpx).sigma = 0.3;
end

if ~isfield(re.pxOpt(idpx),'idkind')
    re.pxOpt(idpx).idkind = 1;
end

if ~isfield(re.pxOpt(idpx),'kinds')
    re.pxOpt(idpx).kinds = {'xstep', 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant'};
end

if ~isfield(re.pxOpt(idpx),'c')
    re.pxOpt(idpx).c = 1;
end

if ~isfield(re.pxOpt, 'kind')
    kind = re.pxOpt(idpx).kinds{re.pxOpt(idpx).idkind};
else
    kind = re.pxOpt.kind;
end

x0 = re.pxOpt(idpx).x0;
sigma = re.pxOpt(idpx).sigma;
c = re.pxOpt(idpx).c;

[x, y] = meshgrid(linspace(0,1,re.PDE.xmax),linspace(0,1,re.PDE.ymax));
x=x';
y=y';

switch kind
    case 'constant'
        px = c * (x==x);
    case 'circle'
        % 2dim circle around x0 with radius sigma
        px = c * ( (x-x0(1)).^2+(y-x0(2)).^2<sigma^2 );
        if re.PDE.ymax == 1
            px = c * ( (x-x0(1)).^2<sigma^2 );  % also possible with xrange
        end
    case '2dgaussian'
        % 2 dim gaussian around x0
        px = c * exp( - ((x-x0(1)).^2 - (y-x0(2)).^2)/2/sigma^2 );
    case 'xstep'
        % step: x<x0 =c, x>x0 = zero
        px = c * (x<x0(1));
    case '1dgaussian'
        px = c * exp( - ((x-x0(1)).^2)/2/sigma^2 );
    case 'xrange'
        % c for x in (x0(1) x0(2))
        px = c * (x>x0(1) & x<x0(2));
end

re.px(:,idpx) = px(:);
