arInit
arLoadModel('arModel_Diffusion_from_source')

arCompileAll
arSimu(0,1,1)

re.PDE.Yar=NaN(size(ar.model.condition.xFineSimu));

for idy = 1:length(re.yLabel)
    re.PDE.Yar(:,re.PDE.ctr + idy - 1) = ar.model.condition.xFineSimu(:,(1:re.PDE.xmax)+(idy-1)*re.PDE.xmax);
end
re.PDE.tar = ar.model.condition.tFine; 