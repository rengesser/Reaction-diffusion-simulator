function reWriteRHS()
%% Write matlab function in file "RHS_PDE.m"
global re;
% introduce hashes, that not accidently parts of a name will be replaced in
% the string replacement 

nStates = length(re.yLabel);
eqSymbolic_hashed = re.eqSymbolic;

y_hashes = sprintfc('y_%i_UrTvb62qp0Freafdar54e27u',1:length(re.yLabel));
eqSymbolic_hashed = subs(eqSymbolic_hashed,re.yLabel,y_hashes);

p_hashes = sprintfc('p_%i_UrTvb62qp0Freafdar54e27u',1:length(re.pLabel));
eqSymbolic_hashed = subs(eqSymbolic_hashed,re.pLabel,p_hashes);

px_hashes = sprintfc('px_%i_UrTvb62qp0Freafdar54e27u',1:length(re.pxLabel));
eqSymbolic_hashed = subs(eqSymbolic_hashed,re.pxLabel,px_hashes);

u_hashes = sprintfc('u_%i_UrTvb62qp0Freafdar54e27u',1:length(re.uLabel));
eqSymbolic_hashed = subs(eqSymbolic_hashed,re.uLabel,u_hashes);

% sym back to string
for i = 1:length(eqSymbolic_hashed)
    eq_hashed{i} = char(eqSymbolic_hashed(i));
end

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
    eq_fkt{ii} = [eq_fkt{ii},'; % ',re.yLabel{ii}];
end

tmp  = sprintf('%s\n',eq_fkt{:});

filename = ['RHS_PDE_' datestr(now,'yyyymmdd_HHMM_SSFFF') '.m'];

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
