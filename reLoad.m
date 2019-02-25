function reLoad(name)
% name can be the number of the resultsfolder, the exact name or empty

evalin('base','clear re')
evalin('base','global re')
addpath('RHS_fcts')
if ~exist('name','var')
    workspace_path = helperGetSavePath;
else
    workspace_path = helperGetSavePath(name);
end

try
    load(['Results/' workspace_path '/workspace.mat'])
    fprintf(1,'Loading of Results/%s/workspace.mat successful \n',workspace_path);
catch
    error(['Results/' workspace_path '/workspace.mat does not exists!'])
end
