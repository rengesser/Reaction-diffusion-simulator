function reSave(name)
% Save re struct + model def file
global re
if ~exist('name','var')
   name = 'no_name'; 
   warning('no name given')
end

if ~exist('Results','dir')
    mkdir('Results');
end

fl = fileListre('Results');
nold = length(fl);

folder = [sprintf('%03i',nold+1) '_' name];
mkdir(['Results/' folder]);

save(['Results/' folder '/workspace.mat']);
disp(['Workspace saved to "Results/' folder '/workspace.mat"'])

% todo: save also RHS function into save folder and load it back when reLoad
