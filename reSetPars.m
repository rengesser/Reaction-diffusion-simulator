% pL    String with parameter name
% p     Parameter value

function reSetPars(pL,p)
global re

for i = 1:length(re.pLabel)
    if strcmp(char(re.pLabel(i)),pL)
        re.p(i)=p;
        return;
    end
end
for i = 1:length(re.dLabel)
    if strcmp(char(re.dLabel(i)),pL)
        re.d(i)=p;
        return;
    end
end

disp([pL ' not found!'])
