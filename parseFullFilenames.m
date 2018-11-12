function fullFilenameCell = parseFullFilenames(directory, stringPattern)
%Generate a natural sorted list of full filenames(filepath and filename)
%   Inputs :
%           directory : String containing the path to the directory
%           containing the files you want to parse
%
%           stringPattern : String used to identify which filenames to
%           collect. Used as string pattern when calling dir().
%
%   Output :
%           fullFilenameCell : A cell array containing the full filenames
%           of each file that matches the stringPattern.

%parse files using dir
fileStruct = dir(strcat(directory, filesep, stringPattern));
%preallocate cell array to store full filenames
fullFilenameCell = cell(numel(fileStruct),1);
for n = 1:numel(fileStruct)
    fullFilenameCell{n} = fullfile(fileStruct(n).folder, fileStruct(n).name);
end