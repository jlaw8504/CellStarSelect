function batchSelectionMod(flPattern1, flPattern2)
%batchSelection Run spotSelection on multiple image sets
%   Inputs :
%       flPattern1 : A string variable containing the pattern that
%       identifies the simulated fluorescent image stack to analyze, i.e.
%       '*_G_*.tif'
%
%       flPattern2 : A string variable containing the pattern that
%       identifies the simulated fluorescent image stack to analyze, i.e.
%       '*_R_*.tif'
%
%   Outputs :
%
%       This function will save .mat files containing the
%       spotStructArray variable for each image set

%% Parse working directory for filenames
flStruct1 = dir(flPattern1);
flStruct2 = dir(flPattern2);
%% Check if file cell arrays contain the same number of elements
if ~(numel(flStruct1) == numel(flStruct2))
    error('Number of image files (i.e. green to red images) does not match!');
end

for n = 1:numel(flStruct1)
    spotStructArray = SpotDetectionModified(...
        fullfile(flStruct1(n).folder, flStruct1(n).name),...
        fullfile(flStruct2(n).folder, flStruct2(n).name));
    [~, basename, ~] = fileparts(flStruct1(n).name);
    save(strcat(basename, '.mat'), 'spotStructArray');
    clear spotStructArray
end