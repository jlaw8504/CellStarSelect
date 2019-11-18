function batchSelection(transBgFullFilename, transPattern, flPattern1, flPattern2)
%batchSelection Run spotSelection on multiple image sets
%   Inputs :
%       transFiles : Cell array of trans image stack filenames
%
%       transBgFullFilename : Full filename (path/filename) of the trans
%       image of the background
%
%       stack1Files : Cell array of fluorescent image stack filenames
%
%       stack2Files : Cell array of fluorescent image stack filenames
%
%   Outputs :
%
%       This function will save .mat files containing the
%       spotStructArray variable for each image set

%% Parse working directory for filenames
transStruct = dir(transPattern);
transFiles = {transStruct(:).name};
flStruct1 = dir(flPattern1);
flFiles1 = {flStruct1(:).name};
flStruct2 = dir(flPattern2);
flFiles2 = {flStruct2(:).name};
%% Check if file cell arrays contain the same number of elements
if ~(numel(transFiles) == numel(flFiles1) && numel(flFiles1) == numel(flFiles2))
    error('Number of image files does not match!');
end

for n = 1:numel(transFiles)
    spotStructArray = SpotDetectionModified(transFiles{n},...
        transBgFullFilename,...
        flFiles1{n},...
        flFiles2{n});
    [~, transBasename, ~] = fileparts(transFiles{n});
    save(strcat(transBasename, '.mat'), 'spotStructArray');
    clear spotStructArray
end