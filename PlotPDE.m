function PlotPDE(X,Y,Z)

global ar

if ~exist('X','var') || isempty(X)
    X = true;                       % Plot States      [true]
end
if ~exist('Y','var') || isempty(Y)
    Y = true;                       % Plot Observables [true]
end
if ~exist('Z','var') || isempty(Z)
    Z = true;                       % Plot Derived     [true]
end

if Y
    PlotPDEY
end
if X || Z
    if X
        nPlots = length(ar.model.x);
    elseif Y
        nPlots = length(ar.model.data);
    elseif Z
        nPlots = nPlots + length(ar.model.z);
    end
    
    % Figure settings
    figure; set(gcf,'units','points','position',[0,0,1000,500])
    n = ar.model.nobs;
    s = ceil(nPlots/n);
    s1 = floor(sqrt(s));
    s2 = ceil(s/s1);
    for c=1:length(ar.model.condition)
        [~,idxt(c)] = min(abs(ar.model.condition(c).tFine - ar.model.data(c).tExp)); % Where in simu is time of data
    end

    if X
        plotgroup('xFineSimu','x',s1,s2,idxt,0)
        cplot = length(ar.model.x)/n;
    else
        cplot = 0;
    end
    if Z
        plotgroup('zFineSimu','z',s1,s2,idxt,cplot)
    end
end
end

function plotgroup(field,namefield,s1,s2,idxt,s3)

global ar

names = ar.model.(namefield);
for c = 1:length(ar.model.condition)
    if c==1
        data = ar.model.condition(c).(field);
    else
        data(:,:,c) = ar.model.condition(c).(field);
    end
end
n = ar.model.nobs;

for i=1:length(names)/n
    subplot(s1,s2,s3+i)
    hold on
    
    for c=1:length(ar.model.condition)
        x = (i-1)*n+1:i*n;
        plot(data(idxt(c),x,c),'LineWidth',3)
    end
    
    obs = split(names{i*n},'_');
    title([namefield ': ' obs{1}])
    if s3+i==1
        if ~isempty(ar.model.plot(i).condition)
            legend(ar.model.plot(i).condition)
        elseif ~isempty(ar.model.data(ar.model.plot(i).dLink).condition.parameter) && ~isempty(ar.model.data(ar.model.plot(i).dLink).condition.value)
            legend('ubx=0','ubx=1')       
        end
    end
    if s3+i>s2*(s1-1)
        xlabel('position [au]')
    end
    xticks([])
    if rem(i-1,s2)==0
        ylabel('conc. [au]')
    end
    set(gca,'FontSize',12)
end
end
