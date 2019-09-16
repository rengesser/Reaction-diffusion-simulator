% name - file name of model.def
% obs - cell of observable names
% idx - columns of data entries
% n - Number of x coordinates
% t - tmax
%
% Example:
% idx = [2 4 7; 3 6 9]; idx(:,:,2) = [1 6 14;2 8 15];
% xls2data('JanineODE',{'dad','tkv'},idx,length(re.PDE.ctr),500)
%

function xls2data(name,obs,idx,n,t,sheet)

if ~exist('name','var') || isempty(name)
    name = '';
end
if ~exist('obs','var') || isempty(obs)
    obs = '';
end
if ~exist('idx','var') || isempty(idx)
    idx = [];
    for i=1:length(obs)
        idx(i) = i+1;
    end
    warning(['xls2data.m: Set idx to ' num2str(idx) '. Better specify the right column of observable from the xls yourself.']);
end
if ~exist('n','var') || isempty(n)
    n = 50;
end
if ~exist('t','var') || isempty(t)
    t = 500;
end
if ~exist('sheet','var') || isempty(sheet)
    sheet = 1;
end

delete(['Data' filesep 'arModel_' name '.xls'])

%% Get data
A = xlsread('Data/Data_Tkv.xlsx',1);
A = A(:,~any(isnan(A)));
try
    B = xlsread('Data/Data_Tkv.xlsx',2);
    B = B(:,~any(isnan(B)));
end

%% Set time
header = "t";
data = t;

%% Set condition
header(end+1) = "ubx";
data(end+1) = 0;

%% Convert Data matrix
for o =1:length(obs)
    if exist('B','var')
        if length(size(idx))<3
            warning('xls2data.m: Give index of 2nd xls sheet as a third dimension of idx.')
            num = [A(:,idx(o,1)) B(:,idx(o,2))];
        else
            num = [A(:,idx(o,:,1)) B(:,idx(o,:,2))];
        end
    else
        num = A(:,idx(o,:));
    end
    num = num / 1000;   
    % Shorten data to n x-coordinates
    x = round(linspace(1,size(A,1),n));
    num = smoothdata(num,round(size(num,1)/n/2));    
    % if 2nd xls-sheet exists
    if exist('B','var')
        data2 = data;
        av = nanmean(num(:,1:size(num,2)/2),2);
        av2 = nanmean(num(:,size(num,2/2+1):end),2);
        for i=1:n
        data2 = [data2 av2(x(i))];
            if exist('sd','var')
                data2 = [data2 sd2(x(i))];
            end
        end
    else
        av = nanmean(num,2);
    end
    % header & num
    for i=1:n
        header(end+1) = [obs{o} '_' num2str(i,'%04d') '_obs'];
        if exist('sd','var')
            header(end+1) = [obs{o} '_' num2str(i,'%04d') '_obs_std'];
        end
    end
    for i=1:n
        data = [data av(x(i))];
        if exist('sd','var')
            data = [data sd(x(i))];
        end
    end
end


%% Write XLS
data(2,:) = data;
data(2,2) = 1;
xlswrite(['Data' filesep 'arModel_' name],[header; data])
fprintf(['xlsdata.m: Data/arModel_' name '.xls has been written with ' num2str(n) ' x-coordinates for observables ' cell2mat(obs) ' at t = [' num2str(t) '].\n'])

if exist('data2','var')
    data2(2,:) = data2;
    data2(2,2) = 1;
    xlswrite(['Data' filesep 'arModel_' name '2'],[header; data2])
    fprintf(['xlsdata.m: Data/arModel_' name '2.xls has been written with ' num2str(n) ' x-coordinates for observables ' cell2mat(obs) ' at t = [' num2str(t) '].\n'])
    copyfile(['Data' filesep 'arModel_' name '.def'],['Data' filesep 'arModel_' name '2.def'])
end

