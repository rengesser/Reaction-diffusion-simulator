% reSetParsPattern(pattern, options)
% 
% pattern	pattern of the parameter name
% options   works in the same manner as reSetPars. See there for more
%           information
% 
% see also reSetPars

function reSetParsPattern(varargin)

global re

pLabels = re.pLabel(~cellfun(@isempty, strfind(re.pLabel, varargin{1})));
for i=1:length(pLabels)
    reSetPars(pLabels{i}, varargin{2:end});
end

% Plus diffusion coefficients
dLabels = re.dLabel(~cellfun(@isempty, strfind(re.dLabel, varargin{1})));
for i=1:length(dLabels)
    reSetPars(dLabels{i}, varargin{2:end});
end