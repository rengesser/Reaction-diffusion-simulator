tic


re.PDE.options.Vectorized = 'off';

disp('Simulating system ...')
[~, re.PDE.Y] = ode15s(re.PDE.RHS_fct, re.PDE.t , re.PDE.y0,re.PDE.options);

% Set boundary values in the simulations results to the used values.
[IDS,T] = meshgrid(re.PDE.idsBoundary,re.PDE.t);
if strcmp(re.PDE.bndcondition,'dirichlet')
    re.PDE.Y(:,re.PDE.idsBoundary) = re.A+re.A*sin(re.omega*2*pi*T-2*pi*IDS/5000);
end
fprintf(1,'Simulated model %s on a %ix%i grid: Elapsed time %.2f min \n',re.modelname,re.PDE.xmax,re.PDE.ymax,toc/60)
