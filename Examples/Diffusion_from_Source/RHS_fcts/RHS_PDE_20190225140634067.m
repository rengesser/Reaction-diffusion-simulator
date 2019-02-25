function dydt = RHS_PDE(t,y)
global re;
p=re.p;
px=re.px;
u=re.u;
D=re.PDE.D;
d=re.d;
ctr=re.PDE.ctr;
dydt = zeros(size(y));
dydt(ctr+0,:)=(px(:,1) - p(4).*y(ctr+0,:))+ d(1)*D* y(ctr+0,:);
dydt(ctr+1,:)=((p(3).*y(ctr+0,:).^2)./(p(1).^2 + y(ctr+0,:).^2) - p(5).*y(ctr+1,:));
dydt(ctr+2,:)=(p(2) - p(6).*y(ctr+2,:) - p(7).*y(ctr+1,:).*y(ctr+2,:));

end
