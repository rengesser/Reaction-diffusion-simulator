function workspace_path = helperGetSavePath(name);

if(~exist('name', 'var') || isempty(name))
    workspace_path = uigetdir('Results','Select a results folder');
    if ~workspace_path 
        disp('Error: No folder chosen!')
        return;
    end
    if strcmp(workspace_path((end-7):end),'/Results')
        disp('Error: No folder chosen!')
        return;
    end         
    ids = strfind(workspace_path,filesep);
    workspace_path = workspace_path((ids(end)+1):end);
elseif(isnumeric(name)) % workspace_name is the file-number
    id_workspace = name;
    if floor(id_workspace)~=id_workspace % test if integer
        disp('Error: Workspace has to deterimed by positive integer number')
        return;
    end
    resultfolders = fileList('Results'); 
    str_id = sprintf('%03i',id_workspace);
    ids = [];
    for i = 1:length(resultfolders)
        if findstr(resultfolders{i},str_id)
            ids = [ids i];
        end
    end
    if isempty(ids)
        disp(['Error: No Workspace containing ' str_id])
        return;
    end
    if length(ids)>1
        disp(['Error: Multiple Workspaces containing ' str_id])
        for kk = 1:length(ids)
            fprintf(1,'%s\n',resultfolders{ids});
        end
        return;
    end
    workspace_path = resultfolders{ids};
elseif(ischar(name)) 
    [~,workspace_path]=fileparts(name);    % extract path of folder to load
end
