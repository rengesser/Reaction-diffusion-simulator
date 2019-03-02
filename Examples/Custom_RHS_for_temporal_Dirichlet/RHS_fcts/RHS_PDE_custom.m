function dydt = RHS_PDE(t,y)

global re;
p=re.p;
px=re.px;
u=re.u;
D=re.PDE.D;
d=re.d;
ctr=re.PDE.ctr;
if strcmp(re.PDE.bndcondition,'dirichlet')
    % This line is added by hand. The left boundary is set to a oscillating
    % wave.
    y(re.PDE.idsBoundary,:) = re.A+re.A*sin(re.omega*2*pi*t-2*pi*re.PDE.idsBoundary/5000);
end
dydt = zeros(size(y));
dydt(ctr+0,:)=(p(1) - p(2).*y(ctr+0,:) + (p(3).*y(ctr+0,:).^2)./(y(ctr+1,:).*(p(5).*y(ctr+0,:).^2 + 1)))+ d(1)*D* y(ctr+0,:); % activator
dydt(ctr+1,:)=((p(3).*y(ctr+0,:).^2)./(p(5).*y(ctr+0,:).^2 + 1) - p(4).*y(ctr+1,:))+ d(2)*D* y(ctr+1,:); % inhibitor

