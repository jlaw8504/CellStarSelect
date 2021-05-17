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
flFiles1 = {flStruct1(:).name};
flStruct2 = dir(flPattern2);
flFiles2 = {flStruct2(:).name};
%% Check if file cell arrays contain the same number of elements
if ~(numel(flFiles1) == numel(flFiles2))
    error('Number of image files (i.e. green to red images) does not match!');
end

for n = 1:numel(flFiles1)
    spotStructArray = SpotDetectionModified(...
        flFiles1{n},...
        flFiles2{n});
    [~, basename, ~] = fileparts(flFiles1{n});
    save(strcat(basename, '.mat'), 'spotStructArray');
    clear spotStructArray
end