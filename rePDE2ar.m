% rePDE2ar()
%
%  Write the discretized PDE which is an ODE system to a D2D model def file.
%
% See Examples/Export_to_D2D for a simple use case. 

function rePDE2ar(obs)
global re

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
if isfield(re,'input')
    for idi = 1:length(re.input)
        for idspace = 1:length(re.PDE.ctr)
            if idspace == round(length(re.PDE.ctr)/2)
                fprintf(fid, '%s_%04d  C  au  conc. "%03d" \n' , re.input(idi).name, idspace, re.input(idi).concmax);
            elseif idspace == round(length(re.PDE.ctr)/2)+1 || idspace == round(length(re.PDE.ctr)/2)-1
                fprintf(fid, '%s_%04d  C  au  conc. "%03d" \n' , re.input(idi).name, idspace, round(re.input(idi).concmax/2));
            else
                fprintf(fid, '%s_%04d  C  au  conc. "%03d" \n' , re.input(idi).name, idspace, re.input(idi).concmin);
            end
        end
    end
end
fprintf(fid, '\n' );

eqSym = re.eqSymbolic;

fprintf(fid, '%s\n' , 'ODES');

re.ar.px = re.px; % todo: something similar to the initials, see below

for idy = 1:length(re.yLabel)
    for idspace = 1:length(re.PDE.ctr)
        eqSym1 = subs(eqSym(idy),  re.yLabel, states_strings(:,idspace)');
        if isfield(re,'pxOpt')
            for idpx = 1:length(re.pxOpt)
                eqSym2 = subs(eqSym1, re.pxLabel{idpx}, arSym(re.ar.px(idspace,idpx))); % todo, substitue parameterized function for px
            end
            eq_str = char(eqSym2);
        else
            eq_str = char(eqSym1);
        end
        if idspace > round(length(re.PDE.ctr)/2) 
            eq_str = strrep(eq_str,'anterior','posterior');
        end
        if idspace == round(length(re.PDE.ctr)/2) 
            eq_str = strrep(eq_str,'central','in');
        end
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
derived_states = cell(length(re.fz),length(re.PDE.ctr));
derived_eqSym = cell(length(re.fz),length(re.PDE.ctr));
fz = re.fz;
for idz = 1:length(re.fz)
    for idspace = 1:length(re.PDE.ctr)   
        derived_states{idz,idspace} = sprintf('%s_%04d',re.z{idz},idspace);
        derived_eqSym{idz,idspace} = subs(fz(idz),  re.yLabel, states_strings(:,idspace)');
        fprintf(fid, '%s  C  au  conc.  "%s"\n' , derived_states{idz,idspace}, derived_eqSym{idz,idspace});
    end
end
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
fclose(fid);

%% Data def

if exist('obs','var') && ~isempty(obs)
    if ~iscell(obs)
        error('rePDE2ar.m: First input (obs) should be a cell')
    end
    
    fid = fopen(['Data/arModel_' re.modelname], 'w');

    fprintf(fid, '%s\n' , 'DESCRIPTION');
    fprintf(fid, '"Exported model from %s."\n', re.modelname);
    fprintf(fid, '"%s"\n' , datestr(clock));
    fprintf(fid, '\n' );

    fprintf(fid, '%s\n' , 'PREDICTOR');
    fprintf(fid, '%s %f %f \n' , 't  T  h  time',re.PDE.t(1),re.PDE.t(end));
    fprintf(fid, '\n' );
    
    fprintf(fid, '%s\n' , 'INPUTS');
    fprintf(fid, '\n' );
    
    fprintf(fid, '%s\n' , 'OBSERVABLES');
    for idy = 1:length(re.yLabel)
        for ido = 1:length(obs)
            if strcmp(re.yLabel{idy},obs{ido})
                for idspace = 1:length(re.PDE.ctr)
                    fprintf(fid, '%s_obs  C  au  conc.  0  0 "offset_%s + %s * scale_%s" \n' , states_strings{idy,idspace},re.yLabel{idy},states_strings{idy,idspace},re.yLabel{idy});
                end
            end
        end
    end
    for idz = 1:length(re.z)
        for ido = 1:length(obs)
            if strcmp(re.z{idz},obs{ido})
                for idspace = 1:length(re.PDE.ctr)
                    fprintf(fid, '%s_obs  C  au  conc.  0  0 "offset_%s + %s * scale_%s" \n' , derived_states{idz,idspace},re.z{idz},derived_states{idz,idspace},re.z{idz});
                end
            end
        end
    end
    fprintf(fid, '\n' );
    
    fprintf(fid, '%s\n' , 'ERRORS');
    for idy = 1:length(re.yLabel)
        for ido = 1:length(obs)
            if strcmp(re.yLabel{idy},obs{ido})
                for idspace = 1:length(re.PDE.ctr)
                    fprintf(fid, '%s_obs  "sd_%s * %s_obs" \n', states_strings{idy,idspace}, re.yLabel{idy}, states_strings{idy,idspace});
                end
            end
        end
    end
    for idz = 1:length(re.z)
        for ido = 1:length(obs)
            if strcmp(re.z{idz},obs{ido})
                for idspace = 1:length(re.PDE.ctr)
                    fprintf(fid, '%s_obs  "sd_%s * %s_obs"\n' , derived_states{idz,idspace}, re.z{idz}, derived_states{idz,idspace});
                end
            end
        end
    end
    fprintf(fid, '\n' );
    
    fprintf(fid, '%s\n' , 'CONDITIONS');
    
    fclose(fid);
end
fprintf(['rePDE2ar.m: Models/arModel_' re.modelname ' and Data/arModel_' re.modelname ' have been written.\n'])
