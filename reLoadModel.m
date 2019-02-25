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
str=textscan(fid,'%s','commentStyle','//');
parafields=str{:};

% 
eqSymbolic  = arSym(eq);
variables=symvar(eqSymbolic);

for i=1:length(variables)
    variables_cell{i} = char(variables(i));
end
id_paras  = ~ismember(variables_cell,states);

p_px_Label = variables_cell(id_paras); 

id_p = ~ismember(p_px_Label,parafields);
id_px = ismember(p_px_Label,parafields);
pLabel = p_px_Label(id_p);
pxLabel = p_px_Label(id_px);

if length(pxLabel) ~= length(parafields)
    id_notdefined = ~ismember(parafields,pxLabel);
    warning(sprintf('\nThe parameterfield "%s" is not used in the model equations!',parafields{id_notdefined}))
end

dSym = symvar(sym(dd));
for i=1:length(dSym)
    dLabel{i} = char(dSym(i));
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
re.pFromAr = 0;
