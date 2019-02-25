% example for writing a video

function rePlotPDE2(resimulate,name)

global re
movie=1;
if ~exist('resimulate','var')
    resimulate = 0;
end
if ~exist('name','var')
   name='myVideo';
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

h=figure('Name',re.modelname(1:end-4));
h.Position=[440 271 947 527];
timestr = [];
%%%
Ymax = max(Y,[],2);
Ymax = max(Ymax,[],1);
if movie ==1
   v = VideoWriter('newfile.avi'); 
end
countT=0;
for idT = idsTimes   
    countT=countT+1;
    for idplot = 1:nPlots
        subplot(nrows,ncols,idplot)
        switch kindofplot
            case '2dim'
                imagesc(reshape(Y(idT,:,idplot),re.PDE.xmax,re.PDE.ymax)')
                labelx = 'x';
                labely = 'y';
                timestr = [': T=' num2str(re.PDE.t(idT))];
                colorbar
                axis square
                myax = gca;
                myax.Position(3:4) = [0.2582 0.2919];
                
            case '1dim_spacetime'
                imagesc(Y(:,:,idplot)')
                labelx = 'time';
                labely = 'space';
            case '1dim'
                plot(Y(idT,:,idplot)','LineWidth',2)
                ylim([0 Ymax(1,1,idplot)*1])
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
    drawnow
    if movie ==1
        f(countT) = getframe(gcf);
    end
    
    if length(idsTimes)>1 && idsTimes(end) > idT
   %     pause
    end
end

if movie ==1 && ~strcmp(kindofplot,'1dim_spacetime')
   v = VideoWriter([name '_' kindofplot  '.avi']);

open(v)
writeVideo(v, f);
close(v)
end
