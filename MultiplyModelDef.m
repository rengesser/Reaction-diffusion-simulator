
function MultiplyModelDef(name,replace,dup)

if ~exist('replace','var') || isempty(replace)
    error('DuplicateModelDef.m: No strings for replacement specified.\n')
end 
if(~exist('dup', 'var') || isempty(dup))
    dup = 1;
end

if(~exist('name', 'var') || isempty(name))
    filelist = dir('./Models/*.def');
    if length(filelist)==1
        name = filelist.name;
    else
        for j=1:length(filelist)
            fprintf('#%3i : %s \n', j, filelist(j).name);
        end
        name = input(['Please choose [1-' num2str(j) ']: '], 's');
        name = str2double(name);
    end
end
if(isnumeric(name)) % name is the file-number
    filelist = dir('./Models/*.def');   
    name = filelist(name).name;
end
if ~contains(name,'.')
    name = [name '.def'];
end
if ~exist(['Models/' name],'file')
    error(['DuplicateModelDef.m: Models/' name ' does not exist.\n'])
end
if isempty(name)
     error('DuplicateModelDef.m: No def file specified to duplicate.\n')
end

%% Write model .def
fin = fopen(['Models/' name]);
fout = fopen(['Models/' name(1:end-4) '_m.def'],'wt');
s = textscan(fin, '%s','delimiter','\n');
X = char(s{1}.');

%% STATES
idx(1) = find(strcmp(s{1}, 'DESCRIPTION'), 1, 'last');
idx(2) = find(strcmp(s{1}, 'STATES'), 1, 'last');
idx(3) = find(strcmp(s{1}, 'INPUTS'), 1, 'last');
if any(strcmp(s{1}, 'ODES'))
    idx(end+1) = find(strcmp(s{1}, 'ODES'), 1, 'last');
elseif any(strcmp(s{1}, 'REACTIONS'))
    idx(end+1) = find(strcmp(s{1}, 'REACTIONS'), 1, 'last');
end
idx(end+1) = find(strcmp(s{1}, 'DERIVED'), 1, 'last');
if any(strcmp(s{1}, 'OBSERVABLES'))
    idx(end+1) = find(strcmp(s{1}, 'OBSERVABLES'), 1, 'last');
end
if any(strcmp(s{1}, 'ERRORS'))
    idx(end+1) = find(strcmp(s{1}, 'ERRORS'), 1, 'last');
end
if any(strcmp(s{1}, 'CONDITIONS'))
    idx(end+1) = find(strcmp(s{1}, 'CONDITIONS'), 1, 'last');
elseif any(strcmp(s{1}, 'INITS'))
    idx(end+1) = find(strcmp(s{1}, 'CONDITIONS'), 1, 'last');
end
idx(end+1) = size(X,1);

for id=1:length(idx)-1
    if ~(id==1 || id==3) && idx(id)>0
        fprintf(fout,'%s\n',X(idx(id),:));
        for i=1:dup
            for j=idx(id)+1:idx(id+1)-1
                if ~strncmp(X(j,:),'//',2)
                    Y = X(j,:);
                    if contains(Y,'2') && contains(Y,'3')
                        if i>1 && i<dup
                            Y = strrep(Y,'3',num2str(i+1));
                            Y = strrep(Y,'2',num2str(i));
                            Y = strrep(Y,'1',num2str(i-1));                
                        end
                    else
                        for k=1:length(replace)
                            idxrep = regexp(Y,[replace{k} '\W']);
                            for l=1:length(idxrep)
                                Y = [Y(1:idxrep(l)+2*l-3) replace{k} num2str(i) ' ' Y(idxrep(l)+length(replace{k})+2*l-2:end)];
                            end

                        end
                    end
                    fprintf(fout,'%s\n',Y);
                end
            end
            fprintf(fout,'\n');
        end
    end
end

fclose(fout);

