% Set values of a initial distributions of states. 
% Properties are stored in re.Y0opt
% Values are stored in re.px
% Corresponding labels are stored in re.yLabel
% 
% idY0    [all]   index of state

function reSetY0(idY0)
% re.Y0opt.kind:
% ['xstep'], 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant','random'
% re.Y0opt.x0: middle of circle, gaussians, step or range
% re.Y0ot.c:  multiplicative constant which determines max(Y0(ctr,:))
% re.Y0opt.sigma: variance of gaussians

global re

if ~isfield(re.PDE, 'y0') 
    re.PDE.y0 = NaN(re.PDE.xmax*re.PDE.ymax*length(re.yLabel),1);
end
if ~exist('idY0','var')
    for i=1:length(re.yLabel)
        reSetY0(i);
    end
    return
end

if idY0>length(re.yLabel)
    warning(['Only ' num2str(length(re.yLabel)) ' states existing.'])
    return
end

if ~isfield(re,'Y0opt') % standard values
    for i=1:length(re.yLabel)
        re.Y0opt(i).kinds = {'xstep', 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant','random'};
        re.Y0opt(i).idkind = 6;
        re.Y0opt(i).x0 = [0.05 0.5];
        re.Y0opt(i).sigma = 0.05;
        re.Y0opt(i).c = 1;
    end
else
    for i=1:length(re.Y0opt)
        re.Y0opt(i).kinds = {'xstep', 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant','random'};
    end
end

kind = re.Y0opt(idY0).kinds{re.Y0opt(idY0).idkind};
if isfield(re.Y0opt(idY0),'x0')
    x0 = re.Y0opt(idY0).x0;
end
if isfield(re.Y0opt(idY0),'sigma')
    sigma = re.Y0opt(idY0).sigma;
end
c = re.Y0opt(idY0).c;

[x, y] = meshgrid(linspace(0,1,re.PDE.xmax),linspace(0,1,re.PDE.ymax));
x=x';
y=y';


%%%%%
switch kind
    case 'constant'
        Y0(:) = c;
    case 'random'
        Y0 = c * ones(size(x)) .* (1+ sigma .* randn(size(x)));
    case 'circle'
        % circle around x0
        Y0 = c * ( (x-x0(1)).^2+(y-x0(2)).^2<sigma );
        if re.PDE.ymax == 1
            Y0 = c * ( (x-x0(1)).^2<sigma );
        end
    case '2dgaussian'
        % 2 dim gaussian around x0
        Y0 = c * exp( - ((x-x0(1)).^2 - (y-x0(2)).^2)/2/sigma^2 );
    case 'xstep'
        % step: x<x0 =1, x>x0 = zero
        Y0 = c * (x<x0(1));
    case '1dgaussian'
        if c>=0
            Y0 = c * exp( - ((x-x0(1)).^2)/2/sigma^2 );
        else
            Y0 =  c * exp( - ((x-x0(1)).^2)/2/sigma^2 );  % invert gaussian, outside high, inside low
            Y0 = Y0 - max(Y0) -c;
        end
    case 'xrange'
        if sigma~=1
            Y0 = c * (x>=x0(1) & x<=x0(2));
            Y0(Y0==0) = 1e-6;
        else
            Y0 = c * (x<x0(1) | x>x0(2));                 % if sigma=1, xrange at start/end
        end
end

re.Y0opt(idY0).Y0 = Y0(:);
re.PDE.y0(re.PDE.ctr+idY0-1,1) = Y0(:); 