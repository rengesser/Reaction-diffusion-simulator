function reLoadPars(name)
global re
if ~exist('name','var')
    workspace_path = helperGetSavePath;
else
    workspace_path = helperGetSavePath(name);
end

    W = load(['Results/' workspace_path '/workspace.mat']);

idsold = zeros(size(W.re.p));
idsnew = zeros(size(re.p));

fprintf(1, 'parameters loaded from file %s:\n', workspace_path);
for idp = 1:length(re.pLabel)
    ids = strcmp(W.re.pLabel,re.pLabel{idp});
    
    if any(ids)
        re.p(idp) = W.re.p(ids);
        idsold(ids) = 1;
        idsnew(idp) = 1;
        fprintf(1, '          assigned -> %s\n', re.pLabel{idp});
    else
        fprintf(1, '                      %s\n', re.pLabel{idp});
    end
end

nnot = length(idsnew)-sum(idsnew);
if ( nnot > 0 )
    fprintf(1, '%i parameters were assigned in the destination model (%i not assigned).\n',sum(idsnew),nnot);
    if(nnot<=30 && nnot>0)
        arFprintf(1, 'Not assigned are: %s \n',sprintf('%s, ',re.pLabel{idsnew==0}));
    end
else
    fprintf(1, 'All parameters assigned.\n');
end

nnot = length(W.re.p)-sum(idsnew);
if ( nnot > 0 )
    fprintf(1, 'There were %i more parameters in the loaded struct than in the target model:\n',nnot);
    if(nnot<=30 && nnot>0)
        fprintf(1, 'Not assigned are: %s \n',sprintf('%s, ',W.re.pLabel{idsold==0}));
    end
end







    
    