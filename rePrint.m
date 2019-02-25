% Print parameter values. Todo: print information about initial
% concentrations and parameter fields

function rePrint

global re

maxlabellength1 = max(cellfun(@length, re.pLabel));
maxlabellength2 = max(cellfun(@length, re.dLabel));
maxlabellength = max(maxlabellength2,maxlabellength1);

for idp = 1:length(re.p)
    fprintf(1,'#%3i | %s | %+6.3g \n',idp , extendStr(re.pLabel{idp},maxlabellength,'left'),re.p(idp) );
    if ~mod(idp,5) && idp < length(re.p)
        fprintf(1,['     | ' extendStr('',maxlabellength,'left') ' |   \n']);
    end
end
        fprintf(1,['     | ' extendStr('',maxlabellength,'left') ' |   \n']);
        
for idd = 1:length(re.d)
    fprintf(1,'#%3i | %s | %+6.3g \n',idd , extendStr(re.dLabel{idd},maxlabellength,'left'),re.d(idd) );
    if ~mod(idd,5) && idd < length(re.d)
        fprintf(1,['     | ' extendStr('',maxlabellength,'left') ' |   \n']);
    end
end


    
function str = extendStr(str,n,formatting)
    if ~exist( 'formatting', 'var' )
        formatting = 'left';
    end
    switch( formatting )
        case 'left'
            nd = n - length(str);
            S = ' ';
            str = [str S(ones(1,nd))];
    end