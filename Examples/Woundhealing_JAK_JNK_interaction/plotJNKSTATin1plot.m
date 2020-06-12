
idJNK = find(strcmp(re.yLabel,'JNK'));
idJAK = find(strcmp(re.yLabel,'JAK'));

J = re.PDE.Y(end,re.PDE.ctr+idJNK-1);
S = re.PDE.Y(end,re.PDE.ctr+idJAK-1);

J = J/max(J(:));
S = S/max(S(:));

plot(S,'b','LineWidth',2)
hold on 
plot(J,'r','LineWidth',2)
hold off

legend('JAK/STAT','JNK')
ylabel('concentration [au]')
xlabel('space [au]')
grid on
ylim([-0.1 1.1])