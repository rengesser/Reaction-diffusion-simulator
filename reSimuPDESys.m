tic

if strcmp(re.PDE.bndcondition,'dirichlet')
   re.PDE.options.Vectorized = 'off';
end
if strcmp(re.PDE.bndcondition,'dirichlet')
    re.PDE.y0(re.PDE.idsBoundary) = re.PDE.yBoundary;
end

disp('Simulating system ...')
[~, re.PDE.Y] = ode15s(re.PDE.RHS_fct, re.PDE.t , re.PDE.y0,re.PDE.options);

if strcmp(re.PDE.bndcondition,'dirichlet')
    re.PDE.Y(:,re.PDE.idsBoundary) = repmat(re.PDE.yBoundary,size(re.PDE.Y,1),1);
end
fprintf(1,'Simulated model %s on a %ix%i grid: Elapsed time %.2f min \n',re.modelname,re.PDE.xmax,re.PDE.ymax,toc/60)
