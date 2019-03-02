%  function rePlotPDE([resimulate],[name])
%
% Plotting. 
%
% resimulate   [false]      resimulate PDE
% name         ['']         String with name of figure
%
% Options are set in re.plot
%
%  re.plot.px            [true]      plot parameter fields
%  re.plot.timespace_1d  [false]     plot heatmap with concentration over 
%                                    time and space, only used in 1dim space
%  re.plot.ts            [0:0.05:1]  indices, absolute or relative timepoints of plotting; 
%                                    if length(re.plot.idt)>1, all timepoints are plotted with pause. 
%                                    Use '+inf' for last timepoint
%  re.plot.qTimes        ['rel']     alternatives: 'ids', 'abs', 'rel' 
%                                    is in re.plot.ts indices, absolute timepoints or 
%                                    relative timepoints (between 0 and 1)  
% 
% See also: rePlotPDE2.m: a example to save a video.

function rePlotPDE(resimulate,name)

global re

if ~exist('resimulate','var')
    resimulate = 0;
end
if ~exist('name','var')
    name = '';
end

% For backwards compability. 
if ~isfield(re.plot, 'global_clims')
    re.plot.global_clims = 0; % 2dim: Use same colorscale for all timepoints 
end

if resimulate
    %disp('Simulating system...')
    reSimuPDESys;
end

if ~isfield(re.PDE,'Y')
    %disp('Simulating system...')
    reSimuPDESys;
end

%%%%%%%% to do: only indices in 1:length(re.PDE.t)
maxid = length(re.PDE.t);
switch re.plot.qTimes
    case 'abs'
        maxT = max(re.PDE.t);
        minT = min(re.PDE.t);
        ts = re.plot.ts;
        ts(ts<minT) = minT;
        ts(ts>maxT) = maxT;
        ts = unique(ts);
        idsTimes = round(interp1(re.PDE.t,1:maxid,ts));
    case 'ids'
        idsTimes = re.plot.ts;
        idsTimes(idsTimes<1) = 1;
        idsTimes(idsTimes>maxid) = maxid;
        idsTimes = round(unique(idsTimes));
    case 'rel'
        rels  = re.plot.ts;
        rels(rels<0)=0;
        rels(rels>1)=1;
        rels=unique(rels);
        idsTimes = round(interp1(linspace(0,1,maxid),1:maxid,rels));
        
end
%%%%%%%%%%
if re.PDE.xmax==1 || re.PDE.ymax==1
    % 1dim
    if re.plot.timespace_1d
        kindofplot = '1dim_spacetime';
        idsTimes = 1;
    else
        kindofplot = '1dim';
    end
else
    % 2dim
    kindofplot = '2dim';
end

nY = length(re.yLabel);

if re.plot.px
    nPlots = nY + length(re.pxLabel);
else
nPlots = nY;    
end

Y=NaN(maxid,re.PDE.xmax*re.PDE.ymax,nPlots);
for i = 1:nY
    Y(:,:,i)=re.PDE.Y(:,re.PDE.ctr+i-1);  % to do: reshape to 3 dim
end
for i = (nY+1):nPlots
    Y(:,:,i) = repmat(re.px(:,i-nY)',maxid,1);
end

ncols = ceil(nPlots^(0.45));
nrows = ceil(nPlots/ncols);

h=figure('Name',[re.modelname(1:end-4) '_: ' name]);
timestr = [];
%%%

for idT = idsTimes   
    for idplot = 1:nPlots
        subplot(nrows,ncols,idplot)
        switch kindofplot
            case '2dim'
                if re.plot.global_clims
                    clims = [min(min(Y(:,:,idplot))) max(max(Y(:,:,idplot)))];
                else
                    clims = [-inf inf];
                end
                imagesc(reshape(Y(idT,:,idplot),re.PDE.xmax,re.PDE.ymax)',clims)
                labelx = 'y';
                labely = 'x';
                timestr = [': T=' num2str(re.PDE.t(idT))];
            case '1dim_spacetime'
                imagesc(re.PDE.t,1:re.PDE.xmax,Y(:,:,idplot)')
                labelx = 'time';
                labely = 'space';
            case '1dim'
                plot(Y(idT,:,idplot)')
                labelx = 'space';
                labely = 'concentration';
                timestr = [': T=' num2str(re.PDE.t(idT))];
        end
        if idplot>((nrows-1)*ncols)
            xlabel(labelx)
        end
        if mod(idplot,ncols)==1
            ylabel(labely)
        end
        if idplot<nY+1
            title(['y: ' reNameTrafo(re.yLabel{idplot}) timestr])
        else
            title(['px: ' reNameTrafo(re.pxLabel{idplot-nY}) timestr])
        end
    end
    if length(idsTimes)>1 && idsTimes(end) > idT
        pause
    end
end
