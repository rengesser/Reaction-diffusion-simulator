tic
disp('Simulating system ...')
[~, re.PDE.Y] = ode15s(re.PDE.RHS_fct, re.PDE.t , re.PDE.y0,re.PDE.options);
fprintf(1,'Simulated model %s on a %ix%i grid: Elapsed time %.2f min \n',re.modelname,re.PDE.xmax,re.PDE.ymax,toc/60)
