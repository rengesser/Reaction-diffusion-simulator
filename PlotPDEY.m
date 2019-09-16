function PlotPDEY

global ar

n = ar.model.nobs;
% Figure settings
s = ceil(length(ar.model.data(1).y)/n);
s1 = floor(sqrt(s));
s2 = ceil(s/s1);
C = {'k','b','r','g','y'};

figure; set(gcf,'units','points','position',[0,0,1000,500])
for i=1:s
    subplot(s1,s2,i)
    hold on
    chi2 = 0;
    for d=1:length(ar.model.data)
        x = (i-1)*n+1:i*n;
        % Get simu
        [~,idxt] = min(abs(ar.model.data(1).tFine - ar.model.data(d).tExp)); % Where in simu is time of data
        y = ar.model.data(d).yFineSimu(idxt,x);
        e = ar.model.data(d).ystdFineSimu(idxt,x);
        % error band
        lo = y - e;
        hi = y + e;
        hp = patch([x, x(end:-1:1), x(1)], [lo, hi(end:-1:1), lo(1)], C{d},'FaceAlpha',.3,'EdgeColor','none','HandleVisibility','off');
        plot(x,y,C{d},'LineWidth',1)%,'marker','x')        
        % data points
        plot(x,ar.model.data(d).yExp(x),'o','MarkerFaceColor',C{d},'MarkerEdgeColor',C{d},'HandleVisibility','off')
        %errorbar(x,ar.model.data(d).yExp(x),ar.model.data(d).yExpStd(x),'o','Color',C{d},'HandleVisibility','off')
        % chi2
        chi2 = chi2 + ar.model.data(d).chi2(i) + ar.model.data(d).chi2err(i);
    end
    obs = split(ar.model.data(1).y{i*n},'_');
    title(obs{1}, 'FontSize', 14)
    if i==1
        legend(ar.model.plot(i).condition)
    end
    yl = get(gca,'Ylim');
    text(x(1)+1,yl(2)*0.95,['LL = ' num2str(round(chi2))],'FontSize',12)
    if i>s2*(s1-1)
        xlabel('Position [au]')
    end
    xticks([])
    if rem(i-1,s2)==0
        ylabel('conc. [au]')
    end
    set(gca,'FontSize',12)
end
    