% rePDE2ar()
%
%  Write the discretized PDE which is an ODE system to a D2D model def file.

function rePDE2ar()
global re;


fid = fopen(['Models/arModel_' re.modelname], 'w');

fprintf(fid, '%s\n' , 'DESCRIPTION');
fprintf(fid, '"Exported model from %s."\n', re.modelname);
fprintf(fid, '"%s"\n' , datestr(clock));
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'PREDICTOR');
fprintf(fid, '%s %f %f \n' , 't  T  h  time',re.PDE.t(1),re.PDE.t(end));
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'COMPARTMENTS');
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'STATES');
states_strings = cell(length(re.yLabel),length(re.PDE.ctr));
for idy = 1:length(re.yLabel)
    for idspace = 1:length(re.PDE.ctr)
        states_strings{idy,idspace} = sprintf('%s_%04d',re.yLabel{idy},idspace);
        fprintf(fid, '%s  C  au  conc.  0\n' , states_strings{idy,idspace});
    end
end
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'INPUTS');
fprintf(fid, '\n' );

eqSym = re.eqSymbolic;

fprintf(fid, '%s\n' , 'ODES');

re.ar.px = re.px; % todo: something similar to the initials, see below

for idy = 1:length(re.yLabel)
    for idspace = 1:length(re.PDE.ctr)
        eqSym1 = subs(eqSym(idy),  re.yLabel, states_strings(:,idspace)');
        for idpx = 1:length(re.pxOpt)
            eqSym2 = subs(eqSym1, re.pxLabel{idpx}, arSym(re.ar.px(idspace,idpx))); % todo, substitue parameterized function for px
        end
        eq_str = char(eqSym2);
        diff_str = '';
        if ~logical(re.D(idy,idy)==0)
            for idcm = 1:length(re.PDE.ctr)
                
                if re.PDE.D(idspace,idcm) ~= 0
                    diff_str = [diff_str '+(' num2str(re.PDE.D(idspace,idcm)) ')*' states_strings{idy,idcm}];
                end
            end
            subs_str = [eq_str '+' char(re.D(idy,idy)) '*(' diff_str ')'];
        else
            subs_str = eq_str;
        end
        fprintf(fid, '"%s"\n' , subs_str);
    end
end
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'DERIVED');
fprintf(fid, '\n' );

fprintf(fid, '%s\n' , 'CONDITIONS');

% If you want parameterized initials you can fill the field
% re.ar.y0_to_ar_str and set re.ar.qParameterized_initials = 1
if ~isfield(re, 'ar') || ~isfield(re.ar, 'qParameterized_initials')
    re.ar.qParameterized_initials = 0;
end 
if ~re.ar.qParameterized_initials % use numeric values for initials
    re.ar.y0_to_ar_str = sprintfc('%f', re.PDE.y0); 
    disp('Use numeric values saved in re.PDE.y0 as initials.') 
else
    if isfield(re.ar, 'y0_to_ar_str')
        disp('Using strings in re.ar.y0_to_ar_str as initials.') 
    else
        error('re.ar.y0_to_ar_str does not exist. Set re.ar.qParameterized_initials = 0 or define initials in re.ar.y0_to_ar_str')
    end
end

for idy = 1:length(re.yLabel)
    for idspace = 1:length(re.PDE.ctr)
        fprintf(fid, 'init_%s   "%s"\n', states_strings{idy,idspace}, re.ar.y0_to_ar_str{re.PDE.ctr(idspace) + idy - 1} );
    end
end
fprintf(fid, '\n' );



return;


% Replace everything with matlab array elements y_hash_1 = y(ctr,:); y_hash_2 =
% y(ctr+1,:) ...
eq_fkt = eq_hashed;
for ii=0:nStates-1
    replace = ['y(ctr+',int2str(ii),',:)'];
    eq_fkt = strrep(eq_fkt, y_hashes(ii+1),replace) ;
end

for ii=1:length(re.pLabel)
    replace = ['p(',int2str(ii),')'];
    eq_fkt = strrep(eq_fkt, p_hashes(ii),replace) ;
end

for ii=1:length(re.pxLabel)
    replace = ['px(:,',int2str(ii),')'];
    eq_fkt = strrep(eq_fkt, px_hashes(ii),replace) ;
end

for ii=1:length(re.uLabel)
    replace = ['u(:,',int2str(ii),')'];
    eq_fkt = strrep(eq_fkt, u_hashes(ii),replace) ;
end


% Dotwise multiplication, division, power
eq_fkt = strrep(eq_fkt, '*', '.*') ;
eq_fkt = strrep(eq_fkt, '/', './') ;
eq_fkt = strrep(eq_fkt, '^', '.^') ;

idif = 1;
for ii = 1:nStates
    replace1 = ['(ctr+',int2str(ii-1),',:)'];
    if logical(re.D(ii,ii) == 0)
        replace2 = [];
    else
        replace2 = ['+ d(' num2str(idif) ')*D* y(ctr+',int2str(ii-1),',:)'];
        idif = idif +1;
    end
    eq_fkt{ii}  = ['dydt' replace1 '=(' eq_fkt{ii} ')' replace2 ];
end

tmp  = sprintf('%s;\n',eq_fkt{:});

filename = ['RHS_PDE_' datestr(now,'yyyymmddHHMMSSFFF') '.m'];

if ~exist(fullfile(pwd, 'RHS_fcts'),'dir')
    mkdir('RHS_fcts')
    addpath('RHS_fcts/')
end
%fid = fopen(['RHS_fcts/' filename], 'w');
%fprintf(fid, '%s' ,'');
%fclose(fid);
% open the file with write permission
fid = fopen(['RHS_fcts/' filename], 'w');
fprintf(fid, '%s\n' ,'function dydt = RHS_PDE(t,y)');
fprintf(fid, '%s\n' , 'global re;');
fprintf(fid, '%s\n' , 'p=re.p;');
fprintf(fid, '%s\n' , 'px=re.px;');
fprintf(fid, '%s\n' , 'u=re.u;');
fprintf(fid, '%s\n' , 'D=re.PDE.D;');
fprintf(fid, '%s\n' , 'd=re.d;');
fprintf(fid, '%s\n' , 'ctr=re.PDE.ctr;');
fprintf(fid, '%s\n' ,'dydt = zeros(size(y));');
fprintf(fid, '%s\n' ,tmp);
fprintf(fid, '%s\n' ,'end');
fclose(fid);
re.PDE.RHS_fct = str2func(filename(1:end-2));
rehash
