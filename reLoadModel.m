function reLoadModel(name)
clear -global re
global re;


if ~exist('name','var')
  error('Please specify a model name.')
end
if length(name)>3 
    if ~strcmp(name(end-3:end),'.def')
        name = [name '.def'];
    end
else
   name = [name '.def']; 
end


if ~exist(['Models/' name],'file')
   error(['The File ' name ' does not exist in the subfolder Models/']) 
end
fid = fopen(['Models/' name], 'r');

%%% States
str=textscan(fid,'%s',1,'commentStyle','//');
if(~strcmp(str{1},'STATES'))
    error('parsing model %s for STATES', name);
end

str = textscan(fid,'%s%d',1,'commentStyle','//');
states={};
dd={};
while(~strcmp(str{1},'EQUATIONS'))
    states(end+1) = str{1};
    if str{2}
        dd{end+1}=['d_' states{end}];
    else
        dd{end+1} = '0';
    end
    str = textscan(fid, '%q%d', 1, 'commentStyle', '//');
end

nstates = length(states);

%%% Equations
   str=textscan(fid,'%q',1,'commentStyle','//');
eq={};
while(~strcmp(str{1},'PARAMETERFIELDS'))
   eq{end+1}=str{:}{:};
   str=textscan(fid,'%q',1,'commentStyle','//');
end
if length(eq)~=nstates
    error('Number of equations must equals number of states!')
end

for i = 1:length(eq)
    helperCheckReservedWords(symvar(eq{i}),states{i});    
end
% % PARAMETERFIELDS (space dependent parameters, denoted with px)
str=textscan(fid,'%s',1,'commentStyle','//');
parafields={};
if ~isempty(str{1})
    while(~strcmp(str{1},'INITS') && (~strcmp(str{1},'DERIVED')))
        parafields(end+1)=str{:};
        str=textscan(fid,'%s',1,'commentStyle','//');
        if isempty(str{1})
            break
        end
    end
end

%%% DERIVED
z = {}; fz = {};
str=textscan(fid,'%q%q',1,'commentStyle','//');

while(~strcmp(str{1},'INITS'))
    z(end+1) = str{1};
    fz{end+1} = str{2}{:};
    str=textscan(fid,'%q%q',1,'commentStyle','//');
end

%%INITS  // name kind c x0(1) x0(2) sigma
re.Y0opt = struct('names',{},'idkind',[],'c',[],'x0',[],'sigma',[]);

% Set default values
for ids=1:nstates
    re.Y0opt(ids).kinds = {'xstep', 'circle', '2dgaussian', '1dgaussian', 'xrange', 'constant','random'};
    re.Y0opt(ids).idkind = 6;
    re.Y0opt(ids).x0 = [0.05 0.5];
    re.Y0opt(ids).sigma = 0.05;
    re.Y0opt(ids).c = 1;
end

str=textscan(fid,'%s%f%f%f%f%f','commentStyle','//');
if ~isempty(str)
    for i=1:size(str{1},1)
        re.Y0opt(i).names = str{1}{i};
        re.Y0opt(i).idkind=str{2}(i);
        re.Y0opt(i).c=str{3}(i);
        re.Y0opt(i).x0=str{4}(i);
        re.Y0opt(i).x0(2)=str{5}(i);
        re.Y0opt(i).sigma=str{6}(i);
    end
end
if length(re.Y0opt)~=nstates
    warning('reLoadModel: Not all inits set in def file.')
end
 
eqSymbolic  = arSym(eq);
variables=symvar(eqSymbolic);

for i=1:length(variables)
    variables_cell{i} = char(variables(i));
end
id_paras  = ~ismember(variables_cell,states);

p_px_Label = variables_cell(id_paras); 

pLabel = p_px_Label(~ismember(p_px_Label,parafields));
pxLabel= p_px_Label( ismember(p_px_Label,parafields));

if length(pxLabel) ~= length(parafields)
    id_notdefined = ~ismember(parafields,pxLabel);
    warning(sprintf('\nThe parameterfield "%s" is not used in the model equations!',parafields{id_notdefined}))
end

dSym = sym(dd);
dcount = 0;
for i=1:length(dSym)
    dstr = char(dSym(i));
    if ~strcmp(dstr,'0')
        dcount = dcount + 1;
        dLabel{dcount} = dstr;
    end
end

inter = intersect(pLabel, dLabel);
if ~isempty(inter)
   error('Fatal error: The format "d_STATE" is reserved for diffusion parameters. Problematic are the dynamical parameter(s): %s', sprintf('%s ', inter{:}));
end

re.modelname = name;
re.eq=eq';
re.eqSymbolic = eqSymbolic;

re.yLabel = states;
re.ySymbolic = sym(states,'clear');

re.z = z;
re.fz = arSym(fz);

re.pLabel = pLabel;
re.pSymbolic =pLabel;

re.pxLabel = pxLabel;

re.dLabel = dLabel;
re.dSym = dSym;
re.D = diag(sym(dd));  % Diffusion matrix
% states / y  : y1 ... yn
% paras / p   : p1 ... pn
% paras_x / px : px1 ... pxn
re.uLabel = {};
re.pFromAr = 0;  % Is the model assembled from a Data2dynamics model

re.ar.qParameterized_initials = 0;  % when exporting the model to a D2D model file: Use a parameterized initial function