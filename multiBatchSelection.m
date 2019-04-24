function multiBatchSelection(directory)
%%multiBatchSelection Run batchSelection on multiple subdirectories

%   input :
%       directory: String variable containing the root directory to parse
%       for subdirectories
%
%   output :
%       The called fuction, batchSelection, will will save .mat files
%       containing the spotStructArray variable for each image set

cd(directory); % change working directory
files = dir(); % Grab all directories and files from current directory
for n = 1:numel(files)
    if files(n).isdir && ~strcmp('.', files(n).name) &&...
            ~strcmp('..', files(n).name) %filter for subdirectories
        cd(files(n).name);
        batchSelection(...
            fullfile(pwd, 'blankTrans.tif'),...
            'Trans_*.tif',...
            'GFP_*.tif',...
            'RFP_*.tif')
        cd('..');
    end
end