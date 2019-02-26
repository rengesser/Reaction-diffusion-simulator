
function retoarModelDef(name,replace,dup)

if ~exist('replace','var') || isempty(replace)
    replace = false;
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
fid = fopen(['Models/' name]);
fout = fopen(['Models/' name(1:end-4) '_D2D.def'],'wt');

%% Description / Predictor / Compartments
str = textscan(fid,'%s',1);
fprintf(fout,'%s\n','DESCRIPTION');
while(~strcmp(str{1},'STATES'))
    fprintf(fout,'%s',str{1}{:});
    str = textscan(fid,'%s',1);
end
fprintf(fout,'\n\n%s\t%s\n','PREDICTOR','t	T	"min"	"time"	0	40');
fprintf(fout,'\n%s\t%s\n','COMPARTMENTS','cyt	V	"pl"	"vol."	');

%% STATES
fprintf(fout,'\n%s\n','STATES');
states={};
str = textscan(fid,'%s%d',1,'commentStyle','//');
while(~strcmp(str{1},'EQUATIONS'))
    states(end+1) = str{1};
    fprintf(fout,'%s\n',[str{1}{:} ' C	"au"	"conc."	cyt']);
    str = textscan(fid, '%q%d', 1, 'commentStyle', '//');
end

%% Equations
fprintf(fout,'\n%s\n','INPUTS');
fprintf(fout,'\n%s\n','ODES');
eq={};
str=textscan(fid,'%q',1,'commentStyle','//');
while(~strcmp(str{1},'PARAMETERFIELDS'))
   eq{end+1}=str{:}{:};
   fprintf(fout,'%s\n',['"' str{:}{:} '"']);
   str=textscan(fid,'%q',1,'commentStyle','//');
end
if length(eq)~=length(states)
    error('Number of equations must equal number of states!')
end
for i = 1:length(eq)
    helperCheckReservedWords(symvar(eq{i}),states{i});    
end


%% DERIVED
fprintf(fout,'\n%s\n','DERIVED');
str=textscan(fid,'%s',1,'commentStyle','//');
while(~strcmp(str{1},'DERIVED'))                    % ignore PARAMETERFIELDS, wait for DERIVED
    str=textscan(fid,'%s',1,'commentStyle','//');
end
str=textscan(fid,'%s%q',1,'commentStyle','//');
while(~strcmp(str{1},'INITS'))
    fprintf(fout,'%s\t%s\n',str{1}{:},['"' str{2}{:} '"']);
    str=textscan(fid,'%s%q',1,'commentStyle','//');
end

%% INITS
fprintf(fout,'\n%s\n','CONDITIONS');
str=textscan(fid,'%s%s%s%s%s%s',1,'commentStyle','//');
while(~isempty(str{1}))
    fprintf(fout,'%s\t%s\n',['init_' str{1}{:}],['"' str{3}{:} '"']);
    str=textscan(fid,'%s%s%s%s%s%s',1,'commentStyle','//');
end

fclose(fout);
MultiplyModelDef([name(1:end-4) '_D2D.def'],replace,dup);

