function multiBatchSelectionMod(directory, dirPattern, flPattern1, flPattern2)
%%multiBatchSelectionMod Run batchSelectionMod on multiple subdirectories

%   input :
%       directory: String variable containing the root directory to parse
%       for subdirectories
%
%       dirPattern: String variable containing the pattern to select
%       directories containing simulated images to analyze
%
%       flPattern1 : A string variable containing the pattern that
%       identifies the simulated fluorescent image stack to analyze, i.e.
%       '*_G_*.tif'
%
%       flPattern2 : A string variable containing the pattern that
%       identifies the simulated fluorescent image stack to analyze, i.e.
%       '*_R_*.tif'
%
%   output :
%       The called fuction, batchSelectionMod, will will save .mat files
%       containing the spotStructArray variable for each image set

%% Parse given directory for subdirectories matching dirPattern
fileStruct = dir(fullfile(directory, dirPattern));
%% Establish a return directory
returnDir = pwd;
%% Loop over parsed, image directories
for i = 1:numel(fileStruct)
    if fileStruct(i).isdir
        cd(fullfile(fileStruct(i).folder, fileStruct(i).name));
        batchSelectionMod(flPattern1, flPattern2);
    end
end
cd(returnDir)